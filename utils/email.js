'use strict';

const nodemailer = require('nodemailer');
const logger     = require('./logger');

const transporter = nodemailer.createTransport({
  host:   process.env.EMAIL_HOST || 'smtp.mailtrap.io',
  port:   parseInt(process.env.EMAIL_PORT || '2525', 10),
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS,
  },
});

/**
 * Send a password-reset email.
 * @param {string} toEmail
 * @param {string} resetToken
 */
async function sendPasswordResetEmail(toEmail, resetToken) {
  const resetUrl = `${process.env.BASE_URL}/auth/reset-password?token=${resetToken}`;

  const mailOptions = {
    from:    process.env.EMAIL_FROM || 'noreply@yourapp.com',
    to:      toEmail,
    subject: 'Password Reset Request',
    html: `
      <h2>Password Reset</h2>
      <p>You requested to reset your password. Click the link below (valid for 1 hour):</p>
      <a href="${resetUrl}" style="
        display:inline-block;
        padding:10px 20px;
        background:#4F46E5;
        color:#fff;
        text-decoration:none;
        border-radius:6px;
      ">Reset Password</a>
      <p>If you did not request this, please ignore this email.</p>
      <hr/>
      <small>Token (for API testing): <code>${resetToken}</code></small>
    `,
  };

  try {
    const info = await transporter.sendMail(mailOptions);
    logger.info('Password reset email sent', { to: toEmail, messageId: info.messageId });
    return info;
  } catch (err) {
    logger.error('Failed to send password reset email', { error: err.message });
    throw err;
  }
}

module.exports = { sendPasswordResetEmail };
