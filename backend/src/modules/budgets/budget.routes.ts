import { Router } from 'express';
import { budgetController } from './budget.controller';
import { authenticate } from '../auth/auth.middleware';

export const budgetRoutes = Router();

budgetRoutes.use(authenticate);

budgetRoutes.get('/', budgetController.list);
budgetRoutes.get('/progress', budgetController.getProgress);
budgetRoutes.post('/', budgetController.create);
budgetRoutes.put('/:id', budgetController.update);
budgetRoutes.delete('/:id', budgetController.remove);
