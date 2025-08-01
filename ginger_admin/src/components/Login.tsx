import React, { useState } from 'react';
import {
  Box,
  Card,
  CardContent,
  TextField,
  Button,
  Typography,
  Alert,
  Container,
  Avatar,
  CircularProgress,
} from '@mui/material';
import { LockOutlined } from '@mui/icons-material';
import { adminApi, setAuthToken } from '../services/api';

interface LoginProps {
  onLogin: () => void;
}

const Login: React.FC<LoginProps> = ({ onLogin }) => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError('');

    try {
      const response = await adminApi.login(email, password);
      
      if (response.return_code === 'SUCCESS' && response.user) {
        // Check if user is staff admin
        if (!response.user.staff || !response.user.staff_admin) {
          setError('Access denied. Staff admin privileges required.');
          return;
        }

        setAuthToken(response.user.auth_token);
        onLogin();
      } else {
        setError(response.message || 'Login failed');
      }
    } catch (err: any) {
      setError(err.response?.data?.message || 'Login failed. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <Container component="main" maxWidth="sm">
      <Box
        sx={{
          minHeight: '100vh',
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          justifyContent: 'center',
          background: 'linear-gradient(135deg, #6750A4 0%, #7F67BE 100%)',
          margin: '-8px',
          padding: 3,
        }}
      >
        <Card
          elevation={3}
          sx={{
            width: '100%',
            maxWidth: 400,
            p: 2,
          }}
        >
          <CardContent>
            <Box
              sx={{
                display: 'flex',
                flexDirection: 'column',
                alignItems: 'center',
                mb: 3,
              }}
            >
              <Avatar
                sx={{
                  m: 1,
                  bgcolor: 'primary.main',
                  width: 56,
                  height: 56,
                }}
              >
                <LockOutlined fontSize="large" />
              </Avatar>
              <Typography component="h1" variant="h4" align="center" gutterBottom>
                Ginger Admin
              </Typography>
              <Typography variant="body2" color="text.secondary" align="center">
                Manager Dashboard
              </Typography>
            </Box>

            {error && (
              <Alert severity="error" sx={{ mb: 2 }}>
                {error}
              </Alert>
            )}

            <Box component="form" onSubmit={handleSubmit} sx={{ mt: 1 }}>
              <TextField
                margin="normal"
                required
                fullWidth
                id="email"
                label="Email Address"
                name="email"
                autoComplete="email"
                autoFocus
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                disabled={loading}
                variant="outlined"
              />
              <TextField
                margin="normal"
                required
                fullWidth
                name="password"
                label="Password"
                type="password"
                id="password"
                autoComplete="current-password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                disabled={loading}
                variant="outlined"
              />
              <Button
                type="submit"
                fullWidth
                variant="contained"
                disabled={loading}
                sx={{
                  mt: 3,
                  mb: 2,
                  py: 1.5,
                  position: 'relative',
                }}
              >
                {loading && (
                  <CircularProgress
                    size={20}
                    sx={{
                      position: 'absolute',
                      left: '50%',
                      marginLeft: '-10px',
                    }}
                  />
                )}
                {loading ? 'Signing in...' : 'Sign In'}
              </Button>
            </Box>

            <Box sx={{ mt: 2, textAlign: 'center' }}>
              <Typography variant="caption" color="text.secondary">
                Only staff administrators can access this dashboard
              </Typography>
            </Box>
          </CardContent>
        </Card>
      </Box>
    </Container>
  );
};

export default Login;
