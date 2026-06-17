'use strict';

const { pool } = require('../config/database');
const { v4: uuidv4 } = require('uuid');

const PasswordResetModel = {
  /**
   * Create a new password-reset token (invalidate previous ones first).
   * @param {number} userId
   * @returns {string} plaintext token
   */
  async createToken(userId) {
    // Soft-invalidate previous unused tokens for this user
    await pool.execute(
      'UPDATE password_resets SET used = 1 WHERE user_id = ? AND used = 0',
      [userId]
    );

    const token     = uuidv4();
    const expiresAt = new Date(Date.now() + 60 * 60 * 1000); // +1 hour

    await pool.execute(
      'INSERT INTO password_resets (user_id, token, expires_at) VALUES (?, ?, ?)',
      [userId, token, expiresAt]
    );

    return token;
  },

  /**
   * Find a valid (unused, not expired) reset token row.
   * @param {string} token
   */
  async findValidToken(token) {
    const [rows] = await pool.execute(
      `SELECT pr.*, u.email
       FROM password_resets pr
       JOIN users u ON u.id = pr.user_id
       WHERE pr.token = ?
         AND pr.used = 0
         AND pr.expires_at > NOW()
       LIMIT 1`,
      [token]
    );
    return rows[0] || null;
  },

  /**
   * Mark a token as used.
   * @param {string} token
   */
  async markUsed(token) {
    await pool.execute(
      'UPDATE password_resets SET used = 1 WHERE token = ?',
      [token]
    );
  },
};

module.exports = PasswordResetModel;
