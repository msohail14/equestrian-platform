import express from 'express';
import coachAuthMiddleware from '../middleware/coach-auth.middleware.js';
import {
  getCoachDashboardController,
  getCoachEarningsController,
} from '../controllers/coach-dashboard.controller.js';

const router = express.Router();

router.get('/', coachAuthMiddleware, getCoachDashboardController);
router.get('/earnings', coachAuthMiddleware, getCoachEarningsController);

export default router;
