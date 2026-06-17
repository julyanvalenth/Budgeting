import { Router } from 'express';
import { reportController } from './report.controller';
import { authenticate } from '../auth/auth.middleware';

export const reportRoutes = Router();

reportRoutes.use(authenticate);

reportRoutes.get('/monthly', reportController.monthly);
reportRoutes.get('/category', reportController.categoryBreakdown);
reportRoutes.get('/trend', reportController.trend);
