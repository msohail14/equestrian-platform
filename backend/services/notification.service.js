import { Notification } from '../models/index.js';
import { Op } from 'sequelize';

const normalizePagination = ({ page, limit }) => {
  const parsedPage = Number(page);
  const parsedLimit = Number(limit);
  const safePage = Number.isInteger(parsedPage) && parsedPage > 0 ? parsedPage : 1;
  const safeLimit =
    Number.isInteger(parsedLimit) && parsedLimit > 0 ? Math.min(parsedLimit, 100) : 10;
  return { page: safePage, limit: safeLimit };
};

const buildPaginationMeta = ({ page, limit, totalItems }) => {
  const totalPages = Math.max(1, Math.ceil(totalItems / limit));
  return {
    page,
    limit,
    totalItems,
    totalPages,
    hasNext: page < totalPages,
    hasPrev: page > 1,
  };
};

export const createNotification = async ({ userId, adminId, type, title, body, data }) => {
  if (!userId && !adminId) {
    throw new Error('At least one of userId or adminId is required.');
  }
  if (!type) {
    throw new Error('type is required.');
  }
  if (!title) {
    throw new Error('title is required.');
  }

  const notification = await Notification.create({
    user_id: userId || null,
    admin_id: adminId || null,
    type,
    title,
    body: body || null,
    data: data || null,
  });

  return notification;
};

export const getUserNotifications = async ({ userId, page, limit }) => {
  const pagination = normalizePagination({ page, limit });
  const offset = (pagination.page - 1) * pagination.limit;

  const { rows, count } = await Notification.findAndCountAll({
    where: { user_id: userId },
    order: [['created_at', 'DESC']],
    offset,
    limit: pagination.limit,
  });

  const meta = buildPaginationMeta({
    page: pagination.page,
    limit: pagination.limit,
    totalItems: count,
  });

  return {
    data: rows,
    pagination: {
      ...meta,
      totalRecords: meta.totalItems,
      currentPage: meta.page,
      nextPage: meta.hasNext ? meta.page + 1 : null,
    },
  };
};

export const getAdminNotifications = async ({ adminId, page, limit }) => {
  const pagination = normalizePagination({ page, limit });
  const offset = (pagination.page - 1) * pagination.limit;

  const { rows, count } = await Notification.findAndCountAll({
    where: { admin_id: adminId },
    order: [['created_at', 'DESC']],
    offset,
    limit: pagination.limit,
  });

  const meta = buildPaginationMeta({
    page: pagination.page,
    limit: pagination.limit,
    totalItems: count,
  });

  return {
    data: rows,
    pagination: {
      ...meta,
      totalRecords: meta.totalItems,
      currentPage: meta.page,
      nextPage: meta.hasNext ? meta.page + 1 : null,
    },
  };
};

export const markAsRead = async ({ notificationId, userId }) => {
  const notification = await Notification.findByPk(notificationId);
  if (!notification) {
    throw new Error('Notification not found.');
  }

  if (notification.user_id !== userId && notification.admin_id !== userId) {
    throw new Error('Notification not found.');
  }

  notification.is_read = true;
  await notification.save();

  return notification;
};

export const markAllAsRead = async ({ userId }) => {
  await Notification.update(
    { is_read: true },
    { where: { user_id: userId, is_read: false } }
  );

  return { message: 'All notifications marked as read.' };
};

export const getUnreadCount = async ({ userId }) => {
  const count = await Notification.count({
    where: { user_id: userId, is_read: false },
  });

  return { count };
};
