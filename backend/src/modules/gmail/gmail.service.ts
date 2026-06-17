import { google, gmail_v1 } from 'googleapis';
import { simpleParser } from 'mailparser';
import { prisma } from '../../config/database';
import { ParserService } from '../parser/parser.service';
import { decrypt } from '../../utils/crypto';
import { authService } from '../auth/auth.service';
import { GmailSyncResult } from './gmail.types';
import { logger } from '../../utils/logger';

export class GmailService {
  private parserService = new ParserService();

  // Buat authenticated Gmail client untuk user
  private async getGmailClient(userId: string): Promise<gmail_v1.Gmail> {
    const user = await prisma.user.findUniqueOrThrow({ where: { id: userId } });

    // Refresh token jika sudah expired
    if (user.tokenExpiry && user.tokenExpiry < new Date()) {
      await authService.refreshGoogleToken(userId);
    }

    const client = new google.auth.OAuth2(
      process.env.GOOGLE_CLIENT_ID,
      process.env.GOOGLE_CLIENT_SECRET,
    );

    const freshUser = await prisma.user.findUniqueOrThrow({ where: { id: userId } });
    client.setCredentials({
      access_token: decrypt(freshUser.accessToken),
      refresh_token: decrypt(freshUser.refreshToken),
    });

    return google.gmail({ version: 'v1', auth: client });
  }

  // Sync email transaksi dari Gmail
  async syncTransactions(userId: string): Promise<GmailSyncResult> {
    const gmail = await this.getGmailClient(userId);
    const user = await prisma.user.findUniqueOrThrow({ where: { id: userId } });

    // Gunakan lastSyncAt untuk hanya ambil email baru (default: 7 hari)
    const afterDate = user.lastSyncAt
      ? Math.floor(user.lastSyncAt.getTime() / 1000)
      : Math.floor(Date.now() / 1000) - 7 * 24 * 60 * 60;

    const query = this.buildGmailQuery(afterDate);

    const listResponse = await gmail.users.messages.list({
      userId: 'me',
      q: query,
      maxResults: 100,
    });

    const messages = listResponse.data.messages || [];
    let found = 0;
    const errors: string[] = [];

    for (const message of messages) {
      try {
        // Cek apakah email ini sudah pernah diproses
        const existing = await prisma.transaction.findUnique({
          where: { gmailMessageId: message.id! },
        });
        if (existing) continue;

        // Ambil konten lengkap email
        const fullMessage = await gmail.users.messages.get({
          userId: 'me',
          id: message.id!,
          format: 'raw',
        });

        const rawEmail = Buffer.from(fullMessage.data.raw!, 'base64url').toString();
        const parsed = await simpleParser(rawEmail);

        // Parse transaksi dari konten email
        const transaction = await this.parserService.parse({
          messageId: message.id!,
          subject: parsed.subject || '',
          from: parsed.from?.text || '',
          date: parsed.date || new Date(),
          textBody: parsed.text || '',
          htmlBody: (parsed.html as string) || '',
        });

        if (transaction) {
          await prisma.transaction.create({
            data: {
              ...transaction,
              userId,
              gmailMessageId: message.id,
              amount: transaction.amount,
            },
          });
          found++;
        }
      } catch (err) {
        errors.push(`Message ${message.id}: ${(err as Error).message}`);
        logger.error(`Error processing email ${message.id}:`, err);
      }
    }

    // Update lastSyncAt
    await prisma.user.update({
      where: { id: userId },
      data: { lastSyncAt: new Date() },
    });

    return { checked: messages.length, found, errors };
  }

  // Query Gmail untuk mencari email dari bank/e-wallet Indonesia
  private buildGmailQuery(afterTimestamp: number): string {
    const senders = [
      // Bank
      'info@bca.co.id', 'notifikasi@bni.co.id',
      'mandiri@bankmandiri.co.id', 'bri@bri.co.id',
      // E-wallet
      'no-reply@gopay.co.id', 'no-reply@ovo.id',
      'no-reply@dana.id', 'notification@shopee.co.id',
      // E-commerce
      'noreply@tokopedia.com',
      // International
      'service@paypal.com',
    ];

    const fromQuery = senders.map((s) => `from:${s}`).join(' OR ');
    return `(${fromQuery}) after:${afterTimestamp}`;
  }

  async getLastSyncStatus(userId: string) {
    return prisma.syncLog.findFirst({
      where: { userId },
      orderBy: { startedAt: 'desc' },
    });
  }

  async getSyncLogs(userId: string, limit = 10) {
    return prisma.syncLog.findMany({
      where: { userId },
      orderBy: { startedAt: 'desc' },
      take: limit,
    });
  }
}

export const gmailService = new GmailService();
