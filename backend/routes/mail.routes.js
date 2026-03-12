import express from 'express';
import adminAuthMiddleware from '../middleware/admin-auth.middleware.js';
import { mailRateLimiter } from '../middleware/rate-limit.middleware.js';
import {
  sendCustomMailController,
  sendOtpMailController,
  sendResetLinkMailController,
  sendResetTokenMailController,
} from '../controllers/mail.controller.js';

const router = express.Router();

router.post('/send', adminAuthMiddleware, mailRateLimiter, sendCustomMailController);
router.post('/send-otp', mailRateLimiter, sendOtpMailController);
router.post('/send-reset-token', mailRateLimiter, sendResetTokenMailController);
router.post('/send-reset-link', mailRateLimiter, sendResetLinkMailController);

export default router;
