'use strict';

/**
 * ChatbotService — proxies user messages to the Python FastAPI bot
 * running on PYTHON_BOT_URL (default http://localhost:8000).
 *
 * The Python service handles all the heavy lifting:
 *   - Arabic text normalization
 *   - Fuzzy symptom matching against the 14-fault dataset
 *   - Bilingual intent detection
 *   - Stateful diagnostic question loop (per session_id)
 *
 * This service still owns:
 *   - Logging every interaction to MySQL `chat_logs`
 *   - Mapping the Python response shape into the Express response shape
 *     that the rest of the app expects: { reply, confidence }
 *
 * Session continuity:
 *   - Authenticated users → session_id = `user-${userId}` (persists across
 *     requests, so the diagnostic question loop survives)
 *   - Anonymous users → session_id = `ip-${ipAddress}` (best-effort; if
 *     IP changes mid-conversation the bot will restart its FSM, which is
 *     acceptable for anonymous traffic)
 */

const ChatbotModel = require('../models/ChatbotModel');
const logger       = require('../utils/logger');

// ── Configuration ────────────────────────────────────────────────────────

const PYTHON_BOT_URL = process.env.PYTHON_BOT_URL || 'http://localhost:8000';
const REQUEST_TIMEOUT_MS = parseInt(process.env.PYTHON_BOT_TIMEOUT_MS || '5000', 10);

const FALLBACK_REPLY = {
  reply:      'عذراً، حصلت مشكلة مؤقتة. حاول تاني بعد شوية.',
  confidence: 0,
  matchedId:  null,
};

// ── Helpers ──────────────────────────────────────────────────────────────

/**
 * Build a stable session_id for the Python bot.
 * Same user → same session → state machine persists.
 */
function buildSessionId(userId, ipAddress) {
  if (userId) return `user-${userId}`;
  if (ipAddress) return `ip-${ipAddress.replace(/[:.]/g, '-')}`;
  return `anon-${Date.now()}`;
}

/**
 * Derive a confidence number from the Python bot's response.
 * The Python bot only emits a confidence value at the end of a diagnostic
 * flow (in `diagnosis.confidence`); for greetings, candidate lists, and
 * mid-flow questions we assign reasonable defaults so the existing API
 * contract — { reply, confidence } — keeps working for clients.
 */
function deriveConfidence(pythonResponse) {
  // End of a diagnostic flow → real confidence from the dataset.
  if (pythonResponse.diagnosis && typeof pythonResponse.diagnosis.confidence === 'number') {
    return pythonResponse.diagnosis.confidence;
  }
  // Mid-flow (asking a diagnostic question) → high confidence we're on track.
  if (pythonResponse.state === 'diagnosing' || pythonResponse.fault_id) {
    return 0.85;
  }
  // Candidate list shown → moderate confidence, user needs to pick.
  if (pythonResponse.state === 'choosing' || pythonResponse.candidates) {
    return 0.5;
  }
  // Plain idle reply (greeting, help text, fallback).
  return 0.9;
}

/**
 * Call the Python bot. Uses Node 18+ native fetch with an AbortController
 * so a hung Python service doesn't lock up Express threads.
 */
async function callPythonBot(sessionId, message) {
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), REQUEST_TIMEOUT_MS);

  try {
    const response = await fetch(`${PYTHON_BOT_URL}/chat`, {
      method:  'POST',
      headers: { 'Content-Type': 'application/json' },
      body:    JSON.stringify({ session_id: sessionId, message }),
      signal:  controller.signal,
    });

    if (!response.ok) {
      throw new Error(`Python bot returned ${response.status}`);
    }
    return await response.json();
  } finally {
    clearTimeout(timer);
  }
}

// ── Main service ─────────────────────────────────────────────────────────

const ChatbotService = {
  /**
   * Find the best matching answer for the given user message.
   * @param {string} message   Raw user input
   * @param {string|number|null} userId
   * @param {string|null} ipAddress
   * @returns {{ reply: string, confidence: number }}
   */
  async getReply(message, userId, ipAddress) {
    const sessionId = buildSessionId(userId, ipAddress);

    let reply;
    let confidence;
    let matchedId = null;

    try {
      const pythonResponse = await callPythonBot(sessionId, message);
      reply      = pythonResponse.reply;
      confidence = deriveConfidence(pythonResponse);
      matchedId  = pythonResponse.fault_id
                || (pythonResponse.diagnosis && pythonResponse.diagnosis.fault_id)
                || null;

      logger.debug('Python bot response', {
        sessionId,
        state:      pythonResponse.state,
        confidence,
        fault_id:   matchedId,
      });

    } catch (err) {
      // Python service down / slow / errored. Log it, return fallback,
      // but DON'T crash the Express request — the user still gets a reply.
      logger.error('Python bot call failed', {
        error:     err.message,
        sessionId,
        url:       PYTHON_BOT_URL,
      });
      reply      = FALLBACK_REPLY.reply;
      confidence = FALLBACK_REPLY.confidence;
    }

    // Log every interaction to MySQL — fire-and-forget so DB hiccups
    // don't block the user response.
    this._log(userId, message, reply, confidence, matchedId, ipAddress)
      .catch(err => logger.error('Failed to log chat', { error: err.message }));

    return { reply, confidence };
  },

  // ── Private helpers ────────────────────────────────────────────────────

  async _log(userId, userMessage, botReply, confidence, matchedId, ipAddress) {
    // matched_id in the DB is INT UNSIGNED. Python bot returns string IDs
    // like "COOL_001" which won't fit, so we store null for matched_id and
    // keep the bot reply text as the source of truth.
    const matchedIdForDb = (typeof matchedId === 'number') ? matchedId : null;

    await ChatbotModel.logChat({
      userId,
      userMessage,
      botReply,
      confidence,
      matchedId: matchedIdForDb,
      ipAddress,
    });
  },
};

module.exports = ChatbotService;
