import { prisma } from '../../config/database';
import { z } from 'zod';

export const createBudgetSchema = z.object({
  categoryId: z.string(),
  amount: z.number().positive(),
  currency: z.string().default('IDR'),
  period: z.enum(['WEEKLY', 'MONTHLY', 'YEARLY']),
  startDate: z.string().datetime(),
  endDate: z.string().datetime(),
});

export const updateBudgetSchema = createBudgetSchema.partial();

export class BudgetService {
  async getAll(userId: string) {
    const budgets = await prisma.budget.findMany({
      where: { userId },
      include: { category: true },
      orderBy: { createdAt: 'desc' },
    });
    return budgets;
  }

  async getProgress(userId: string) {
    const now = new Date();
    const budgets = await prisma.budget.findMany({
      where: {
        userId,
        startDate: { lte: now },
        endDate: { gte: now },
      },
      include: { category: true },
    });

    const progress = await Promise.all(
      budgets.map(async (budget) => {
        const spent = await prisma.transaction.aggregate({
          where: {
            userId,
            categoryId: budget.categoryId,
            type: 'DEBIT',
            transactionDate: {
              gte: budget.startDate,
              lte: budget.endDate,
            },
          },
          _sum: { amount: true },
        });

        const spentAmount = Number(spent._sum.amount ?? 0);
        const budgetAmount = Number(budget.amount);

        return {
          ...budget,
          spent: spentAmount,
          remaining: budgetAmount - spentAmount,
          percentage: budgetAmount > 0
            ? Math.min((spentAmount / budgetAmount) * 100, 100)
            : 0,
        };
      })
    );

    return progress;
  }

  async create(userId: string, data: z.infer<typeof createBudgetSchema>) {
    return prisma.budget.create({
      data: {
        ...data,
        userId,
        startDate: new Date(data.startDate),
        endDate: new Date(data.endDate),
      },
      include: { category: true },
    });
  }

  async update(id: string, userId: string, data: z.infer<typeof updateBudgetSchema>) {
    return prisma.budget.update({
      where: { id, userId },
      data: {
        ...data,
        ...(data.startDate && { startDate: new Date(data.startDate) }),
        ...(data.endDate && { endDate: new Date(data.endDate) }),
      },
      include: { category: true },
    });
  }

  async delete(id: string, userId: string) {
    return prisma.budget.delete({ where: { id, userId } });
  }
}

export const budgetService = new BudgetService();
