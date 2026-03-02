import { createTheme } from '@mui/material/styles';

export const soloLevelingTheme = createTheme({
  palette: {
    mode: 'dark',
    primary: { main: '#4f46e5', light: '#7c3aed', dark: '#3730a3' },
    secondary: { main: '#06b6d4', light: '#22d3ee', dark: '#0891b2' },
    warning: { main: '#f59e0b' },
    background: { default: '#0a0a0f', paper: '#0f0f1a' },
    text: { primary: '#e2e8f0', secondary: '#94a3b8' },
  },
  typography: {
    fontFamily: '"Rajdhani", "Orbitron", sans-serif',
    h1: { fontWeight: 700, letterSpacing: '0.05em' },
    h2: { fontWeight: 700, letterSpacing: '0.05em' },
    h3: { fontWeight: 600 },
  },
  shape: { borderRadius: 8 },
  components: {
    MuiCard: {
      styleOverrides: {
        root: {
          background: 'linear-gradient(135deg, #0f0f1a 0%, #1a1a2e 100%)',
          border: '1px solid rgba(79, 70, 229, 0.3)',
          boxShadow: '0 0 20px rgba(79, 70, 229, 0.1)',
        },
      },
    },
    MuiButton: {
      styleOverrides: {
        root: { textTransform: 'uppercase', letterSpacing: '0.1em', fontWeight: 700 },
      },
    },
  },
});

export const rankColors = {
  S: { bg: '#f59e0b', glow: 'rgba(245, 158, 11, 0.4)', label: 'S-RANK' },
  A: { bg: '#7c3aed', glow: 'rgba(124, 58, 237, 0.4)', label: 'A-RANK' },
  B: { bg: '#06b6d4', glow: 'rgba(6, 182, 212, 0.4)', label: 'B-RANK' },
};
