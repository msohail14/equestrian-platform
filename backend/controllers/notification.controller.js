import {
  getAdminNotifications,
  getUserNotifications,
  markAllAsRead,
  markAsRead,
  getUnreadCount,
} from '../services/notification.service.js';

const handleError = (res, error) => {
  const isValidationError =
    error.message.includes('not found') ||
    error.message.includes('required') ||
    error.message.includes('exists');
  return res.status(isValidationError ? 400 : 500).json({
    message: error.message || 'Internal server error.',
  });
};

export const getNotificationsController = async (req, res) => {
  try {
    const data =
      req.user.type === 'admin'
        ? await getAdminNotifications({
            adminId: req.user.id,
            page: req.query.page,
            limit: req.query.limit,
          })
        : await getUserNotifications({
            userId: req.user.id,
            page: req.query.page,
            limit: req.query.limit,
          });
    return res.status(200).json(data);
  } catch (error) {
    return handleError(res, error);
  }
};

export const markAsReadController = async (req, res) => {
  try {
    const data = await markAsRead({
      notificationId: req.params.id,
      userId: req.user.id,
    });
    return res.status(200).json(data);
  } catch (error) {
    return handleError(res, error);
  }
};

export const markAllAsReadController = async (req, res) => {
  try {
    const data = await markAllAsRead({ userId: req.user.id });
    return res.status(200).json(data);
  } catch (error) {
    return handleError(res, error);
  }
};

export const getUnreadCountController = async (req, res) => {
  try {
    const data = await getUnreadCount({ userId: req.user.id });
    return res.status(200).json(data);
  } catch (error) {
    return handleError(res, error);
  }
};
