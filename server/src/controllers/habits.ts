import { Request, Response } from 'express';
import { db } from '../db';
import { habits, completions, streaks } from '../db/schema';
import { eq, and } from 'drizzle-orm';

export const getHabits = async (req: Request, res: Response) => {
  try {
    const userId = (req as any).userId;
    const result = await db.select().from(habits).where(
      and(eq(habits.userId, userId), eq(habits.isActive, true))
    );
    res.json(result);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch habits' });
  }
};

export const createHabit = async (req: Request, res: Response) => {
  try {
    const userId = (req as any).userId;
    const { name, description, rank, categoryId } = req.body;
    const [habit] = await db.insert(habits).values({
      userId, name, description,
      rank: rank || 'B',
      categoryId: categoryId || null,
    }).returning();
    await db.insert(streaks).values({ habitId: habit.id });
    res.status(201).json(habit);
  } catch (error) {
    res.status(500).json({ error: 'Failed to create habit' });
  }
};

export const updateHabit = async (req: Request, res: Response) => {
  try {
    const userId = (req as any).userId;
    const { id } = req.params;
    const { name, description, rank, categoryId } = req.body;
    const [updated] = await db.update(habits)
      .set({ name, description, rank, categoryId })
      .where(and(eq(habits.id, parseInt(id)), eq(habits.userId, userId)))
      .returning();
    res.json(updated);
  } catch (error) {
    res.status(500).json({ error: 'Failed to update habit' });
  }
};

export const deleteHabit = async (req: Request, res: Response) => {
  try {
    const userId = (req as any).userId;
    const { id } = req.params;
    await db.update(habits)
      .set({ isActive: false })
      .where(and(eq(habits.id, parseInt(id)), eq(habits.userId, userId)));
    res.json({ success: true });
  } catch (error) {
    res.status(500).json({ error: 'Failed to delete habit' });
  }
};

export const completeHabit = async (req: Request, res: Response) => {
  try {
    const userId = (req as any).userId;
    const { id } = req.params;
    const today = new Date().toISOString().split('T')[0];
    const existing = await db.select().from(completions).where(
      and(eq(completions.habitId, parseInt(id)), eq(completions.completedDate, today))
    );
    if (existing.length > 0) {
      await db.delete(completions).where(
        and(eq(completions.habitId, parseInt(id)), eq(completions.completedDate, today))
      );
      return res.json({ completed: false });
    }
    await db.insert(completions).values({ habitId: parseInt(id), userId, completedDate: today });
    const [streak] = await db.select().from(streaks).where(eq(streaks.habitId, parseInt(id)));
    if (streak) {
      const yesterday = new Date();
      yesterday.setDate(yesterday.getDate() - 1);
      const yesterdayStr = yesterday.toISOString().split('T')[0];
      const newStreak = streak.lastCompletedDate === yesterdayStr ? streak.currentStreak + 1 : 1;
      const newLongest = Math.max(newStreak, streak.longestStreak);
      await db.update(streaks).set({
        currentStreak: newStreak, longestStreak: newLongest,
        lastCompletedDate: today, updatedAt: new Date(),
      }).where(eq(streaks.habitId, parseInt(id)));
    }
    res.json({ completed: true });
  } catch (error) {
    res.status(500).json({ error: 'Failed to complete habit' });
  }
};

export const getHabitStats = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const [streak] = await db.select().from(streaks).where(eq(streaks.habitId, parseInt(id)));
    const allCompletions = await db.select().from(completions).where(eq(completions.habitId, parseInt(id)));
    res.json({ streak, totalCompletions: allCompletions.length });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch stats' });
  }
};
