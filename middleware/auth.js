'use strict';

const { verifyToken } = require('../utils/jwt');
const UserModel       = require('../models/UserModel');
const logger          = require('../utils/logger');

/**
 * Protect a route: validates Bearer JWT, attaches req.user.
 */
async function authenticate(req, res, next) {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({
      success: false,
      message: 'Authentication required. Provide a Bearer token.',
    });
  }

  const token = authHeader.split(' ')[1];

  try {
    const decoded = verifyToken(token);
    const user    = await UserModel.findById(decoded.id);

    if (!user || !user.is_active) {
      return res.status(401).json({
        success: false,
        message: 'User not found or account deactivated.',
      });
    }

    req.user = user;
    next();
  } catch (err) {
    logger.warn('Unauthorized access attempt', {
      ip:    req.ip,
      error: err.message,
    });

    if (err.name === 'TokenExpiredError') {
      return res.status(401).json({ success: false, message: 'Token has expired.' });
    }

    return res.status(401).json({ success: false, message: 'Invalid token.' });
  }
}

/**
 * Optional auth: attaches req.user if a valid token is present,
 * but does NOT block the request if no token is provided.
 */
async function optionalAuth(req, res, next) {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    req.user = null;
    return next();
  }

  try {
    const token   = authHeader.split(' ')[1];
    const decoded = verifyToken(token);
    const user    = await UserModel.findById(decoded.id);
    req.user = user || null;
  } catch {
    req.user = null;
  }

  next();
}

module.exports = { authenticate, optionalAuth };
