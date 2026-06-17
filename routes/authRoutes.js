'use strict';

const express        = require('express');
const passport       = require('passport');
const AuthController = require('../controllers/AuthController');
const { authenticate } = require('../middleware/auth');
const { authLimiter }  = require('../middleware/rateLimiter');
const {
  validateRegister,
  validateLogin,
  validateForgotPassword,
  validateResetPassword,
} = require('../utils/validation');

const router = express.Router();

// ── Local Auth ────────────────────────────────────────────────────────────────

/**
 * @route  POST /auth/register
 * @desc   Register a new local user
 * @access Public
 */
router.post('/register', authLimiter, validateRegister, AuthController.register);

/**
 * @route  POST /auth/login
 * @desc   Login and receive JWT
 * @access Public
 */
router.post('/login', authLimiter, validateLogin, AuthController.login);

/**
 * @route  POST /auth/forgot-password
 * @desc   Send a password-reset email
 * @access Public
 */
router.post('/forgot-password', authLimiter, validateForgotPassword, AuthController.forgotPassword);

/**
 * @route  POST /auth/reset-password
 * @desc   Reset password using token
 * @access Public
 */
router.post('/reset-password', authLimiter, validateResetPassword, AuthController.resetPassword);

/**
 * @route  GET /auth/me
 * @desc   Get current authenticated user
 * @access Private
 */
router.get('/me', authenticate, AuthController.me);

// ── Google OAuth ──────────────────────────────────────────────────────────────

/**
 * @route  GET /auth/google
 * @desc   Redirect to Google OAuth consent screen
 * @access Public
 */
router.get(
  '/google',
  passport.authenticate('google', { scope: ['profile', 'email'], session: false })
);

/**
 * @route  GET /auth/google/callback
 * @desc   Google OAuth callback
 * @access Public
 */
router.get(
  '/google/callback',
  passport.authenticate('google', { session: false, failureRedirect: '/auth/login?error=google_failed' }),
  AuthController.googleCallback
);

// ── Facebook OAuth ────────────────────────────────────────────────────────────

/**
 * @route  GET /auth/facebook
 * @desc   Redirect to Facebook OAuth consent screen
 * @access Public
 */
router.get(
  '/facebook',
  passport.authenticate('facebook', { scope: ['email'], session: false })
);

/**
 * @route  GET /auth/facebook/callback
 * @desc   Facebook OAuth callback
 * @access Public
 */
router.get(
  '/facebook/callback',
  passport.authenticate('facebook', { session: false, failureRedirect: '/auth/login?error=facebook_failed' }),
  AuthController.facebookCallback
);

module.exports = router;
