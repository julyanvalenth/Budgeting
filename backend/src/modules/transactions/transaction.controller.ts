import { Request, Response, NextFunction } from 'express';
import {
  transactionService,
  transactionFiltersSchema,
  createTransactionSchema,
  updateTransactionSchema,
} from './transaction.service';
import { sendSuccess, sendError } from '../../utils/response';
import { NotFoundError } from '../../utils/errors';

export class TransactionController {
  // GET /api/transactions
  list = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const filters = transactionFiltersSchema.parse(req.query);
      const result = await transactionService.getTransactions(req.userId, filters);
      return sendSuccess(res, result.data, undefined, 200, result.pagination);
    } catch (err) {
      next(err);
    }
  };

  // GET /api/transactions/summary
  summary = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const now = new Date();
      const startDate = req.query.startDate
        ? new Date(req.query.startDate as string)
        : new Date(now.getFullYear(), now.getMonth(), 1);
      const endDate = req.query.endDate
        ? new Date(req.query.endDate as string)
        : now;

      const data = await transactionService.getSummary(req.userId, startDate, endDate);
      return sendSuccess(res, data);
    } catch (err) {
      next(err);
    }
  };

  // GET /api/transactions/:id
  getById = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const transaction = await transactionService.getById(req.params.id, req.userId);
      if (!transaction) throw new NotFoundError('Transaction');
      return sendSuccess(res, transaction);
    } catch (err) {
      next(err);
    }
  };

  // POST /api/transactions
  create = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const data = createTransactionSchema.parse(req.body);
      const transaction = await transactionService.create(req.userId, data);
      return sendSuccess(res, transaction, 'Transaction created', 201);
    } catch (err) {
      next(err);
    }
  };

  // PUT /api/transactions/:id
  update = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const data = updateTransactionSchema.parse(req.body);
      const transaction = await transactionService.update(req.params.id, req.userId, data);
      return sendSuccess(res, transaction, 'Transaction updated');
    } catch (err) {
      next(err);
    }
  };

  // DELETE /api/transactions/:id
  remove = async (req: Request, res: Response, next: NextFunction) => {
    try {
      await transactionService.delete(req.params.id, req.userId);
      return sendSuccess(res, null, 'Transaction deleted');
    } catch (err) {
      next(err);
    }
  };
}

export const transactionController = new TransactionController();
