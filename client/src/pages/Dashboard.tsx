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
