import {
  createTemplate,
  getMyTemplates,
  getTemplateById,
  updateTemplate,
  deleteTemplate,
} from '../services/course-template.service.js';

const handleError = (res, error) => {
  const isValidationError =
    error.message.includes('required') ||
    error.message.includes('not found') ||
    error.message.includes('already') ||
    error.message.includes('allowed') ||
    error.message.includes('must');

  return res.status(isValidationError ? 400 : 500).json({
    message: error.message || 'Internal server error.',
  });
};

export const createTemplateController = async (req, res) => {
  try {
    const data = await createTemplate({ coachId: req.user.id, payload: req.body });
    return res.status(201).json(data);
  } catch (error) {
    return handleError(res, error);
  }
};

export const getMyTemplatesController = async (req, res) => {
  try {
    const data = await getMyTemplates({
      coachId: req.user.id,
      search: req.query.search,
      page: req.query.page,
      limit: req.query.limit,
    });
    return res.status(200).json(data);
  } catch (error) {
    return handleError(res, error);
  }
};

export const getTemplateByIdController = async (req, res) => {
  try {
    const data = await getTemplateById({ coachId: req.user.id, templateId: req.params.id });
    return res.status(200).json(data);
  } catch (error) {
    return handleError(res, error);
  }
};

export const updateTemplateController = async (req, res) => {
  try {
    const data = await updateTemplate({
      coachId: req.user.id,
      templateId: req.params.id,
      payload: req.body,
    });
    return res.status(200).json(data);
  } catch (error) {
    return handleError(res, error);
  }
};

export const deleteTemplateController = async (req, res) => {
  try {
    const data = await deleteTemplate({ coachId: req.user.id, templateId: req.params.id });
    return res.status(200).json(data);
  } catch (error) {
    return handleError(res, error);
  }
};
