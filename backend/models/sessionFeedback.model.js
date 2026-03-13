import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const SessionFeedback = sequelize.define(
  'SessionFeedback',
  {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    session_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: 'course_sessions',
        key: 'id',
      },
    },
    coach_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: 'user',
        key: 'id',
      },
    },
    rider_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: 'user',
        key: 'id',
      },
    },
    feedback_text: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    performance_rating: {
      type: DataTypes.TINYINT.UNSIGNED,
      allowNull: true,
      validate: {
        min: 1,
        max: 5,
      },
    },
    areas_to_improve: {
      type: DataTypes.JSON,
      allowNull: true,
    },
    created_at: {
      type: DataTypes.DATE,
      allowNull: false,
      defaultValue: DataTypes.NOW,
    },
  },
  {
    tableName: 'session_feedback',
    timestamps: false,
  }
);

export default SessionFeedback;
