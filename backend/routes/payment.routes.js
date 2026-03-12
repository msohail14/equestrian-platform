import express from 'express';
import authMiddleware from '../middleware/auth.middleware.js';
import coachAuthMiddleware from '../middleware/coach-auth.middleware.js';
import {
  initiatePaymentController,
  webhookController,
  getPaymentStatusController,
  getUserPaymentsController,
  getUserSubscriptionController,
  cancelSubscriptionController,
  getCoachPayoutsController,
} from '../controllers/payment.controller.js';

const router = express.Router();

router.post('/initiate', authMiddleware, initiatePaymentController);
router.post('/webhook', webhookController);
router.get('/status/:transactionId', authMiddleware, getPaymentStatusController);
router.get('/my-payments', authMiddleware, getUserPaymentsController);
router.get('/my-subscription', authMiddleware, getUserSubscriptionController);
router.patch('/subscriptions/:id/cancel', authMiddleware, cancelSubscriptionController);
router.get('/coach-payouts', coachAuthMiddleware, getCoachPayoutsController);

export default router;
