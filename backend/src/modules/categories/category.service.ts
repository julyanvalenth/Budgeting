import { prisma } from '../../config/database';
import { z } from 'zod';

export const createCategorySchema = z.object({
  name: z.string().min(1).max(50),
  icon: z.string().min(1),
  color: z.string().regex(/^#[0-9A-Fa-f]{6}$/),
  type: z.enum(['DEBIT', 'CREDIT']),
  keywords: z.array(z.string()).default([]),
});

export const updateCategorySchema = createCategorySchema.partial();

export class CategoryService {
  async getAll(userId: string) {
    return prisma.category.findMany({
      where: {
        OR: [
          { userId },
          { userId: null, isDefault: true }, // default system categories
        ],
      },
      orderBy: [{ isDefault: 'desc' }, { name: 'asc' }],
    });
  }

  async create(userId: string, data: z.infer<typeof createCategorySchema>) {
    return prisma.category.create({
      data: { ...data, userId },
    });
  }

  async update(id: string, userId: string, data: z.infer<typeof updateCategorySchema>) {
    return prisma.category.update({
      where: { id, userId },
      data,
    });
  }

  async delete(id: string, userId: string) {
    return prisma.category.delete({
      where: { id, userId },
    });
  }
}

export const categoryService = new CategoryService();
