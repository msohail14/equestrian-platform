import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const HorseAvailability = sequelize.define(
  'HorseAvailability',
  {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    horse_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: 'horses',
        key: 'id',
      },
    },
    date: {
      type: DataTypes.DATEONLY,
      allowNull: false,
    },
    max_sessions_per_day: {
      type: DataTypes.INTEGER,
      allowNull: false,
      defaultValue: 3,
    },
    sessions_booked: {
      type: DataTypes.INTEGER,
      allowNull: false,
      defaultValue: 0,
    },
    is_available: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
      defaultValue: true,
    },
    created_at: {
      type: DataTypes.DATE,
      allowNull: false,
      defaultValue: DataTypes.NOW,
    },
    updated_at: {
      type: DataTypes.DATE,
      allowNull: false,
      defaultValue: DataTypes.NOW,
    },
  },
  {
    tableName: 'horse_availability',
    timestamps: false,
  }
);

export default HorseAvailability;
