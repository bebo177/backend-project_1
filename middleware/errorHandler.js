'use strict';

const logger = require('../utils/logger');

/**
 * Centralised error handler — must be registered LAST with app.use().
 */
// eslint-disable-next-line no-unused-vars
function errorHandler(err, req, res, next) {
  const statusCode = err.statusCode || 500;
  const isProduction = process.env.NODE_ENV === 'production';

  // Log all 5xx errors (server faults); log 4xx at warn level
  if (statusCode >= 500) {
    logger.error('Server error', {
      message:    err.message,
      stack:      err.stack,
      path:       req.path,
      method:     req.method,
      ip:         req.ip,
    });
  } else {
    logger.warn('Client error', {
      message: err.message,
      path:    req.path,
      method:  req.method,
      status:  statusCode,
    });
  }

  // MySQL duplicate entry
  if (err.code === 'ER_DUP_ENTRY') {
    return res.status(409).json({
      success: false,
      message: 'A record with this value already exists.',
    });
  }

  return res.status(statusCode).json({
    success: false,
    message: isProduction && statusCode === 500
      ? 'An unexpected error occurred. Please try again later.'
      : err.message || 'Internal server error',
    ...(isProduction ? {} : { stack: err.stack }),
  });
}

/**
 * 404 handler — register just before errorHandler.
 */
function notFound(req, res) {
  return res.status(404).json({
    success: false,
    message: `Cannot ${req.method} ${req.originalUrl}`,
  });
}

module.exports = { errorHandler, notFound };
