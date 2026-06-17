import { Router } from 'express';
import { gmailController } from './gmail.controller';
import { authenticate } from '../auth/auth.middleware';

export const gmailRoutes = Router();

gmailRoutes.use(authenticate);

gmailRoutes.post('/sync', gmailController.sync);
gmailRoutes.get('/sync/status', gmailController.getSyncStatus);
gmailRoutes.get('/sync/logs', gmailController.getSyncLogs);
