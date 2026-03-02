import { Request, Response } from 'express';
import { db } from '../db';
import { categories } from '../db/schema';
import { eq, and } from 'drizzle-orm';

export const getCategories = async (req: Request, res: Response) => {
  try {
    const userId = (req as any).userId;
    const result = await db.select().from(categories).where(eq(categories.userId, userId));
    res.json(result);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch categories' });
  }
};

export const createCategory = async (req: Request, res: Response) => {
  try {
    const userId = (req as any).userId;
    const { name, icon, color } = req.body;
    const [category] = await db.insert(categories).values({
      userId, name,
      icon: icon || '⚔️',
      color: color || '#4f46e5',
    }).returning();
    res.status(201).json(category);
  } catch (error) {
    res.status(500).json({ error: 'Failed to create category' });
  }
};

export const updateCategory = async (req: Request, res: Response) => {
  try {
    const userId = (req as any).userId;
    const { id } = req.params;
    const { name, icon, color } = req.body;
    const [updated] = await db.update(categories)
      .set({ name, icon, color })
      .where(and(eq(categories.id, parseInt(id)), eq(categories.userId, userId)))
      .returning();
    res.json(updated);
  } catch (error) {
    res.status(500).json({ error: 'Failed to update category' });
  }
};

export const deleteCategory = async (req: Request, res: Response) => {
  try {
    const userId = (req as any).userId;
    const { id } = req.params;
    await db.delete(categories).where(
      and(eq(categories.id, parseInt(id)), eq(categories.userId, userId))
    );
    res.json({ success: true });
  } catch (error) {
    res.status(500).json({ error: 'Failed to delete category' });
  }
};
