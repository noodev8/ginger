import React from 'react';
import {
  Box,
  Card,
  CardContent,
  Typography,
  LinearProgress,
  Paper,
  Avatar,
} from '@mui/material';
import {
  People,
  Star,
  TrendingUp,
  PersonAdd,
  Insights,
  Assessment,
  EmojiEvents,
} from '@mui/icons-material';
import { Analytics as AnalyticsData } from '../services/api';

interface AnalyticsProps {
  analytics: AnalyticsData;
  detailed?: boolean;
}

const Analytics: React.FC<AnalyticsProps> = ({ analytics, detailed = false }) => {
  const calculateEngagementRate = () => {
    if (analytics.total_customers === 0) return 0;
    return Math.round((analytics.customers_with_points / analytics.total_customers) * 100);
  };

  const calculateAveragePoints = () => {
    if (analytics.customers_with_points === 0) return 0;
    return Math.round(analytics.total_points_distributed / analytics.customers_with_points);
  };

  const MetricCard: React.FC<{
    title: string;
    value: string | number;
    subtitle?: string;
    icon: React.ReactNode;
    color: 'primary' | 'secondary' | 'success' | 'warning';
  }> = ({ title, value, subtitle, icon, color }) => (
    <Card elevation={2} sx={{ height: '100%' }}>
      <CardContent>
        <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
          <Avatar
            sx={{
              bgcolor: `${color}.main`,
              width: 56,
              height: 56,
            }}
          >
            {icon}
          </Avatar>
          <Box sx={{ flex: 1 }}>
            <Typography variant="h4" component="div" fontWeight="bold">
              {value}
            </Typography>
            <Typography variant="h6" color="text.primary" gutterBottom>
              {title}
            </Typography>
            {subtitle && (
              <Typography variant="body2" color="text.secondary">
                {subtitle}
              </Typography>
            )}
          </Box>
        </Box>
      </CardContent>
    </Card>
  );

  return (
    <Box>
      <Card elevation={2} sx={{ mb: 3 }}>
        <CardContent>
          <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 3 }}>
            <Typography variant="h5" component="h2">
              Customer Analytics
            </Typography>
            <Typography variant="body2" color="text.secondary">
              Last 30 days
            </Typography>
          </Box>

          <Box sx={{
            display: 'grid',
            gridTemplateColumns: { xs: '1fr', sm: '1fr 1fr', md: '1fr 1fr 1fr 1fr' },
            gap: 3
          }}>
            <MetricCard
              title="Total Customers"
              value={analytics.total_customers.toLocaleString()}
              subtitle="Registered users"
              icon={<People />}
              color="primary"
            />

            <MetricCard
              title="Active Customers"
              value={analytics.customers_with_points.toLocaleString()}
              subtitle={`${calculateEngagementRate()}% engagement rate`}
              icon={<Star />}
              color="success"
            />

            <MetricCard
              title="Points Distributed"
              value={analytics.total_points_distributed.toLocaleString()}
              subtitle={`Avg: ${calculateAveragePoints()} per customer`}
              icon={<EmojiEvents />}
              color="secondary"
            />

            <MetricCard
              title="New Registrations"
              value={analytics.recent_registrations.toLocaleString()}
              subtitle="Last 30 days"
              icon={<PersonAdd />}
              color="warning"
            />
          </Box>
        </CardContent>
      </Card>

      {detailed && (
        <>
          <Card elevation={2} sx={{ mb: 3 }}>
            <CardContent>
              <Typography variant="h6" gutterBottom>
                Customer Engagement
              </Typography>
              <Box sx={{ mb: 2 }}>
                <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 1 }}>
                  <Typography variant="body2">Active Customers</Typography>
                  <Typography variant="body2">
                    {analytics.customers_with_points} / {analytics.total_customers}
                  </Typography>
                </Box>
                <LinearProgress
                  variant="determinate"
                  value={calculateEngagementRate()}
                  sx={{ height: 8, borderRadius: 4 }}
                />
                <Box sx={{ textAlign: 'right', mt: 1 }}>
                  <Typography variant="body2" color="primary.main" fontWeight="bold">
                    {calculateEngagementRate()}%
                  </Typography>
                </Box>
              </Box>
            </CardContent>
          </Card>

          <Card elevation={2}>
            <CardContent>
              <Typography variant="h6" gutterBottom>
                Key Insights
              </Typography>
              <Box sx={{
                display: 'grid',
                gridTemplateColumns: { xs: '1fr', md: '1fr 1fr 1fr' },
                gap: 3
              }}>
                <Paper elevation={1} sx={{ p: 2, height: '100%' }}>
                  <Box sx={{ display: 'flex', alignItems: 'center', gap: 2, mb: 2 }}>
                    <Avatar sx={{ bgcolor: 'primary.main' }}>
                      <Insights />
                    </Avatar>
                    <Typography variant="h6">Engagement Rate</Typography>
                  </Box>
                  <Typography variant="body2" color="text.secondary">
                    {calculateEngagementRate()}% of customers have earned loyalty points,
                    showing good app engagement.
                  </Typography>
                </Paper>

                <Paper elevation={1} sx={{ p: 2, height: '100%' }}>
                  <Box sx={{ display: 'flex', alignItems: 'center', gap: 2, mb: 2 }}>
                    <Avatar sx={{ bgcolor: 'secondary.main' }}>
                      <Assessment />
                    </Avatar>
                    <Typography variant="h6">Average Points</Typography>
                  </Box>
                  <Typography variant="body2" color="text.secondary">
                    Active customers have earned an average of {calculateAveragePoints()} points each.
                  </Typography>
                </Paper>

                <Paper elevation={1} sx={{ p: 2, height: '100%' }}>
                  <Box sx={{ display: 'flex', alignItems: 'center', gap: 2, mb: 2 }}>
                    <Avatar sx={{ bgcolor: 'success.main' }}>
                      <TrendingUp />
                    </Avatar>
                    <Typography variant="h6">Growth</Typography>
                  </Box>
                  <Typography variant="body2" color="text.secondary">
                    {analytics.recent_registrations} new customers joined in the last 30 days.
                  </Typography>
                </Paper>
              </Box>
            </CardContent>
          </Card>
        </>
      )}
    </Box>
  );
};

export default Analytics;
