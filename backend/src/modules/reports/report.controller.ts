import { Request, Response, NextFunction } from 'express';
import { reportService } from './report.service';
import { sendSuccess, sendError } from '../../utils/response';

export class ReportController {
  monthly = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const now = new Date();
      const year = parseInt(req.query.year as string) || now.getFullYear();
      const month = parseInt(req.query.month as string) || now.getMonth() + 1;
      const data = await reportService.getMonthlyReport(req.userId, year, month);
      return sendSuccess(res, data);
    } catch (err) { next(err); }
  };

  categoryBreakdown = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const now = new Date();
      const startDate = req.query.startDate
        ? new Date(req.query.startDate as string)
        : new Date(now.getFullYear(), now.getMonth(), 1);
      const endDate = req.query.endDate
        ? new Date(req.query.endDate as string)
        : now;
      const data = await reportService.getCategoryBreakdown(req.userId, startDate, endDate);
      return sendSuccess(res, data);
    } catch (err) { next(err); }
  };

  trend = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const months = parseInt(req.query.months as string) || 6;
      const data = await reportService.getMonthlyTrend(req.userId, months);
      return sendSuccess(res, data);
    } catch (err) { next(err); }
  };
}

export const reportController = new ReportController();
