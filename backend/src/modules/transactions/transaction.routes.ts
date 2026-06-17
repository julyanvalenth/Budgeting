import { Router } from 'express';
import { transactionController } from './transaction.controller';
import { authenticate } from '../auth/auth.middleware';

export const transactionRoutes = Router();

transactionRoutes.use(authenticate);

transactionRoutes.get('/', transactionController.list);
transactionRoutes.get('/summary', transactionController.summary);
transactionRoutes.get('/:id', transactionController.getById);
transactionRoutes.post('/', transactionController.create);
transactionRoutes.put('/:id', transactionController.update);
transactionRoutes.delete('/:id', transactionController.remove);
