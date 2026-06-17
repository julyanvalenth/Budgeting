import { Request, Response, NextFunction } from 'express';
import { authService } from './auth.service';
import { UnauthorizedError } from '../../utils/errors';

export function authenticate(req: Request, _res: Response, next: NextFunction) {
  const authHeader = req.headers.authorization;

  if (!authHeader?.startsWith('Bearer ')) {
    return next(new UnauthorizedError('No token provided'));
  }

  const token = authHeader.split(' ')[1];

  try {
    const payload = authService.verifyJwt(token);
    req.userId = payload.userId;
    next();
  } catch (err) {
    next(new UnauthorizedError('Invalid or expired token'));
  }
}

export function optionalAuthenticate(req: Request, _res: Response, next: NextFunction) {
  const authHeader = req.headers.authorization;

  if (authHeader?.startsWith('Bearer ')) {
    try {
      const token = authHeader.split(' ')[1];
      const payload = authService.verifyJwt(token);
      req.userId = payload.userId;
    } catch {
      // Ignore invalid token for optional auth
    }
  }

  next();
}
