import { Request, Response, NextFunction } from 'express';
import {
  categoryService,
  createCategorySchema,
  updateCategorySchema,
} from './category.service';
import { sendSuccess } from '../../utils/response';

export class CategoryController {
  list = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const categories = await categoryService.getAll(req.userId);
      return sendSuccess(res, categories);
    } catch (err) { next(err); }
  };

  create = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const data = createCategorySchema.parse(req.body);
      const category = await categoryService.create(req.userId, data);
      return sendSuccess(res, category, 'Category created', 201);
    } catch (err) { next(err); }
  };

  update = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const data = updateCategorySchema.parse(req.body);
      const category = await categoryService.update(req.params.id, req.userId, data);
      return sendSuccess(res, category, 'Category updated');
    } catch (err) { next(err); }
  };

  remove = async (req: Request, res: Response, next: NextFunction) => {
    try {
      await categoryService.delete(req.params.id, req.userId);
      return sendSuccess(res, null, 'Category deleted');
    } catch (err) { next(err); }
  };
}

export const categoryController = new CategoryController();
