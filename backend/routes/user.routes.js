import express from 'express';
import authMiddleware from '../middleware/auth.middleware.js';
import { uploadUserProfileImage } from '../middleware/upload.middleware.js';
import { authRateLimiter, otpRateLimiter } from '../middleware/rate-limit.middleware.js';
import {
  changePasswordController,
  changeProfileController,
  forgotPasswordController,
  getMyProfileController,
  login,
  resendEmailOtpController,
  resetPasswordController,
  signup,
  verifyEmailOtpController,
} from '../controllers/user.controller.js';

const router = express.Router();

router.post('/signup', authRateLimiter, uploadUserProfileImage, signup);
router.post('/login', authRateLimiter, login);
router.post('/verify-email-otp', otpRateLimiter, verifyEmailOtpController);
router.post('/resend-verification-otp', otpRateLimiter, resendEmailOtpController);
router.post('/forgot-password', authRateLimiter, forgotPasswordController);
router.post('/resend-reset-token', authRateLimiter, forgotPasswordController);
router.post('/reset-password', authRateLimiter, resetPasswordController);
router.get('/me', authMiddleware, getMyProfileController);
router.post('/change-password', authMiddleware, changePasswordController);
router.put('/change-profile', authMiddleware, uploadUserProfileImage, changeProfileController);

export default router;
