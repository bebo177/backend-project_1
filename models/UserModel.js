'use strict';

const { pool } = require('../config/database');

const UserModel = {
  // ── Finders ──────────────────────────────────────────────────────────────

  async findById(id) {
    const [rows] = await pool.execute(
      'SELECT id, name, email, provider, avatar, is_active, created_at FROM users WHERE id = ?',
      [id]
    );
    return rows[0] || null;
  },

  async findByEmail(email) {
    const [rows] = await pool.execute(
      'SELECT * FROM users WHERE email = ? LIMIT 1',
      [email]
    );
    return rows[0] || null;
  },

  // ── Writers ──────────────────────────────────────────────────────────────

  /**
   * Create a local (email/password) user.
   */
  async createLocalUser({ name, email, hashedPassword }) {
    const [result] = await pool.execute(
      `INSERT INTO users (name, email, password, provider)
       VALUES (?, ?, ?, 'local')`,
      [name, email, hashedPassword]
    );
    return this.findById(result.insertId);
  },

  /**
   * Create a social (Google / Facebook) user.
   */
  async createSocialUser({ name, email, provider, providerId, avatar }) {
    const [result] = await pool.execute(
      `INSERT INTO users (name, email, provider, provider_id, avatar)
       VALUES (?, ?, ?, ?, ?)`,
      [name, email, provider, providerId, avatar || null]
    );
    return this.findById(result.insertId);
  },

  async updatePassword(userId, hashedPassword) {
    await pool.execute(
      'UPDATE users SET password = ? WHERE id = ?',
      [hashedPassword, userId]
    );
  },
};

module.exports = UserModel;
