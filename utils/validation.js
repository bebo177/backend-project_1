'use strict';

const Joi = require('joi');

// ── Auth ──────────────────────────────────────────────────────────────────────

const registerSchema = Joi.object({
  name:     Joi.string().min(2).max(100).required().trim(),
  email:    Joi.string().email().max(191).required().lowercase().trim(),
  password: Joi.string().min(8).max(128).required()
    .pattern(/[A-Z]/, 'uppercase')
    .pattern(/[0-9]/, 'number')
    .messages({
      'string.pattern.name': '"password" must contain at least one {#name} character',
    }),
});

const loginSchema = Joi.object({
  email:    Joi.string().email().required().lowercase().trim(),
  password: Joi.string().required(),
});

const forgotPasswordSchema = Joi.object({
  email: Joi.string().email().required().lowercase().trim(),
});

const resetPasswordSchema = Joi.object({
  token:    Joi.string().min(10).required(),
  password: Joi.string().min(8).max(128).required()
    .pattern(/[A-Z]/, 'uppercase')
    .pattern(/[0-9]/, 'number')
    .messages({
      'string.pattern.name': '"password" must contain at least one {#name} character',
    }),
});

// ── Chat ──────────────────────────────────────────────────────────────────────

const chatSchema = Joi.object({
  message: Joi.string().min(1).max(1000).required().trim(),
  userId:  Joi.alternatives().try(
    Joi.number().integer().positive(),
    Joi.string().max(100)
  ).optional(),
});

// ── Middleware factory ────────────────────────────────────────────────────────

/**
 * Returns an Express middleware that validates req.body against `schema`.
 * Sends 422 on failure; calls next() on success.
 */
function validate(schema) {
  return (req, res, next) => {
    const { error, value } = schema.validate(req.body, {
      abortEarly:   false,
      stripUnknown: true,
    });

    if (error) {
      const details = error.details.map(d => ({
        field:   d.context?.key || 'unknown',
        message: d.message,
      }));
      return res.status(422).json({
        success: false,
        message: 'Validation failed',
        errors:  details,
      });
    }

    req.body = value;   // use the sanitised / normalised values
    next();
  };
}

module.exports = {
  validateRegister:       validate(registerSchema),
  validateLogin:          validate(loginSchema),
  validateForgotPassword: validate(forgotPasswordSchema),
  validateResetPassword:  validate(resetPasswordSchema),
  validateChat:           validate(chatSchema),
};
