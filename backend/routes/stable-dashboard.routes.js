import express from 'express';
import adminAuthMiddleware from '../middleware/admin-auth.middleware.js';
import {
  getStableDashboardOverviewController,
  getArenaScheduleController,
  getStableRevenueController,
  getHorseUtilizationController,
} from '../controllers/stable-dashboard.controller.js';

const router = express.Router();

router.get('/overview', adminAuthMiddleware, getStableDashboardOverviewController);
router.get('/arena-schedule', adminAuthMiddleware, getArenaScheduleController);
router.get('/revenue', adminAuthMiddleware, getStableRevenueController);
router.get('/horses/utilization', adminAuthMiddleware, getHorseUtilizationController);

export default router;
