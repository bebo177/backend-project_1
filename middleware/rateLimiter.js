'use strict';

const rateLimit = require('express-rate-limit');

const windowMs  = parseInt(process.env.RATE_LIMIT_WINDOW_MS    || '900000', 10); // 15 min
const maxReqs   = parseInt(process.env.RATE_LIMIT_MAX_REQUESTS || '100',    10);
const authMax   = parseInt(process.env.RATE_LIMIT_AUTH_MAX     || '10',     10);

/**
 * General rate limiter — applied to all routes.
 */
const generalLimiter = rateLimit({
  windowMs,
  max:         maxReqs,
  standardHeaders: true,
  legacyHeaders:   false,
  message: {
    success: false,
    message: 'Too many requests from this IP, please try again later.',
  },
});

/**
 * Stricter limiter for sensitive auth endpoints.
 * 10 attempts per 15 minutes per IP.
 */
const authLimiter = rateLimit({
  windowMs,
  max:         authMax,
  standardHeaders: true,
  legacyHeaders:   false,
  message: {
    success: false,
    message: 'Too many authentication attempts, please try again later.',
  },
});

/**
 * Chat endpoint limiter — 60 messages per 15 minutes.
 */
const chatLimiter = rateLimit({
  windowMs,
  max:         60,
  standardHeaders: true,
  legacyHeaders:   false,
  message: {
    success: false,
    message: 'Too many chat requests, please slow down.',
  },
});

module.exports = { generalLimiter, authLimiter, chatLimiter };
