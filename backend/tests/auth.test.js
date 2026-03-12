import { jest } from '@jest/globals';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';

process.env.JWT_SECRET = 'test-secret-key-for-testing-only';
process.env.JWT_EXPIRES_IN = '1h';
process.env.EMAIL_OTP_EXPIRES_MINUTES = '10';

describe('Auth utilities', () => {
  test('bcrypt hashes and verifies passwords correctly', async () => {
    const password = 'TestPassword123!';
    const hash = await bcrypt.hash(password, 10);
    expect(hash).not.toBe(password);
    expect(await bcrypt.compare(password, hash)).toBe(true);
    expect(await bcrypt.compare('wrongpassword', hash)).toBe(false);
  });

  test('JWT signs and verifies tokens correctly', () => {
    const payload = { id: 1, email: 'test@test.com', role: 'rider' };
    const token = jwt.sign(payload, process.env.JWT_SECRET, { expiresIn: '1h' });
    expect(token).toBeDefined();

    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    expect(decoded.id).toBe(1);
    expect(decoded.email).toBe('test@test.com');
    expect(decoded.role).toBe('rider');
  });

  test('JWT verification fails with wrong secret', () => {
    const payload = { id: 1 };
    const token = jwt.sign(payload, process.env.JWT_SECRET, { expiresIn: '1h' });
    expect(() => jwt.verify(token, 'wrong-secret')).toThrow();
  });

  test('JWT token expires as configured', () => {
    const payload = { id: 1 };
    const token = jwt.sign(payload, process.env.JWT_SECRET, { expiresIn: '0s' });
    expect(() => jwt.verify(token, process.env.JWT_SECRET)).toThrow(/expired/);
  });
});

describe('OTP generation', () => {
  test('generates 6-digit OTP', () => {
    const generateOtp = () => String(Math.floor(100000 + Math.random() * 900000));
    const otp = generateOtp();
    expect(otp).toHaveLength(6);
    expect(Number(otp)).toBeGreaterThanOrEqual(100000);
    expect(Number(otp)).toBeLessThan(1000000);
  });
});

describe('Password strength validation', () => {
  test('password with less than 6 chars is weak', () => {
    const isStrong = (pw) => pw.length >= 6;
    expect(isStrong('abc')).toBe(false);
    expect(isStrong('abcdef')).toBe(true);
  });
});

describe('Gender normalization', () => {
  const allowedGenders = ['male', 'female', 'other', 'prefer_not_to_say'];
  const normalizeGender = (value) => {
    if (value === undefined || value === null || value === '') return null;
    const normalized = String(value).trim().toLowerCase();
    if (!allowedGenders.includes(normalized)) {
      throw new Error(`gender must be one of: ${allowedGenders.join(', ')}.`);
    }
    return normalized;
  };

  test('normalizes valid genders', () => {
    expect(normalizeGender('Male')).toBe('male');
    expect(normalizeGender('FEMALE')).toBe('female');
    expect(normalizeGender('Other')).toBe('other');
  });

  test('returns null for empty values', () => {
    expect(normalizeGender(null)).toBeNull();
    expect(normalizeGender(undefined)).toBeNull();
    expect(normalizeGender('')).toBeNull();
  });

  test('throws for invalid genders', () => {
    expect(() => normalizeGender('invalid')).toThrow('gender must be one of');
  });
});
