import { Router } from 'express';
import { authController } from './auth.controller';
import { authenticate } from './auth.middleware';

export const authRoutes = Router();

// Public routes
authRoutes.get('/google', authController.googleAuth);
authRoutes.get('/google/callback', authController.googleCallback);
authRoutes.get('/mobile/callback', authController.mobileCallback);
authRoutes.post('/logout', authController.logout);

// Protected routes
authRoutes.get('/me', authenticate, authController.getMe);
authRoutes.put('/fcm-token', authenticate, authController.updateFcmToken);
