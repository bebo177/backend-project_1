'use strict';

const ChatbotService = require('../services/ChatbotService');

const ChatController = {

  // POST /chat
  async chat(req, res, next) {
    try {
      const { message, userId } = req.body;

      // Use authenticated user id if available, otherwise use provided userId
      const resolvedUserId = req.user?.id || userId || null;
      const ipAddress      = req.ip || req.socket?.remoteAddress || null;

      const result = await ChatbotService.getReply(message, resolvedUserId, ipAddress);

      return res.status(200).json({
        success:    true,
        reply:      result.reply,
        confidence: result.confidence,
      });
    } catch (err) {
      next(err);
    }
  },
};

module.exports = ChatController;
