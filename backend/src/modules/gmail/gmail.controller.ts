import { Request, Response, NextFunction } from 'express';
import { gmailService } from './gmail.service';
import { prisma } from '../../config/database';
import { sendSuccess, sendError } from '../../utils/response';
import { logger } from '../../utils/logger';

export class GmailController {
  // POST /api/gmail/sync — Trigger sync manual
  sync = async (req: Request, res: Response, next: NextFunction) => {
    try {
      // Buat sync log entry
      const syncLog = await prisma.syncLog.create({
        data: {
          userId: req.userId,
          status: 'RUNNING',
        },
      });

      // Run sync (async, update log setelah selesai)
      (async () => {
        try {
          const result = await gmailService.syncTransactions(req.userId);
          await prisma.syncLog.update({
            where: { id: syncLog.id },
            data: {
              completedAt: new Date(),
              emailsChecked: result.checked,
              transactionFound: result.found,
              status: result.errors.length === 0 ? 'SUCCESS' : 'PARTIAL',
              errorMessage: result.errors.join('; ') || null,
            },
          });
        } catch (err) {
          await prisma.syncLog.update({
            where: { id: syncLog.id },
            data: {
              completedAt: new Date(),
              status: 'FAILED',
              errorMessage: (err as Error).message,
            },
          }).catch((updateErr) => logger.error('Failed to update sync log:', updateErr));
        }
      })();

      return sendSuccess(res, { syncLogId: syncLog.id }, 'Gmail sync started');
    } catch (err) {
      next(err);
    }
  };

  // GET /api/gmail/sync/status — Status sync terakhir
  getSyncStatus = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const status = await gmailService.getLastSyncStatus(req.userId);
      return sendSuccess(res, status);
    } catch (err) {
      next(err);
    }
  };

  // GET /api/gmail/sync/logs — Riwayat sync
  getSyncLogs = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const limit = parseInt(req.query.limit as string) || 10;
      const logs = await gmailService.getSyncLogs(req.userId, limit);
      return sendSuccess(res, logs);
    } catch (err) {
      next(err);
    }
  };
}

export const gmailController = new GmailController();
