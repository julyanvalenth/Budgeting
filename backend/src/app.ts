import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import { authRoutes } from './modules/auth/auth.routes';
import { transactionRoutes } from './modules/transactions/transaction.routes';
import { gmailRoutes } from './modules/gmail/gmail.routes';
import { budgetRoutes } from './modules/budgets/budget.routes';
import { reportRoutes } from './modules/reports/report.routes';
import { categoryRoutes } from './modules/categories/category.routes';
import { errorHandler } from './utils/errors';
import { startGmailSyncJob } from './jobs/sync-gmail.job';
import { logger } from './utils/logger';

const app = express();

app.use(helmet());
app.use(cors({
  origin: process.env.ALLOWED_ORIGINS?.split(',') || ['http://localhost:3000'],
  credentials: true,
}));
app.use(express.json());

// Health check
app.get('/health', (_req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/transactions', transactionRoutes);
app.use('/api/gmail', gmailRoutes);
app.use('/api/budgets', budgetRoutes);
app.use('/api/reports', reportRoutes);
app.use('/api/categories', categoryRoutes);

// Error handler (must be last)
app.use(errorHandler);

// Start cron job
startGmailSyncJob();

logger.info('BudgetMate backend initialized');

export default app;
