import 'dotenv/config';
import app from './app';
import { logger } from './utils/logger';
import { prisma } from './config/database';

const PORT = parseInt(process.env.PORT || '3000', 10);

async function main() {
  try {
    // Test DB connection
    await prisma.$connect();
    logger.info('Database connected');

    app.listen(PORT, () => {
      logger.info(`BudgetMate server running on http://localhost:${PORT}`);
    });
  } catch (error) {
    logger.error('Failed to start server:', error);
    process.exit(1);
  }
}

main();

// Graceful shutdown
process.on('SIGINT', async () => {
  await prisma.$disconnect();
  logger.info('Server shut down gracefully');
  process.exit(0);
});
