import { prisma } from '../../config/database';
import { Prisma } from '@prisma/client';
import { z } from 'zod';

export const transactionFiltersSchema = z.object({
  startDate: z.string().datetime().optional(),
  endDate: z.string().datetime().optional(),
  categoryId: z.string().optional(),
  type: z.enum(['DEBIT', 'CREDIT']).optional(),
  source: z.string().optional(),
  page: z.coerce.number().int().positive().default(1),
  limit: z.coerce.number().int().positive().max(100).default(20),
});

export const createTransactionSchema = z.object({
  amount: z.number().positive(),
  currency: z.string().default('IDR'),
  type: z.enum(['DEBIT', 'CREDIT']),
  description: z.string().min(1),
  merchant: z.string().optional(),
  categoryId: z.string().optional(),
  source: z.string().default('MANUAL'),
  transactionDate: z.string().datetime(),
  referenceNumber: z.string().optional(),
});

export const updateTransactionSchema = z.object({
  categoryId: z.string().optional(),
  description: z.string().optional(),
  merchant: z.string().optional(),
});

export class TransactionService {
  async getTransactions(
    userId: string,
    filters: z.infer<typeof transactionFiltersSchema>
  ) {
    const { page, limit, startDate, endDate, categoryId, type, source } = filters;

    const whereClause: Prisma.TransactionWhereInput = {
      userId,
      ...(startDate && { transactionDate: { gte: new Date(startDate) } }),
      ...(endDate && { transactionDate: { lte: new Date(endDate) } }),
      ...(categoryId && { categoryId }),
      ...(type && { type }),
      ...(source && { source }),
    };

    const [total, transactions] = await prisma.$transaction([
      prisma.transaction.count({ where: whereClause }),
      prisma.transaction.findMany({
        where: whereClause,
        include: { category: true },
        orderBy: { transactionDate: 'desc' },
        skip: (page - 1) * limit,
        take: limit,
      }),
    ]);

    return {
      data: transactions,
      pagination: { page, limit, total, totalPages: Math.ceil(total / limit) },
    };
  }

  async getById(id: string, userId: string) {
    return prisma.transaction.findFirst({
      where: { id, userId },
      include: { category: true },
    });
  }

  async getSummary(userId: string, startDate: Date, endDate: Date) {
    const where = { userId, transactionDate: { gte: startDate, lte: endDate } };

    const [debitAgg, creditAgg, byCategory] = await prisma.$transaction([
      prisma.transaction.aggregate({
        where: { ...where, type: 'DEBIT' },
        _sum: { amount: true },
        _count: { id: true },
      }),
      prisma.transaction.aggregate({
        where: { ...where, type: 'CREDIT' },
        _sum: { amount: true },
        _count: { id: true },
      }),
      prisma.transaction.groupBy({
        by: ['categoryId'],
        where: {
          userId,
          transactionDate: { gte: startDate, lte: endDate },
          type: 'DEBIT',
          categoryId: { not: null },
        },
        _sum: { amount: true },
        orderBy: { _sum: { amount: 'desc' } },
        take: 5,
      }),
    ]);

    return {
      totalDebit: Number(debitAgg._sum.amount ?? 0),
      totalCredit: Number(creditAgg._sum.amount ?? 0),
      transactionCount: (debitAgg._count.id ?? 0) + (creditAgg._count.id ?? 0),
      topCategories: byCategory,
    };
  }

  async create(userId: string, data: z.infer<typeof createTransactionSchema>) {
    return prisma.transaction.create({
      data: {
        ...data,
        userId,
        isManual: true,
        isParsed: false,
        transactionDate: new Date(data.transactionDate),
      },
      include: { category: true },
    });
  }

  async update(
    id: string,
    userId: string,
    data: z.infer<typeof updateTransactionSchema>
  ) {
    return prisma.transaction.update({
      where: { id, userId },
      data,
      include: { category: true },
    });
  }

  async delete(id: string, userId: string) {
    return prisma.transaction.delete({
      where: { id, userId },
    });
  }
}

export const transactionService = new TransactionService();
