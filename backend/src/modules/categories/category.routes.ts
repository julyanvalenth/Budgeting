import { Router } from 'express';
import { categoryController } from './category.controller';
import { authenticate } from '../auth/auth.middleware';

export const categoryRoutes = Router();

categoryRoutes.use(authenticate);

categoryRoutes.get('/', categoryController.list);
categoryRoutes.post('/', categoryController.create);
categoryRoutes.put('/:id', categoryController.update);
categoryRoutes.delete('/:id', categoryController.remove);
