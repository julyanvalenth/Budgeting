import cron from 'node-cron';
import { prisma } from '../config/database';
import { GmailService } from '../modules/gmail/gmail.service';
import { logger } from '../utils/logger';

const gmailService = new GmailService();

export function startGmailSyncJob() {
  // Sinkronisasi setiap 15 menit
  cron.schedule('*/15 * * * *', async () => {
    logger.info('Starting scheduled Gmail sync for all users');

    const users = await prisma.user.findMany({
      select: { id: true, email: true },
    });

    logger.info(`Syncing ${users.length} users`);

    for (const user of users) {
      try {
        const syncLog = await prisma.syncLog.create({
          data: {
            userId: user.id,
            status: 'RUNNING',
          },
        });

        const result = await gmailService.syncTransactions(user.id);

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

        logger.info(
          `User ${user.email}: ${result.found} transactions from ${result.checked} emails`
        );
      } catch (err) {
        logger.error(`Sync failed for user ${user.email}:`, err);
        await prisma.syncLog.create({
          data: {
            userId: user.id,
            completedAt: new Date(),
            status: 'FAILED',
            errorMessage: (err as Error).message,
          },
        });
      }
    }
  });

  logger.info('Gmail sync job scheduled (every 15 minutes)');
}
