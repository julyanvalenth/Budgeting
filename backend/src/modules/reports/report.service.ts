import { prisma } from '../../config/database';

export class ReportService {
  async getMonthlyReport(userId: string, year: number, month: number) {
    const startDate = new Date(year, month - 1, 1);
    const endDate = new Date(year, month, 0, 23, 59, 59);
    const where = { userId, transactionDate: { gte: startDate, lte: endDate } };

    const [debitAgg, creditAgg, transactions] = await prisma.$transaction([
      prisma.transaction.aggregate({
        where: { ...where, type: 'DEBIT' },
        _sum: { amount: true },
      }),
      prisma.transaction.aggregate({
        where: { ...where, type: 'CREDIT' },
        _sum: { amount: true },
      }),
      prisma.transaction.findMany({
        where,
        include: { category: true },
        orderBy: { transactionDate: 'asc' },
      }),
    ]);

    const totalDebit = Number(debitAgg._sum.amount ?? 0);
    const totalCredit = Number(creditAgg._sum.amount ?? 0);

    return {
      period: { year, month, startDate, endDate },
      totalDebit,
      totalCredit,
      net: totalCredit - totalDebit,
      transactionCount: transactions.length,
      transactions,
    };
  }

  async getCategoryBreakdown(userId: string, startDate: Date, endDate: Date) {
    const data = await prisma.transaction.groupBy({
      by: ['categoryId'],
      where: {
        userId,
        type: 'DEBIT',
        transactionDate: { gte: startDate, lte: endDate },
      },
      _sum: { amount: true },
      _count: true,
      orderBy: { _sum: { amount: 'desc' } },
    });

    // Resolve category names
    const withCategories = await Promise.all(
      data.map(async (item) => {
        const category = item.categoryId
          ? await prisma.category.findUnique({ where: { id: item.categoryId } })
          : null;
        return {
          category,
          total: Number(item._sum.amount ?? 0),
          count: item._count,
        };
      })
    );

    return withCategories;
  }

  async getMonthlyTrend(userId: string, months = 6) {
    const results = [];
    const now = new Date();

    for (let i = months - 1; i >= 0; i--) {
      const date = new Date(now.getFullYear(), now.getMonth() - i, 1);
      const startDate = new Date(date.getFullYear(), date.getMonth(), 1);
      const endDate = new Date(date.getFullYear(), date.getMonth() + 1, 0, 23, 59, 59);

      const summary = await prisma.transaction.groupBy({
        by: ['type'],
        where: { userId, transactionDate: { gte: startDate, lte: endDate } },
        _sum: { amount: true },
        orderBy: { type: 'asc' },
      });

      const debit = summary.find((s) => s.type === 'DEBIT');
      const credit = summary.find((s) => s.type === 'CREDIT');

      results.push({
        year: date.getFullYear(),
        month: date.getMonth() + 1,
        label: date.toLocaleString('id-ID', { month: 'short', year: '2-digit' }),
        totalDebit: Number(debit?._sum.amount ?? 0),
        totalCredit: Number(credit?._sum.amount ?? 0),
      });
    }

    return results;
  }
}

export const reportService = new ReportService();
