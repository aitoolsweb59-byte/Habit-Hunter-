import React from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { ThemeProvider, CssBaseline, Box, CircularProgress } from '@mui/material';
import { ClerkProvider, SignIn, SignUp, useAuth } from '@clerk/clerk-react';
import { soloLevelingTheme } from './theme';
import Dashboard from './pages/Dashboard';

const PUBLISHABLE_KEY = (import.meta as any).env?.VITE_CLERK_PUBLISHABLE_KEY;

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
