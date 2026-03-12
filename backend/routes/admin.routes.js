import express from 'express';
import adminAuthMiddleware from '../middleware/admin-auth.middleware.js';
import { authRateLimiter } from '../middleware/rate-limit.middleware.js';
import {
  changeAdminPasswordController,
  changeAdminProfileController,
  forgotAdminPasswordController,
  getAdminDashboardController,
  loginAdminController,
  resetAdminPasswordController,
  signupAdminController,
} from '../controllers/admin.controller.js';

const router = express.Router();

router.post('/signup', authRateLimiter, signupAdminController);
router.post('/login', authRateLimiter, loginAdminController);
router.post('/forgot-password', authRateLimiter, forgotAdminPasswordController);
router.post('/resend-reset-token', authRateLimiter, forgotAdminPasswordController);
router.post('/reset-password', authRateLimiter, resetAdminPasswordController);
router.post('/change-password', adminAuthMiddleware, changeAdminPasswordController);
router.put('/change-profile', adminAuthMiddleware, changeAdminProfileController);
router.get('/dashboard', adminAuthMiddleware, getAdminDashboardController);

export default router;
