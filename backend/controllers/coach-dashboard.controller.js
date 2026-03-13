import {
  getCoachDashboard,
  getCoachEarnings,
} from '../services/coach-dashboard.service.js';

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

export const getCoachDashboardController = async (req, res) => {
  try {
    const data = await getCoachDashboard({
      coachId: req.user.id,
    });
    return res.status(200).json(data);
  } catch (error) {
    return handleError(res, error);
  }
};

export const getCoachEarningsController = async (req, res) => {
  try {
    const data = await getCoachEarnings({
      coachId: req.user.id,
      months: req.query.months,
    });
    return res.status(200).json(data);
  } catch (error) {
    return handleError(res, error);
  }
};
