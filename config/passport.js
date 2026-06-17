'use strict';

const passport      = require('passport');
const GoogleStrategy  = require('passport-google-oauth20').Strategy;
const FacebookStrategy = require('passport-facebook').Strategy;
const UserModel     = require('../models/UserModel');
const logger        = require('../utils/logger');

// ── Google ────────────────────────────────────────────────────────────────────
passport.use(
  new GoogleStrategy(
    {
      clientID:     process.env.GOOGLE_CLIENT_ID,
      clientSecret: process.env.GOOGLE_CLIENT_SECRET,
      callbackURL:  process.env.GOOGLE_CALLBACK_URL,
    },
    async (accessToken, refreshToken, profile, done) => {
      try {
        const email  = profile.emails?.[0]?.value;
        const avatar = profile.photos?.[0]?.value;

        if (!email) {
          return done(new Error('No email returned from Google'), null);
        }

        let user = await UserModel.findByEmail(email);

        if (!user) {
          user = await UserModel.createSocialUser({
            name:       profile.displayName,
            email,
            provider:   'google',
            providerId: profile.id,
            avatar,
          });
        }

        return done(null, user);
      } catch (err) {
        logger.error('Google OAuth error', { error: err.message });
        return done(err, null);
      }
    }
  )
);

// ── Facebook ──────────────────────────────────────────────────────────────────
passport.use(
  new FacebookStrategy(
    {
      clientID:     process.env.FACEBOOK_APP_ID,
      clientSecret: process.env.FACEBOOK_APP_SECRET,
      callbackURL:  process.env.FACEBOOK_CALLBACK_URL,
      profileFields: ['id', 'displayName', 'emails', 'photos'],
    },
    async (accessToken, refreshToken, profile, done) => {
      try {
        const email  = profile.emails?.[0]?.value;
        const avatar = profile.photos?.[0]?.value;

        if (!email) {
          return done(new Error('No email returned from Facebook'), null);
        }

        let user = await UserModel.findByEmail(email);

        if (!user) {
          user = await UserModel.createSocialUser({
            name:       profile.displayName,
            email,
            provider:   'facebook',
            providerId: profile.id,
            avatar,
          });
        }

        return done(null, user);
      } catch (err) {
        logger.error('Facebook OAuth error', { error: err.message });
        return done(err, null);
      }
    }
  )
);

module.exports = passport;
