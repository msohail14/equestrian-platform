import express from 'express';
import adminAuthMiddleware from '../middleware/admin-auth.middleware.js';
import {
  getHorseAvailabilityController,
  setHorseAvailabilityController,
  blockHorseDatesController,
} from '../controllers/horse-availability.controller.js';

const router = express.Router();

router.get('/:id/availability', getHorseAvailabilityController);

router.put('/:id/availability', adminAuthMiddleware, setHorseAvailabilityController);
router.post('/:id/block-dates', adminAuthMiddleware, blockHorseDatesController);

export default router;
