import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const PlatformSetting = sequelize.define(
  'PlatformSetting',
  {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    key: {
      type: DataTypes.STRING(100),
      allowNull: false,
      unique: true,
    },
    value: {
      type: DataTypes.JSON,
      allowNull: true,
    },
    updated_at: {
      type: DataTypes.DATE,
      allowNull: false,
      defaultValue: DataTypes.NOW,
    },
  },
  {
    tableName: 'platform_settings',
    timestamps: false,
  }
);

export default PlatformSetting;
