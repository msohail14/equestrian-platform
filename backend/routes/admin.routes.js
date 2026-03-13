import express from 'express';
import adminAuthMiddleware from '../middleware/admin-auth.middleware.js';
import { authRateLimiter } from '../middleware/rate-limit.middleware.js';
import {
  approveStableController,
  changeAdminPasswordController,
  changeAdminProfileController,
  forgotAdminPasswordController,
  getAdminAnalyticsController,
  getAdminBookingsController,
  getAdminDashboardController,
  getAdminPaymentsController,
  getAdminPayoutsController,
  getAdminSettingsController,
  loginAdminController,
  processAdminPayoutController,
  resetAdminPasswordController,
  signupAdminController,
  updateAdminSettingsController,
  verifyCoachController,
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
router.get('/analytics', adminAuthMiddleware, getAdminAnalyticsController);
router.get('/payments', adminAuthMiddleware, getAdminPaymentsController);
router.get('/payouts', adminAuthMiddleware, getAdminPayoutsController);
router.post('/payouts/:id/process', adminAuthMiddleware, processAdminPayoutController);
router.patch('/stables/:id/approve', adminAuthMiddleware, approveStableController);
router.patch('/coaches/:id/verify', adminAuthMiddleware, verifyCoachController);
router.get('/settings', adminAuthMiddleware, getAdminSettingsController);
router.put('/settings', adminAuthMiddleware, updateAdminSettingsController);
router.get('/bookings', adminAuthMiddleware, getAdminBookingsController);

export default router;
