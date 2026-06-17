import { Request, Response, NextFunction } from 'express';
import { budgetService, createBudgetSchema, updateBudgetSchema } from './budget.service';
import { sendSuccess } from '../../utils/response';

export class BudgetController {
  list = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const budgets = await budgetService.getAll(req.userId);
      return sendSuccess(res, budgets);
    } catch (err) { next(err); }
  };

  getProgress = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const progress = await budgetService.getProgress(req.userId);
      return sendSuccess(res, progress);
    } catch (err) { next(err); }
  };

  create = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const data = createBudgetSchema.parse(req.body);
      const budget = await budgetService.create(req.userId, data);
      return sendSuccess(res, budget, 'Budget created', 201);
    } catch (err) { next(err); }
  };

  update = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const data = updateBudgetSchema.parse(req.body);
      const budget = await budgetService.update(req.params.id, req.userId, data);
      return sendSuccess(res, budget, 'Budget updated');
    } catch (err) { next(err); }
  };

  remove = async (req: Request, res: Response, next: NextFunction) => {
    try {
      await budgetService.delete(req.params.id, req.userId);
      return sendSuccess(res, null, 'Budget deleted');
    } catch (err) { next(err); }
  };
}

export const budgetController = new BudgetController();
