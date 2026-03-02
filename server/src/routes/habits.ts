import { Router } from 'express';
import { requireAuth, extractUserId } from '../middleware/auth';
import { getHabits, createHabit, updateHabit, deleteHabit, completeHabit, getHabitStats } from '../controllers/habits';

const router = Router();
router.use(requireAuth, extractUserId);
router.get('/', getHabits);
router.post('/', createHabit);
router.put('/:id', updateHabit);
router.delete('/:id', deleteHabit);
router.post('/:id/complete', completeHabit);
router.get('/:id/stats', getHabitStats);
export default router;
