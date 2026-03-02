#!/bin/bash
echo "Fixing errors..."

# Fix api/index.ts
cat > client/src/api/index.ts << 'EOF'
import axios from 'axios';

const api = axios.create({
  baseURL: (import.meta as any).env?.VITE_API_URL || '/api',
});

api.interceptors.request.use(async (config) => {
  try {
    const token = await (window as any).__clerk_frontend_api?.session?.getToken();
    if (token) config.headers.Authorization = `Bearer ${token}`;
  } catch {}
  return config;
});

export const habitsApi = {
  getAll: () => api.get('/habits'),
  create: (data: any) => api.post('/habits', data),
  update: (id: number, data: any) => api.put(`/habits/${id}`, data),
  delete: (id: number) => api.delete(`/habits/${id}`),
  complete: (id: number) => api.post(`/habits/${id}/complete`),
  getStats: (id: number) => api.get(`/habits/${id}/stats`),
};

export const categoriesApi = {
  getAll: () => api.get('/categories'),
  create: (data: any) => api.post('/categories', data),
  update: (id: number, data: any) => api.put(`/categories/${id}`, data),
  delete: (id: number) => api.delete(`/categories/${id}`),
};

export default api;
EOF
echo "api fixed!"

# Fix HabitCard - replace LocalFire with Whatshot
cat > client/src/components/HabitCard.tsx << 'EOF'
import React, { useState } from 'react';
import { useSwipeable } from 'react-swipeable';
import { Box, Typography, IconButton } from '@mui/material';
import { CheckCircle, RadioButtonUnchecked, Whatshot, Delete } from '@mui/icons-material';
import { motion, AnimatePresence } from 'framer-motion';
import { Habit } from '../types';
import { rankColors } from '../theme';

interface Props {
  habit: Habit;
  onComplete: (id: number) => void;
  onDelete: (id: number) => void;
}

const HabitCard: React.FC<Props> = ({ habit, onComplete, onDelete }) => {
  const [swipeX, setSwipeX] = useState(0);
  const [isDeleting, setIsDeleting] = useState(false);
  const [showEliminated, setShowEliminated] = useState(false);
  const rank = rankColors[habit.rank as keyof typeof rankColors] || rankColors.B;

  const handlers = useSwipeable({
    onSwiping: (e) => { if (e.dir === 'Left') setSwipeX(-Math.min(e.absX, 100)); },
    onSwipedLeft: (e) => { if (e.absX > 80) handleDelete(); else setSwipeX(0); },
    onSwipedRight: () => setSwipeX(0),
    trackMouse: false,
  });

  const handleDelete = () => {
    setShowEliminated(true);
    setIsDeleting(true);
    setTimeout(() => onDelete(habit.id), 600);
  };

  return (
    <AnimatePresence>
      {!isDeleting && (
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          exit={{ opacity: 0, x: -300 }}
          style={{ position: 'relative', marginBottom: 12 }}
        >
          <Box sx={{
            position: 'absolute', right: 0, top: 0, bottom: 0, width: 80,
            borderRadius: 2, background: 'linear-gradient(135deg, #7f1d1d, #dc2626)',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            boxShadow: '0 0 20px rgba(220, 38, 38, 0.5)',
          }}>
            <Delete sx={{ color: 'white' }} />
          </Box>
          <AnimatePresence>
            {showEliminated && (
              <motion.div
                initial={{ opacity: 0, scale: 0.8 }}
                animate={{ opacity: 1, scale: 1 }}
                style={{
                  position: 'absolute', inset: 0, zIndex: 10,
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                  background: 'rgba(220, 38, 38, 0.9)', borderRadius: 8,
                }}
              >
                <Typography variant="h5" sx={{ color: 'white', fontWeight: 900, letterSpacing: '0.2em' }}>
                  ELIMINATED
                </Typography>
              </motion.div>
            )}
          </AnimatePresence>
          <Box
            {...handlers}
            sx={{
              transform: `translateX(${swipeX}px)`,
              transition: swipeX === 0 ? 'transform 0.3s ease' : 'none',
              background: 'linear-gradient(135deg, #0f0f1a 0%, #1a1a2e 100%)',
              border: `1px solid ${rank.bg}44`,
              boxShadow: `0 0 15px ${rank.glow}`,
              borderRadius: 2, p: 2,
              display: 'flex', alignItems: 'center', gap: 2,
              userSelect: 'none',
            }}
          >
            <Box sx={{
              width: 40, height: 40, borderRadius: 1, flexShrink: 0,
              background: `linear-gradient(135deg, ${rank.bg}33, ${rank.bg}66)`,
              border: `1px solid ${rank.bg}`,
              boxShadow: `0 0 10px ${rank.glow}`,
              display: 'flex', alignItems: 'center', justifyContent: 'center',
            }}>
              <Typography sx={{ color: rank.bg, fontWeight: 900, fontSize: 13 }}>
                {habit.rank}
              </Typography>
            </Box>
            <Box sx={{ flex: 1, minWidth: 0 }}>
              <Typography sx={{
                fontWeight: 700, fontSize: 15,
                color: habit.completedToday ? '#64748b' : '#e2e8f0',
                textDecoration: habit.completedToday ? 'line-through' : 'none',
                whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis',
              }}>
                {habit.name}
              </Typography>
              {(habit.currentStreak ?? 0) > 0 && (
                <Box sx={{ display: 'flex', alignItems: 'center', gap: 0.5, mt: 0.5 }}>
                  <Whatshot sx={{ fontSize: 14, color: '#f59e0b' }} />
                  <Typography sx={{ fontSize: 12, color: '#f59e0b', fontWeight: 700 }}>
                    {habit.currentStreak} day streak
                  </Typography>
                </Box>
              )}
            </Box>
            <IconButton onClick={() => onComplete(habit.id)} sx={{ color: habit.completedToday ? '#4f46e5' : '#334155' }}>
              {habit.completedToday
                ? <CheckCircle sx={{ fontSize: 28, filter: 'drop-shadow(0 0 8px #4f46e5)' }} />
                : <RadioButtonUnchecked sx={{ fontSize: 28 }} />
              }
            </IconButton>
          </Box>
        </motion.div>
      )}
    </AnimatePresence>
  );
};

export default HabitCard;
EOF
echo "HabitCard fixed!"

echo "All fixes done!"
