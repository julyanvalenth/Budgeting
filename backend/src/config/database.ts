import { PrismaClient } from '@prisma/client';
import { logger } from '../utils/logger';

declare global {
  // eslint-disable-next-line no-var
  var __prisma: PrismaClient | undefined;
}

// Prisma v5: gunakan $extends untuk middleware, bukan $use yang deprecated
const createPrismaClient = () =>
  new PrismaClient({
    log: process.env.NODE_ENV === 'development'
      ? ['error', 'warn']
      : ['error'],
  });

// Prevent multiple instances in development (hot reload)
export const prisma = global.__prisma ?? createPrismaClient();

if (process.env.NODE_ENV !== 'production') {
  global.__prisma = prisma;
}

// Log slow queries via event listener (Prisma v5 compatible)
if (process.env.NODE_ENV === 'development') {
  prisma.$on('error' as never, (e: unknown) => {
    logger.error('Prisma error:', e);
  });
}

export default prisma;
