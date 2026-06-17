'use strict';

const { pool } = require('../config/database');

const ChatbotModel = {
  /**
   * Fetch all active chatbot entries.
   * @returns {Array}
   */
  async getAllActive() {
    const [rows] = await pool.execute(
      'SELECT id, question, answer, category, keywords FROM chatbot_data WHERE is_active = 1'
    );
    return rows;
  },

  /**
   * MySQL FULLTEXT search — fast server-side candidate retrieval.
   * Returns up to `limit` rows scored by relevance.
   * @param {string} query
   * @param {number} limit
   */
  async fullTextSearch(query, limit = 10) {
    // Sanitise for BOOLEAN MODE: strip special chars
    const safeQuery = query.replace(/[+\-><()~*"@]+/g, ' ').trim();
    if (!safeQuery) return [];

    const [rows] = await pool.execute(
      `SELECT id, fault_id ,questions, system_name, fault, user_symptoms, ranking_score, final_diagnosis, answer, category, keywords,
              MATCH(fault, user_symptoms) AGAINST (? IN BOOLEAN MODE) AS score
       FROM chatbot_data
       WHERE is_active = 1
         AND MATCH(fault, user_symptoms) AGAINST (? IN BOOLEAN MODE)
       ORDER BY score DESC
       LIMIT ?`,
      [safeQuery, safeQuery, limit]
    );
    return rows;
  },

  /**
   * Log a chat interaction.
   */
  async logChat({ userId, userMessage, botReply, confidence, matchedId, ipAddress }) {
    await pool.execute(
      `INSERT INTO chat_logs (user_id, user_message, bot_reply, confidence, matched_id, ip_address)
       VALUES (?, ?, ?, ?, ?, ?)`,
      [userId || null, userMessage, botReply, confidence, matchedId || null, ipAddress || null]
    );
  },
};

module.exports = ChatbotModel;
