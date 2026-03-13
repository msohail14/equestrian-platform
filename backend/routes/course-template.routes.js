import express from 'express';
import coachAuthMiddleware from '../middleware/coach-auth.middleware.js';
import {
  createTemplateController,
  getMyTemplatesController,
  getTemplateByIdController,
  updateTemplateController,
  deleteTemplateController,
} from '../controllers/course-template.controller.js';

const router = express.Router();

router.post('/', coachAuthMiddleware, createTemplateController);
router.get('/', coachAuthMiddleware, getMyTemplatesController);
router.get('/:id', coachAuthMiddleware, getTemplateByIdController);
router.put('/:id', coachAuthMiddleware, updateTemplateController);
router.delete('/:id', coachAuthMiddleware, deleteTemplateController);

export default router;
