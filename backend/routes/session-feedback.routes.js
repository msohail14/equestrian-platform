import express from 'express';
import authMiddleware from '../middleware/auth.middleware.js';
import coachAuthMiddleware from '../middleware/coach-auth.middleware.js';
import {
  createFeedbackController,
  getSessionFeedbackController,
  getRiderPerformanceController,
} from '../controllers/session-feedback.controller.js';

const router = express.Router();

router.post('/session/:id', coachAuthMiddleware, createFeedbackController);
router.get('/session/:id', authMiddleware, getSessionFeedbackController);
router.get('/rider/:id/performance', authMiddleware, getRiderPerformanceController);

export default router;
