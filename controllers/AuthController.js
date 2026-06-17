'use strict';

const AuthService = require('../services/AuthService');
const { signToken } = require('../utils/jwt');
const logger = require('../utils/logger');

const AuthController = {

  // POST /auth/register
  async register(req, res, next) {
    try {
      const { name, email, password } = req.body;
      const result = await AuthService.register({ name, email, password });
      return res.status(201).json({
        success: true,
        message: 'Registration successful',
        data: {
          user:  result.user,
          token: result.token,
        },
      });
    } catch (err) {
      next(err);
    }
  },

  // POST /auth/login
  async login(req, res, next) {
    try {
      const { email, password } = req.body;
      const result = await AuthService.login({ email, password });
      return res.status(200).json({
        success: true,
        message: 'Login successful',
        data: {
          user:  result.user,
          token: result.token,
        },
      });
    } catch (err) {
      next(err);
    }
  },

  // GET /auth/google/callback  (called by Passport after Google OAuth)
  async googleCallback(req, res, next) {
    try {
      const result = AuthService.socialLogin(req.user);
      // In a real frontend app, redirect to frontend with token in query param
      // or exchange it for a session. Here we return JSON for API testing.
      return res.status(200).json({
        success: true,
        message: 'Google login successful',
        data: {
          user:  result.user,
          token: result.token,
        },
      });
    } catch (err) {
      next(err);
    }
  },

  // GET /auth/facebook/callback  (called by Passport after Facebook OAuth)
  async facebookCallback(req, res, next) {
    try {
      const result = AuthService.socialLogin(req.user);
      return res.status(200).json({
        success: true,
        message: 'Facebook login successful',
        data: {
          user:  result.user,
          token: result.token,
        },
      });
    } catch (err) {
      next(err);
    }
  },

  // POST /auth/forgot-password
  async forgotPassword(req, res, next) {
    try {
      const { email } = req.body;
      const result = await AuthService.forgotPassword({ email });
      return res.status(200).json({ success: true, ...result });
    } catch (err) {
      next(err);
    }
  },

  // POST /auth/reset-password
  async resetPassword(req, res, next) {
    try {
      const { token, password } = req.body;
      const result = await AuthService.resetPassword({ token, password });
      return res.status(200).json({ success: true, ...result });
    } catch (err) {
      next(err);
    }
  },

  // GET /auth/me  (protected — requires JWT)
  async me(req, res) {
    return res.status(200).json({
      success: true,
      data:    { user: req.user },
    });
  },
};

module.exports = AuthController;
