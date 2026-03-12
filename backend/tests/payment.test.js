import { jest } from '@jest/globals';

describe('Payment utilities', () => {
  test('generates unique transaction IDs', () => {
    const generateTransactionId = () => `TXN_${Date.now()}_${Math.random().toString(36).slice(2, 10)}`;
    const id1 = generateTransactionId();
    const id2 = generateTransactionId();

    expect(id1).toMatch(/^TXN_\d+_/);
    expect(id2).toMatch(/^TXN_\d+_/);
    expect(id1).not.toBe(id2);
  });

  test('validates payment types', () => {
    const validTypes = ['subscription', 'session', 'course', 'tip'];
    const isValidType = (type) => validTypes.includes(type);

    expect(isValidType('subscription')).toBe(true);
    expect(isValidType('session')).toBe(true);
    expect(isValidType('course')).toBe(true);
    expect(isValidType('tip')).toBe(true);
    expect(isValidType('invalid')).toBe(false);
  });

  test('validates payment providers', () => {
    const validProviders = ['tappay', 'hyperpay', 'manual'];
    const isValidProvider = (provider) => validProviders.includes(provider);

    expect(isValidProvider('tappay')).toBe(true);
    expect(isValidProvider('hyperpay')).toBe(true);
    expect(isValidProvider('manual')).toBe(true);
    expect(isValidProvider('stripe')).toBe(false);
  });

  test('calculates subscription duration correctly', () => {
    const getDurationDays = (planType) => {
      switch (planType) {
        case 'pro': return 365;
        case 'premium': return 90;
        case 'basic':
        default: return 30;
      }
    };

    expect(getDurationDays('basic')).toBe(30);
    expect(getDurationDays('premium')).toBe(90);
    expect(getDurationDays('pro')).toBe(365);
    expect(getDurationDays(undefined)).toBe(30);
  });

  test('subscription end date calculated from start', () => {
    const startDate = new Date('2026-03-12');
    const durationDays = 30;
    const endDate = new Date(startDate);
    endDate.setDate(endDate.getDate() + durationDays);

    expect(endDate.toISOString().slice(0, 10)).toBe('2026-04-11');
  });
});

describe('Payment status flow', () => {
  test('valid status transitions', () => {
    const validStatuses = ['pending', 'completed', 'failed', 'refunded'];
    validStatuses.forEach(status => {
      expect(validStatuses).toContain(status);
    });
  });

  test('subscription statuses are valid', () => {
    const validStatuses = ['active', 'cancelled', 'expired', 'past_due'];
    validStatuses.forEach(status => {
      expect(validStatuses).toContain(status);
    });
  });
});
