'use strict';

const { createLogger, format, transports } = require('winston');
const path = require('path');

const { combine, timestamp, printf, colorize, errors } = format;

// Custom log line format
const logFormat = printf(({ level, message, timestamp, stack, ...meta }) => {
  const metaStr = Object.keys(meta).length ? JSON.stringify(meta) : '';
  return `[${timestamp}] ${level}: ${stack || message} ${metaStr}`;
});

const logger = createLogger({
  level: process.env.NODE_ENV === 'production' ? 'info' : 'debug',
  format: combine(
    timestamp({ format: 'YYYY-MM-DD HH:mm:ss' }),
    errors({ stack: true }),
    logFormat
  ),
  transports: [
    // Console — colorised in dev, plain in prod
    new transports.Console({
      format: combine(
        colorize(),
        timestamp({ format: 'YYYY-MM-DD HH:mm:ss' }),
        errors({ stack: true }),
        logFormat
      ),
    }),
    // Persistent combined log
    new transports.File({
      filename: path.join(__dirname, '../logs/combined.log'),
      maxsize:  5_242_880,   // 5 MB
      maxFiles: 5,
    }),
    // Error-only log
    new transports.File({
      filename: path.join(__dirname, '../logs/error.log'),
      level:    'error',
      maxsize:  5_242_880,
      maxFiles: 5,
    }),
  ],
});

module.exports = logger;
