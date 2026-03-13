import { Op } from 'sequelize';
import { Horse, HorseAvailability, Stable } from '../models/index.js';

const ensureHorseOwnedByAdmin = async (adminId, horseId) => {
  const horse = await Horse.findByPk(horseId);
  if (!horse) {
    throw new Error('Horse not found.');
  }

  const stable = await Stable.findOne({
    where: {
      id: horse.stable_id,
      admin_id: adminId,
    },
  });

  if (!stable) {
    throw new Error('Horse not found or access denied.');
  }

  return horse;
};

export const getHorseAvailability = async ({ horseId, month }) => {
  if (!horseId) {
    throw new Error('horseId is required.');
  }

  const horse = await Horse.findByPk(horseId);
  if (!horse) {
    throw new Error('Horse not found.');
  }

  let dateFilter = {};
  if (month) {
    const monthRegex = /^\d{4}-\d{2}$/;
    if (!monthRegex.test(month)) {
      throw new Error('month must be in YYYY-MM format.');
    }
    const [year, mon] = month.split('-').map(Number);
    const startDate = `${month}-01`;
    const lastDay = new Date(year, mon, 0).getDate();
    const endDate = `${month}-${String(lastDay).padStart(2, '0')}`;
    dateFilter = { date: { [Op.between]: [startDate, endDate] } };
  }

  const availability = await HorseAvailability.findAll({
    where: {
      horse_id: horseId,
      ...dateFilter,
    },
    order: [['date', 'ASC']],
  });

  return {
    max_daily_sessions: horse.max_daily_sessions,
    availability,
  };
};

export const setHorseAvailability = async ({ adminId, horseId, date, maxSessionsPerDay, isAvailable }) => {
  if (!date) {
    throw new Error('date is required.');
  }

  await ensureHorseOwnedByAdmin(adminId, horseId);

  const [record] = await HorseAvailability.findOrCreate({
    where: { horse_id: horseId, date },
    defaults: {
      horse_id: horseId,
      date,
      max_sessions_per_day: maxSessionsPerDay ?? 3,
      is_available: isAvailable ?? true,
    },
  });

  if (maxSessionsPerDay !== undefined) {
    record.max_sessions_per_day = maxSessionsPerDay;
  }
  if (isAvailable !== undefined) {
    record.is_available = isAvailable;
  }
  record.updated_at = new Date();
  await record.save();

  return record;
};

export const blockHorseDates = async ({ adminId, horseId, dates, reason }) => {
  if (!dates || !Array.isArray(dates) || dates.length === 0) {
    throw new Error('dates array is required.');
  }

  await ensureHorseOwnedByAdmin(adminId, horseId);

  for (const date of dates) {
    const [record] = await HorseAvailability.findOrCreate({
      where: { horse_id: horseId, date },
      defaults: {
        horse_id: horseId,
        date,
        is_available: false,
      },
    });

    record.is_available = false;
    record.updated_at = new Date();
    await record.save();
  }

  return { blocked: dates.length, reason: reason || null };
};
