'use strict';

/**
 * Express application bootstrap.
 * server.js requires this module and calls app.listen().
 */

const express      = require('express');
const helmet       = require('helmet');
const cors         = require('cors');
const morgan       = require('morgan');

const authRoutes   = require('./routes/authRoutes');
const chatRoutes   = require('./routes/chatRoutes');
const { errorHandler, notFound } = require('./middleware/errorHandler');
const logger       = require('./utils/logger');

const app = express();

// ── Security & parsing middleware ────────────────────────────────────────
app.use(helmet());
app.use(cors({
  origin:      process.env.CORS_ORIGIN || '*',
  credentials: true,
}));
app.use(express.json({ limit: '1mb' }));
app.use(express.urlencoded({ extended: true }));

// HTTP request logging → winston
app.use(morgan('combined', {
  stream: { write: (msg) => logger.info(msg.trim()) },
}));

// Trust first proxy (needed for correct req.ip behind load balancers / nginx)
app.set('trust proxy', 1);

// ── Health check ─────────────────────────────────────────────────────────
app.get('/health', (req, res) => {
  res.json({ ok: true, service: 'backend-project', timestamp: new Date().toISOString() });
});

// ── Routes ───────────────────────────────────────────────────────────────
app.use('/auth', authRoutes);
app.use('/chat', chatRoutes);

// 404 handler — use the one from middleware/errorHandler.js
app.use(notFound);

// Centralised error handler — MUST be last middleware
app.use(errorHandler);

module.exports = app;