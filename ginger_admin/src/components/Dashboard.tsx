import React, { useState, useEffect } from 'react';
import {
  Box,
  AppBar,
  Toolbar,
  Typography,
  Button,
  Tabs,
  Tab,
  Container,
  CircularProgress,
  Alert,
  IconButton,
} from '@mui/material';
import {
  Dashboard as DashboardIcon,
  People as PeopleIcon,
  Analytics as AnalyticsIcon,
  EmojiEvents as RewardsIcon,
  Refresh as RefreshIcon,
  Logout as LogoutIcon,
} from '@mui/icons-material';
import { adminApi, DashboardData, clearAuthToken } from '../services/api';
import StaffList from './StaffList';
import Analytics from './Analytics';
import RecentTransactions from './RecentTransactions';
import ManageRewards from './ManageRewards';

const Dashboard: React.FC = () => {
  const [dashboardData, setDashboardData] = useState<DashboardData | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [activeTab, setActiveTab] = useState<'overview' | 'staff' | 'analytics' | 'rewards'>('overview');

  useEffect(() => {
    loadDashboardData();
  }, []);

  const loadDashboardData = async () => {
    try {
      setLoading(true);
      setError('');
      const data = await adminApi.getDashboardData();
      setDashboardData(data);
    } catch (err: any) {
      setError(err.message || 'Failed to load dashboard data');
    } finally {
      setLoading(false);
    }
  };

  const handleLogout = async () => {
    try {
      await adminApi.logout();
    } catch (err) {
      // Ignore logout errors, just clear token
    }
    clearAuthToken();
    window.location.reload();
  };

  const handleRefresh = () => {
    loadDashboardData();
  };

  if (loading) {
    return (
      <Box
        sx={{
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          justifyContent: 'center',
          minHeight: '100vh',
          gap: 2,
        }}
      >
        <CircularProgress size={60} />
        <Typography variant="h6" color="text.secondary">
          Loading dashboard...
        </Typography>
      </Box>
    );
  }

  if (error) {
    return (
      <Container maxWidth="md" sx={{ mt: 4 }}>
        <Alert
          severity="error"
          action={
            <Button color="inherit" size="small" onClick={handleRefresh}>
              Try Again
            </Button>
          }
        >
          <Typography variant="h6">Error Loading Dashboard</Typography>
          <Typography variant="body2">{error}</Typography>
        </Alert>
      </Container>
    );
  }

  if (!dashboardData) {
    return (
      <Container maxWidth="md" sx={{ mt: 4 }}>
        <Alert
          severity="info"
          action={
            <Button color="inherit" size="small" onClick={handleRefresh}>
              Refresh
            </Button>
          }
        >
          <Typography variant="h6">No Data Available</Typography>
        </Alert>
      </Container>
    );
  }

  const tabIcons = [
    <DashboardIcon />,
    <PeopleIcon />,
    <AnalyticsIcon />,
    <RewardsIcon />,
  ];

  const tabLabels = ['Overview', 'Staff Management', 'Customer Analytics', 'Manage Rewards'];

  return (
    <Box sx={{ flexGrow: 1 }}>
      <AppBar position="static" elevation={1}>
        <Toolbar>
          <Typography variant="h6" component="div" sx={{ flexGrow: 1 }}>
            Ginger Admin Dashboard
          </Typography>
          <IconButton
            color="inherit"
            onClick={handleRefresh}
            sx={{ mr: 1 }}
          >
            <RefreshIcon />
          </IconButton>
          <Button
            color="inherit"
            onClick={handleLogout}
            startIcon={<LogoutIcon />}
          >
            Logout
          </Button>
        </Toolbar>
        <Tabs
          value={activeTab === 'overview' ? 0 : activeTab === 'staff' ? 1 : activeTab === 'analytics' ? 2 : 3}
          onChange={(_, newValue) => {
            const tabs = ['overview', 'staff', 'analytics', 'rewards'] as const;
            setActiveTab(tabs[newValue]);
          }}
          sx={{
            bgcolor: 'primary.dark',
            '& .MuiTab-root': {
              color: 'rgba(255, 255, 255, 0.7)',
              '&.Mui-selected': {
                color: 'white',
              },
            },
            '& .MuiTabs-indicator': {
              backgroundColor: 'white',
            },
          }}
        >
          {tabLabels.map((label, index) => (
            <Tab
              key={label}
              icon={tabIcons[index]}
              label={label}
              iconPosition="start"
              sx={{ minHeight: 64 }}
            />
          ))}
        </Tabs>
      </AppBar>

      <Container maxWidth="xl" sx={{ mt: 3, mb: 3 }}>
        {activeTab === 'overview' && (
          <Box sx={{ display: 'flex', flexDirection: 'column', gap: 3 }}>
            {/* Customer Analytics - Full Width */}
            <Box sx={{ width: '100%' }}>
              <Analytics analytics={dashboardData.analytics} />
            </Box>
            {/* Recent Transactions - Full Width Below */}
            <Box sx={{ width: '100%' }}>
              <RecentTransactions transactions={dashboardData.recent_transactions} />
            </Box>
          </Box>
        )}

        {activeTab === 'staff' && (
          <StaffList staff={dashboardData.staff} onStaffUpdate={loadDashboardData} />
        )}

        {activeTab === 'analytics' && (
          <Analytics analytics={dashboardData.analytics} detailed={true} />
        )}

        {activeTab === 'rewards' && (
          <ManageRewards />
        )}
      </Container>
    </Box>
  );
};

export default Dashboard;
