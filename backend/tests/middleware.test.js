import { jest } from '@jest/globals';
import jwt from 'jsonwebtoken';

process.env.JWT_SECRET = 'test-secret-key-for-testing-only';

const createMockReqRes = (overrides = {}) => {
  const req = {
    headers: {},
    user: null,
    ...overrides,
  };
  const res = {
    statusCode: null,
    body: null,
    status(code) {
      this.statusCode = code;
      return this;
    },
    json(data) {
      this.body = data;
      return this;
    },
  };
  const next = jest.fn();
  return { req, res, next };
};

describe('Auth middleware logic', () => {
  const authMiddleware = (req, res, next) => {
    try {
      const authHeader = req.headers.authorization;
      if (!authHeader || !authHeader.startsWith('Bearer ')) {
        return res.status(401).json({ message: 'Authorization token is required.' });
      }
      const token = authHeader.split(' ')[1];
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      req.user = decoded;
      return next();
    } catch (error) {
      return res.status(401).json({ message: 'Invalid or expired token.' });
    }
  };

  test('rejects request without authorization header', () => {
    const { req, res, next } = createMockReqRes();
    authMiddleware(req, res, next);
    expect(res.statusCode).toBe(401);
    expect(next).not.toHaveBeenCalled();
  });

  test('rejects request with invalid token', () => {
    const { req, res, next } = createMockReqRes({
      headers: { authorization: 'Bearer invalid-token' },
    });
    authMiddleware(req, res, next);
    expect(res.statusCode).toBe(401);
    expect(next).not.toHaveBeenCalled();
  });

  test('passes valid token and sets req.user', () => {
    const token = jwt.sign({ id: 1, email: 'test@test.com', role: 'rider' }, process.env.JWT_SECRET);
    const { req, res, next } = createMockReqRes({
      headers: { authorization: `Bearer ${token}` },
    });
    authMiddleware(req, res, next);
    expect(next).toHaveBeenCalled();
    expect(req.user.id).toBe(1);
    expect(req.user.email).toBe('test@test.com');
  });
});

describe('Admin auth middleware logic', () => {
  const authMiddleware = (req, res, next) => {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ message: 'Authorization token is required.' });
    }
    const token = authHeader.split(' ')[1];
    try {
      req.user = jwt.verify(token, process.env.JWT_SECRET);
      return next();
    } catch {
      return res.status(401).json({ message: 'Invalid or expired token.' });
    }
  };

  const adminAuthMiddleware = (req, res, next) => {
    authMiddleware(req, res, () => {
      if (req.user?.type !== 'admin') {
        return res.status(403).json({ message: 'Admin access only.' });
      }
      return next();
    });
  };

  test('rejects non-admin user', () => {
    const token = jwt.sign({ id: 1, type: 'user' }, process.env.JWT_SECRET);
    const { req, res, next } = createMockReqRes({
      headers: { authorization: `Bearer ${token}` },
    });
    adminAuthMiddleware(req, res, next);
    expect(res.statusCode).toBe(403);
    expect(next).not.toHaveBeenCalled();
  });

  test('allows admin user', () => {
    const token = jwt.sign({ id: 1, type: 'admin' }, process.env.JWT_SECRET);
    const { req, res, next } = createMockReqRes({
      headers: { authorization: `Bearer ${token}` },
    });
    adminAuthMiddleware(req, res, next);
    expect(next).toHaveBeenCalled();
  });
});
