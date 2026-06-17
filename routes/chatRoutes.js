'use strict';

const express        = require('express');
const ChatController = require('../controllers/ChatController');
const { optionalAuth } = require('../middleware/auth');
const { chatLimiter }  = require('../middleware/rateLimiter');
const { validateChat }  = require('../utils/validation');

const router = express.Router();

/**
 * @route  POST /chat
 * @desc   Send a message to the chatbot and receive a reply
 * @access Public (optionally authenticated — logs userId if token provided)
 */
router.post('/', chatLimiter, optionalAuth, validateChat, ChatController.chat);

module.exports = router;
