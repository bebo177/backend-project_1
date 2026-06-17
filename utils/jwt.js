'use strict';

const jwt    = require('jsonwebtoken');
const logger = require('./logger');

const SECRET     = process.env.JWT_SECRET     || 'change_me_in_production';
const EXPIRES_IN = process.env.JWT_EXPIRES_IN || '7d';

/**
 * Sign a JWT for the given user payload.
 * @param {{ id: number, email: string }} payload
 * @returns {string}
 */
function signToken(payload) {
  return jwt.sign(
    { id: payload.id, email: payload.email },
    SECRET,
    { expiresIn: EXPIRES_IN, algorithm: 'HS256' }
  );
}

/**
 * Verify a JWT and return the decoded payload.
 * Throws JsonWebTokenError / TokenExpiredError on failure.
 * @param {string} token
 * @returns {object}
 */
function verifyToken(token) {
  try {
    return jwt.verify(token, SECRET, { algorithms: ['HS256'] });
  } catch (err) {
    logger.warn('JWT verification failed', { error: err.message });
    throw err;
  }
}

module.exports = { signToken, verifyToken };
