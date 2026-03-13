import {
  getHorseAvailability,
  setHorseAvailability,
  blockHorseDates,
} from '../services/horse-availability.service.js';

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

export const getHorseAvailabilityController = async (req, res) => {
  try {
    const data = await getHorseAvailability({
      horseId: req.params.id,
      month: req.query.month,
    });
    return res.status(200).json(data);
  } catch (error) {
    return handleError(res, error);
  }
};

export const setHorseAvailabilityController = async (req, res) => {
  try {
    const data = await setHorseAvailability({
      adminId: req.user.id,
      horseId: req.params.id,
      date: req.body.date,
      maxSessionsPerDay: req.body.max_sessions_per_day,
      isAvailable: req.body.is_available,
    });
    return res.status(200).json(data);
  } catch (error) {
    return handleError(res, error);
  }
};

export const blockHorseDatesController = async (req, res) => {
  try {
    const data = await blockHorseDates({
      adminId: req.user.id,
      horseId: req.params.id,
      dates: req.body.dates,
      reason: req.body.reason,
    });
    return res.status(200).json(data);
  } catch (error) {
    return handleError(res, error);
  }
};
