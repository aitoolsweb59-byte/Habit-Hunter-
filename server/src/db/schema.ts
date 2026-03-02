import { pgTable, serial, text, timestamp, integer, boolean, date } from 'drizzle-orm/pg-core';

export const users = pgTable('users', {
  id: serial('id').primaryKey(),
  clerkId: text('clerk_id').notNull().unique(),
  email: text('email').notNull(),
  createdAt: timestamp('created_at').defaultNow().notNull(),
});

export const categories = pgTable('categories', {
  id: serial('id').primaryKey(),
  userId: text('user_id').notNull(),
  name: text('name').notNull(),
  icon: text('icon').notNull().default('⚔️'),
  color: text('color').notNull().default('#4f46e5'),
  createdAt: timestamp('created_at').defaultNow().notNull(),
});

export const habits = pgTable('habits', {
  id: serial('id').primaryKey(),
  userId: text('user_id').notNull(),
  categoryId: integer('category_id').references(() => categories.id),
  name: text('name').notNull(),
  description: text('description'),
  rank: text('rank').notNull().default('B'),
  isActive: boolean('is_active').notNull().default(true),
  createdAt: timestamp('created_at').defaultNow().notNull(),
});

export const completions = pgTable('completions', {
  id: serial('id').primaryKey(),
  habitId: integer('habit_id').notNull().references(() => habits.id),
  userId: text('user_id').notNull(),
  completedDate: date('completed_date').notNull(),
  createdAt: timestamp('created_at').defaultNow().notNull(),
});

export const streaks = pgTable('streaks', {
  id: serial('id').primaryKey(),
  habitId: integer('habit_id').notNull().unique().references(() => habits.id),
  currentStreak: integer('current_streak').notNull().default(0),
  longestStreak: integer('longest_streak').notNull().default(0),
  lastCompletedDate: date('last_completed_date'),
  updatedAt: timestamp('updated_at').defaultNow().notNull(),
});
