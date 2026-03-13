import {
  getStableDashboardOverview,
  getArenaSchedule,
  getStableRevenue,
  getHorseUtilization,
} from '../services/stable-dashboard.service.js';

const handleError = (res, error) => {
  const isValidationError =
    error.message.includes('required') ||
    error.message.includes('not found') ||
    error.message.includes('access denied') ||
    error.message.includes('must be');

  return res.status(isValidationError ? 400 : 500).json({
    message: error.message || 'Internal server error.',
  });
};

export const getStableDashboardOverviewController = async (req, res) => {
  try {
    const data = await getStableDashboardOverview({
      adminId: req.user.id,
    });
    return res.status(200).json(data);
  } catch (error) {
    return handleError(res, error);
  }
};

export const getArenaScheduleController = async (req, res) => {
  try {
    const data = await getArenaSchedule({
      adminId: req.user.id,
      stableId: req.query.stable_id,
      startDate: req.query.start_date,
      endDate: req.query.end_date,
    });
    return res.status(200).json(data);
  } catch (error) {
    return handleError(res, error);
  }
};

export const getStableRevenueController = async (req, res) => {
  try {
    const data = await getStableRevenue({
      adminId: req.user.id,
      stableId: req.query.stable_id,
      months: req.query.months,
    });
    return res.status(200).json(data);
  } catch (error) {
    return handleError(res, error);
  }
};

export const getHorseUtilizationController = async (req, res) => {
  try {
    const data = await getHorseUtilization({
      adminId: req.user.id,
      stableId: req.query.stable_id,
    });
    return res.status(200).json(data);
  } catch (error) {
    return handleError(res, error);
  }
};
