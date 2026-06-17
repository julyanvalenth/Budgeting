import { Request, Response, NextFunction } from 'express';
import { authService } from './auth.service';
import { sendSuccess, sendError } from '../../utils/response';

export class AuthController {
  // GET /api/auth/google — Redirect ke Google
  googleAuth = (_req: Request, res: Response) => {
    const url = authService.getAuthUrl();
    res.redirect(url);
  };

  // GET /api/auth/google/callback — Handle OAuth callback
  googleCallback = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const { code } = req.query;
      if (!code || typeof code !== 'string') {
        return sendError(res, 'Authorization code missing', 400);
      }

      const { user, token } = await authService.handleCallback(code);

      // Redirect ke app deep link (mobile) atau return JSON (web)
      const appRedirect = process.env.MOBILE_DEEP_LINK;
      if (appRedirect) {
        return res.redirect(`${appRedirect}?token=${token}`);
      }

      return sendSuccess(res, { user, token }, 'Login successful');
    } catch (err) {
      next(err);
    }
  };

  // GET /api/auth/me — Get current user
  getMe = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const user = await authService.getUserById(req.userId);
      return sendSuccess(res, user);
    } catch (err) {
      next(err);
    }
  };

  // PUT /api/auth/fcm-token — Update FCM token
  updateFcmToken = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const { fcmToken } = req.body;
      if (!fcmToken) return sendError(res, 'fcmToken is required', 400);
      await authService.updateFcmToken(req.userId, fcmToken);
      return sendSuccess(res, null, 'FCM token updated');
    } catch (err) {
      next(err);
    }
  };

  // GET /api/auth/mobile/callback?code=xxx — Exchange code dari deep link Flutter
  mobileCallback = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const { code } = req.query;
      if (!code || typeof code !== 'string') {
        return sendError(res, 'Authorization code missing', 400);
      }
      const { user, token } = await authService.handleCallback(code);
      return sendSuccess(res, { user, token }, 'Login successful');
    } catch (err) {
      next(err);
    }
  };

  // POST /api/auth/logout
  logout = async (_req: Request, res: Response) => {
    // JWT is stateless; client should discard token
    return sendSuccess(res, null, 'Logged out successfully');
  };
}

export const authController = new AuthController();
