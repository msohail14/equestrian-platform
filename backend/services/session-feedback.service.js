import { SessionFeedback, CourseSession, User, Course } from '../models/index.js';

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

export const createFeedback = async ({ sessionId, coachId, riderId, feedbackText, performanceRating, areasToImprove }) => {
  const session = await CourseSession.findByPk(sessionId);
  if (!session) {
    throw new Error('Session not found.');
  }
  if (Number(session.coach_id) !== Number(coachId)) {
    throw new Error('You are not allowed to provide feedback for this session.');
  }

  const existing = await SessionFeedback.findOne({
    where: { session_id: sessionId },
  });
  if (existing) {
    throw new Error('Feedback already exists for this session.');
  }

  const feedback = await SessionFeedback.create({
    session_id: sessionId,
    coach_id: coachId,
    rider_id: riderId,
    feedback_text: feedbackText || null,
    performance_rating: performanceRating || null,
    areas_to_improve: areasToImprove || null,
  });

  return feedback;
};

export const getSessionFeedback = async ({ sessionId }) => {
  const feedback = await SessionFeedback.findOne({
    where: { session_id: sessionId },
    include: [
      {
        model: User,
        as: 'coach',
        attributes: ['id', 'first_name', 'last_name', 'profile_picture_url'],
      },
      {
        model: User,
        as: 'rider',
        attributes: ['id', 'first_name', 'last_name', 'profile_picture_url'],
      },
    ],
  });

  if (!feedback) {
    throw new Error('Feedback not found for this session.');
  }

  return feedback;
};

export const getRiderPerformance = async ({ riderId, page, limit }) => {
  const { page: safePage, limit: safeLimit } = normalizePagination({ page, limit });
  const offset = (safePage - 1) * safeLimit;

  const { rows, count } = await SessionFeedback.findAndCountAll({
    where: { rider_id: riderId },
    include: [
      {
        model: CourseSession,
        as: 'session',
        include: [
          {
            model: Course,
            as: 'course',
            attributes: ['id', 'title'],
          },
        ],
      },
      {
        model: User,
        as: 'coach',
        attributes: ['id', 'first_name', 'last_name', 'profile_picture_url'],
      },
    ],
    order: [['created_at', 'DESC']],
    offset,
    limit: safeLimit,
    distinct: true,
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
