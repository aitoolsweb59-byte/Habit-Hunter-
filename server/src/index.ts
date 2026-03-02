import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import habitsRouter from './routes/habits';
import categoriesRouter from './routes/categories';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors({
  origin: process.env.CLIENT_URL || 'http://localhost:5173',
  credentials: true,
}));
app.use(express.json());

app.get('/health', (req, res) => {
  res.json({ status: 'Hunter is online ⚔️' });
});

app.use('/api/habits', habitsRouter);
app.use('/api/categories', categoriesRouter);

app.listen(PORT, () => {
  console.log(`⚔️ Habit Hunter server running on port ${PORT}`);
});

export default app;
