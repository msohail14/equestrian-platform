import express from 'express';
import authMiddleware from '../middleware/auth.middleware.js';

const router = express.Router();

router.post('/initiate', authMiddleware, async (req, res) => {
  res.status(501).json({ message: 'Payment initiation not yet implemented.' });
});

router.post('/webhook', async (req, res) => {
  res.status(501).json({ message: 'Payment webhook not yet implemented.' });
});

router.get('/status/:transactionId', authMiddleware, async (req, res) => {
  res.status(501).json({ message: 'Payment status not yet implemented.' });
});

router.get('/my-payments', authMiddleware, async (req, res) => {
  res.status(501).json({ message: 'Payment history not yet implemented.' });
});

export default router;
