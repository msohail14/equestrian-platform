import { Op } from 'sequelize';
import { CourseTemplate, User } from '../models/index.js';

const normalizePagination = ({ page, limit }) => {
  const parsedPage = Number(page);
  const parsedLimit = Number(limit);
  const safePage = Number.isInteger(parsedPage) && parsedPage > 0 ? parsedPage : 1;
  const safeLimit = Number.isInteger(parsedLimit) && parsedLimit > 0 ? Math.min(parsedLimit, 100) : 10;
  return { page: safePage, limit: safeLimit };
};

const buildPaginationMeta = ({ currentPage, limit, totalRecords }) => {
  const totalPages = Math.max(1, Math.ceil(totalRecords / limit));
  return {
    totalRecords,
    currentPage,
    nextPage: currentPage < totalPages ? currentPage + 1 : null,
    limit,
    totalPages,
    hasNext: currentPage < totalPages,
    hasPrev: currentPage > 1,
  };
};

export const createTemplate = async ({ coachId, payload }) => {
  if (!payload.name || !String(payload.name).trim()) {
    throw new Error('name is required.');
  }

  const template = await CourseTemplate.create({
    coach_id: coachId,
    name: payload.name,
    difficulty: payload.difficulty || null,
    obstacles: payload.obstacles || null,
    distances: payload.distances || null,
    arena_layout: payload.arena_layout || null,
    notes: payload.notes || null,
    layout_image_url: payload.layout_image_url || null,
    layout_drawing_data: payload.layout_drawing_data || null,
  });

  return template;
};

export const getMyTemplates = async ({ coachId, search, page, limit }) => {
  const { page: safePage, limit: safeLimit } = normalizePagination({ page, limit });
  const offset = (safePage - 1) * safeLimit;

  const where = { coach_id: coachId, is_active: true };
  if (search && String(search).trim()) {
    where.name = { [Op.like]: `%${String(search).trim()}%` };
  }

  const { rows, count } = await CourseTemplate.findAndCountAll({
    where,
    order: [['created_at', 'DESC']],
    offset,
    limit: safeLimit,
  });

  return {
    data: rows,
    pagination: buildPaginationMeta({
      currentPage: safePage,
      limit: safeLimit,
      totalRecords: count,
    }),
  };
};

export const getTemplateById = async ({ coachId, templateId }) => {
  const template = await CourseTemplate.findByPk(templateId);
  if (!template) {
    throw new Error('Template not found.');
  }
  if (Number(template.coach_id) !== Number(coachId)) {
    throw new Error('You are not allowed to access this template.');
  }
  return template;
};

export const updateTemplate = async ({ coachId, templateId, payload }) => {
  const template = await CourseTemplate.findByPk(templateId);
  if (!template) {
    throw new Error('Template not found.');
  }
  if (Number(template.coach_id) !== Number(coachId)) {
    throw new Error('You are not allowed to modify this template.');
  }

  const fields = [
    'name', 'difficulty', 'obstacles', 'distances',
    'arena_layout', 'notes', 'layout_image_url', 'layout_drawing_data',
  ];
  for (const field of fields) {
    if (payload[field] !== undefined) {
      template[field] = payload[field];
    }
  }

  template.updated_at = new Date();
  await template.save();
  return template;
};

export const deleteTemplate = async ({ coachId, templateId }) => {
  const template = await CourseTemplate.findByPk(templateId);
  if (!template) {
    throw new Error('Template not found.');
  }
  if (Number(template.coach_id) !== Number(coachId)) {
    throw new Error('You are not allowed to delete this template.');
  }

  template.is_active = false;
  template.updated_at = new Date();
  await template.save();
  return { message: 'Template deleted successfully.' };
};
