'use strict';

require('dotenv').config();

const app                = require('./app');
const { testConnection } = require('./config/database');
const logger             = require('./utils/logger');

const PORT = parseInt(process.env.PORT || '3000', 10);

async function startServer() {
  try {
    // 1. Verify DB connection before accepting traffic
    await testConnection();
    logger.info('✅ MySQL connection established');

    // 2. Start HTTP server
    const server = app.listen(PORT, () => {
      logger.info(`🚀 Server running on http://localhost:${PORT} [${process.env.NODE_ENV || 'development'}]`);
    });

    // ── Graceful shutdown ───────────────────────────────────────────────────
    const shutdown = (signal) => {
      logger.info(`${signal} received. Shutting down gracefully...`);
      server.close(() => {
        logger.info('HTTP server closed.');
        process.exit(0);
      });
      // Force exit after 10 s if connections don't drain
      setTimeout(() => process.exit(1), 10_000).unref();
    };

    process.on('SIGTERM', () => shutdown('SIGTERM'));
    process.on('SIGINT',  () => shutdown('SIGINT'));

  } catch (err) {
    logger.error('Failed to start server', { error: err.message });
    process.exit(1);
  }
}

startServer();
