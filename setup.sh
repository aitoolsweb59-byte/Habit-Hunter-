#!/bin/bash
echo "Batch 8 starting..."

# main.tsx
cat > client/src/main.tsx << 'EOF'
import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App';

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);
EOF
echo "main.tsx done!"

# App.tsx
cat > client/src/App.tsx << 'EOF'
import React from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { ThemeProvider, CssBaseline, Box, CircularProgress } from '@mui/material';
import { ClerkProvider, SignIn, SignUp, useAuth } from '@clerk/clerk-react';
import { soloLevelingTheme } from './theme';
import Dashboard from './pages/Dashboard';

const PUBLISHABLE_KEY = import.meta.env.VITE_CLERK_PUBLISHABLE_KEY;

const ProtectedRoute: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const { isLoaded, isSignedIn } = useAuth();
  if (!isLoaded) return (
    <Box sx={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '100vh', background: '#0a0a0f' }}>
      <CircularProgress sx={{ color: '#4f46e5' }} />
    </Box>
  );
  if (!isSignedIn) return <Navigate to="/sign-in" replace />;
  return <>{children}</>;
};

function App() {
  return (
    <ClerkProvider publishableKey={PUBLISHABLE_KEY}>
      <ThemeProvider theme={soloLevelingTheme}>
        <CssBaseline />
        <BrowserRouter>
          <Routes>
            <Route path="/sign-in/*" element={
              <Box sx={{ display: 'flex', justifyContent: 'center', alignItems: 'center', minHeight: '100vh', background: '#0a0a0f' }}>
                <SignIn routing="path" path="/sign-in" afterSignInUrl="/" />
              </Box>
            } />
            <Route path="/sign-up/*" element={
              <Box sx={{ display: 'flex', justifyContent: 'center', alignItems: 'center', minHeight: '100vh', background: '#0a0a0f' }}>
                <SignUp routing="path" path="/sign-up" afterSignUpUrl="/" />
              </Box>
            } />
            <Route path="/" element={<ProtectedRoute><Dashboard /></ProtectedRoute>} />
          </Routes>
        </BrowserRouter>
      </ThemeProvider>
    </ClerkProvider>
  );
}

export default App;
EOF
echo "App.tsx done!"

# HabitCard component
cat > client/src/components/HabitCard.tsx << 'EOF'
import React, { useState } from 'react';
import { useSwipeable } from 'react-swipeable';
import { Box, Typography, IconButton } from '@mui/material';
import { CheckCircle, RadioButtonUnchecked, LocalFire, Delete } from '@mui/icons-material';
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
                  <LocalFire sx={{ fontSize: 14, color: '#f59e0b' }} />
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
echo "HabitCard done!"

# Dashboard page
cat > client/src/pages/Dashboard.tsx << 'EOF'
import React, { useState, useEffect } from 'react';
import {
  Box, Typography, Fab, CircularProgress, LinearProgress,
  Dialog, DialogTitle, DialogContent, DialogActions,
  Button, TextField, Select, MenuItem, FormControl, InputLabel,
} from '@mui/material';
import { Add } from '@mui/icons-material';
import { motion } from 'framer-motion';
import { useUser } from '@clerk/clerk-react';
import HabitCard from '../components/HabitCard';
import { habitsApi } from '../api';
import { Habit, Rank } from '../types';

