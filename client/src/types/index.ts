export type Rank = 'S' | 'A' | 'B';

export interface Category {
  id: number;
  userId: string;
  name: string;
  icon: string;
  color: string;
  createdAt: string;
}

export interface Habit {
  id: number;
  userId: string;
  categoryId: number | null;
  name: string;
  description: string | null;
  rank: Rank;
  isActive: boolean;
  createdAt: string;
  completedToday?: boolean;
  currentStreak?: number;
}

export interface Streak {
  id: number;
  habitId: number;
  currentStreak: number;
  longestStreak: number;
  lastCompletedDate: string | null;
}

export interface HabitStats {
  streak: Streak;
  totalCompletions: number;
}
