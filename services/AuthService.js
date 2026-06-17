'use strict';

const bcrypt             = require('bcryptjs');
const UserModel          = require('../models/UserModel');
const PasswordResetModel = require('../models/PasswordResetModel');
const { signToken }      = require('../utils/jwt');
const { sendPasswordResetEmail } = require('../utils/email');
const logger             = require('../utils/logger');

const SALT_ROUNDS = parseInt(process.env.BCRYPT_SALT_ROUNDS || '12', 10);

const AuthService = {
  // ── Register ────────────────────────────────────────────────────────────

  async register({ name, email, password }) {
    // 1. Ensure email is not taken
    const existing = await UserModel.findByEmail(email);
    if (existing) {
      const err = new Error('Email is already registered');
      err.statusCode = 409;
      throw err;
    }

    // 2. Hash password
    const hashedPassword = await bcrypt.hash(password, SALT_ROUNDS);

    // 3. Persist
    const user = await UserModel.createLocalUser({ name, email, hashedPassword });

    // 4. Issue token
    const token = signToken(user);

    logger.info('New user registered', { userId: user.id, email: user.email });

    return { user, token };
  },

  // ── Login ────────────────────────────────────────────────────────────────

  async login({ email, password }) {
    const user = await UserModel.findByEmail(email);

    if (!user || user.provider !== 'local') {
      const err = new Error('Invalid email or password');
      err.statusCode = 401;
      throw err;
    }

    const match = await bcrypt.compare(password, user.password);
    if (!match) {
      const err = new Error('Invalid email or password');
      err.statusCode = 401;
      throw err;
    }

    if (!user.is_active) {
      const err = new Error('Account is deactivated');
      err.statusCode = 403;
      throw err;
    }

    const token = signToken(user);

    // Return a safe user object (no password)
    const safeUser = {
      id:         user.id,
      name:       user.name,
      email:      user.email,
      provider:   user.provider,
      avatar:     user.avatar,
      created_at: user.created_at,
    };

    logger.info('User logged in', { userId: user.id });

    return { user: safeUser, token };
  },

  // ── Social Login (called from Passport callback) ─────────────────────────

  socialLogin(user) {
    const token = signToken(user);
    logger.info('Social login', { userId: user.id, provider: user.provider });
    return { user, token };
  },

  // ── Forgot Password ──────────────────────────────────────────────────────

  async forgotPassword({ email }) {
    const user = await UserModel.findByEmail(email);

    // Always return success to prevent email enumeration
    if (!user || user.provider !== 'local') {
      logger.info('Forgot-password: email not found or social account', { email });
      return { message: 'If that email is registered, a reset link has been sent.' };
    }

    const token = await PasswordResetModel.createToken(user.id);

    try {
      await sendPasswordResetEmail(email, token);
    } catch (emailErr) {
      logger.error('Failed to send reset email', { error: emailErr.message });
      // Don't expose email errors to the client
    }

    logger.info('Password reset token created', { userId: user.id });

    return {
      message: 'If that email is registered, a reset link has been sent.',
      // Include token in dev mode for easy Postman testing
      ...(process.env.NODE_ENV !== 'production' && { debug_token: token }),
    };
  },

  // ── Reset Password ───────────────────────────────────────────────────────

  async resetPassword({ token, password }) {
    const record = await PasswordResetModel.findValidToken(token);

    if (!record) {
      const err = new Error('Reset token is invalid or has expired');
      err.statusCode = 400;
      throw err;
    }

    const hashedPassword = await bcrypt.hash(password, SALT_ROUNDS);

    await UserModel.updatePassword(record.user_id, hashedPassword);
    await PasswordResetModel.markUsed(token);

    logger.info('Password reset successful', { userId: record.user_id });

    return { message: 'Password has been reset successfully. You can now log in.' };
  },
};

module.exports = AuthService;