const Dashboard: React.FC = () => {
  const { user } = useUser();
  const [habits, setHabits] = useState<Habit[]>([]);
  const [loading, setLoading] = useState(true);
  const [openDialog, setOpenDialog] = useState(false);
  const [newHabit, setNewHabit] = useState({ name: '', description: '', rank: 'B' as Rank });

  useEffect(() => { fetchHabits(); }, []);

  const fetchHabits = async () => {
    try {
      const res = await habitsApi.getAll();
      setHabits(res.data);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const handleComplete = async (id: number) => {
    try {
      const res = await habitsApi.complete(id);
      setHabits(prev => prev.map(h => h.id === id ? { ...h, completedToday: res.data.completed } : h));
    } catch (err) { console.error(err); }
  };

  const handleDelete = async (id: number) => {
    try {
      await habitsApi.delete(id);
      setHabits(prev => prev.filter(h => h.id !== id));
    } catch (err) { console.error(err); }
  };

  const handleCreate = async () => {
    try {
      const res = await habitsApi.create(newHabit);
      setHabits(prev => [...prev, res.data]);
      setOpenDialog(false);
      setNewHabit({ name: '', description: '', rank: 'B' });
    } catch (err) { console.error(err); }
  };

  const completedCount = habits.filter(h => h.completedToday).length;
  const progress = habits.length > 0 ? (completedCount / habits.length) * 100 : 0;
  const sRank = habits.filter(h => h.rank === 'S');
  const aRank = habits.filter(h => h.rank === 'A');
  const bRank = habits.filter(h => h.rank === 'B');

  return (
    <Box sx={{ pb: 10, px: 2, pt: 3, minHeight: '100vh', background: '#0a0a0f' }}>
      <motion.div initial={{ opacity: 0, y: -20 }} animate={{ opacity: 1, y: 0 }}>
        <Box sx={{ mb: 3 }}>
          <Typography variant="h5" sx={{
            fontWeight: 900, letterSpacing: '0.1em',
            background: 'linear-gradient(135deg, #4f46e5, #06b6d4)',
            WebkitBackgroundClip: 'text', WebkitTextFillColor: 'transparent',
          }}>
            DAILY QUESTS
          </Typography>
          <Typography sx={{ color: '#64748b', fontSize: 13, mt: 0.5 }}>
            Hunter: {user?.firstName || user?.username || 'Unknown'}
          </Typography>
        </Box>
        <Box sx={{
          background: 'linear-gradient(135deg, #0f0f1a, #1a1a2e)',
          border: '1px solid rgba(79, 70, 229, 0.3)',
          borderRadius: 2, p: 2, mb: 3,
        }}>
          <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 1 }}>
            <Typography sx={{ fontSize: 12, color: '#94a3b8', fontWeight: 700, letterSpacing: '0.1em' }}>
              DAILY PROGRESS
            </Typography>
            <Typography sx={{ fontSize: 12, color: '#4f46e5', fontWeight: 700 }}>
              {completedCount}/{habits.length}
            </Typography>
          </Box>
          <LinearProgress variant="determinate" value={progress} sx={{
            height: 8, borderRadius: 4,
            bgcolor: 'rgba(79, 70, 229, 0.15)',
            '& .MuiLinearProgress-bar': {
              background: 'linear-gradient(90deg, #4f46e5, #06b6d4)',
              borderRadius: 4,
            },
          }} />
        </Box>
      </motion.div>

      {loading ? (
        <Box sx={{ display: 'flex', justifyContent: 'center', mt: 8 }}>
          <CircularProgress sx={{ color: '#4f46e5' }} />
        </Box>
      ) : (
        <>
          {sRank.length > 0 && (
            <Box sx={{ mb: 3 }}>
              <Typography sx={{ fontSize: 11, color: '#f59e0b', fontWeight: 900, letterSpacing: '0.2em', mb: 1 }}>
                ★ S-RANK — PRIMARY
              </Typography>
              {sRank.map(h => <HabitCard key={h.id} habit={h} onComplete={handleComplete} onDelete={handleDelete} />)}
            </Box>
          )}
          {aRank.length > 0 && (
            <Box sx={{ mb: 3 }}>
              <Typography sx={{ fontSize: 11, color: '#7c3aed', fontWeight: 900, letterSpacing: '0.2em', mb: 1 }}>
                ◆ A-RANK — SECONDARY
              </Typography>
              {aRank.map(h => <HabitCard key={h.id} habit={h} onComplete={handleComplete} onDelete={handleDelete} />)}
            </Box>
          )}
          {bRank.length > 0 && (
            <Box sx={{ mb: 3 }}>
              <Typography sx={{ fontSize: 11, color: '#06b6d4', fontWeight: 900, letterSpacing: '0.2em', mb: 1 }}>
                ◇ B-RANK — TERTIARY
              </Typography>
              {bRank.map(h => <HabitCard key={h.id} habit={h} onComplete={handleComplete} onDelete={handleDelete} />)}
            </Box>
          )}
          {habits.length === 0 && (
            <Box sx={{ textAlign: 'center', mt: 10 }}>
              <Typography sx={{ color: '#334155', fontSize: 16, fontWeight: 700, letterSpacing: '0.1em' }}>
                NO QUESTS FOUND, HUNTER.
              </Typography>
              <Typography sx={{ color: '#1e293b', fontSize: 13, mt: 1 }}>
                Tap + to add your first daily quest
              </Typography>
            </Box>
          )}
        </>
      )}

      <Fab onClick={() => setOpenDialog(true)} sx={{
        position: 'fixed', bottom: 80, right: 20,
        background: 'linear-gradient(135deg, #4f46e5, #7c3aed)',
        boxShadow: '0 0 25px rgba(79, 70, 229, 0.6)',
      }}>
        <Add />
      </Fab>

      <Dialog open={openDialog} onClose={() => setOpenDialog(false)} fullWidth maxWidth="sm"
        PaperProps={{ sx: { background: 'linear-gradient(135deg, #0f0f1a, #1a1a2e)', border: '1px solid rgba(79, 70, 229, 0.4)' } }}
      >
        <DialogTitle sx={{
          fontWeight: 900, letterSpacing: '0.1em',
          background: 'linear-gradient(135deg, #4f46e5, #06b6d4)',
          WebkitBackgroundClip: 'text', WebkitTextFillColor: 'transparent',
        }}>
          NEW QUEST
        </DialogTitle>
        <DialogContent sx={{ display: 'flex', flexDirection: 'column', gap: 2, pt: 2 }}>
          <TextField label="Quest Name" value={newHabit.name}
            onChange={e => setNewHabit(p => ({ ...p, name: e.target.value }))} fullWidth />
          <TextField label="Description (optional)" value={newHabit.description}
            onChange={e => setNewHabit(p => ({ ...p, description: e.target.value }))} fullWidth multiline rows={2} />
          <FormControl fullWidth>
            <InputLabel>Rank</InputLabel>
            <Select value={newHabit.rank} label="Rank"
              onChange={e => setNewHabit(p => ({ ...p, rank: e.target.value as Rank }))}>
              <MenuItem value="S">⭐ S-Rank — Primary</MenuItem>
              <MenuItem value="A">◆ A-Rank — Secondary</MenuItem>
              <MenuItem value="B">◇ B-Rank — Tertiary</MenuItem>
            </Select>
          </FormControl>
        </DialogContent>
        <DialogActions sx={{ p: 2, gap: 1 }}>
          <Button onClick={() => setOpenDialog(false)} sx={{ color: '#64748b' }}>CANCEL</Button>
          <Button onClick={handleCreate} disabled={!newHabit.name.trim()} variant="contained"
            sx={{ background: 'linear-gradient(135deg, #4f46e5, #7c3aed)' }}>
            ACCEPT QUEST
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
};

export default Dashboard;
EOF
echo "Dashboard done!"

# render.yaml
cat > render.yaml << 'EOF'
services:
  - type: web
    name: habit-hunter-server
    env: node
    rootDir: server
    buildCommand: npm install && npm run build
    startCommand: npm start
    envVars:
      - key: DATABASE_URL
        sync: false
      - key: CLERK_SECRET_KEY
        sync: false
      - key: CLIENT_URL
        sync: false
      - key: NODE_ENV
        value: production

  - type: web
    name: habit-hunter-client
    env: static
    rootDir: client
    buildCommand: npm install && npm run build
    staticPublishPath: dist
    envVars:
      - key: VITE_CLERK_PUBLISHABLE_KEY
        sync: false
      - key: VITE_API_URL
        sync: false
EOF
echo "render.yaml done!"

echo "ALL FILES CREATED! Hunter is ready! ⚔️"
