import React from 'react';
import {
  Box,
  Card,
  CardContent,
  Typography,
  List,
  ListItem,
  ListItemAvatar,
  ListItemText,
  Avatar,
  Chip,
  Divider,
  Paper,
} from '@mui/material';
import {
  QrCodeScanner,
  Star,
  Redeem,
} from '@mui/icons-material';
import { Transaction } from '../services/api';

interface RecentTransactionsProps {
  transactions: Transaction[];
}

const RecentTransactions: React.FC<RecentTransactionsProps> = ({ transactions }) => {
  const formatDate = (dateString: string) => {
    const date = new Date(dateString);
    const now = new Date();
    const diffInHours = Math.floor((now.getTime() - date.getTime()) / (1000 * 60 * 60));
    
    if (diffInHours < 1) {
      const diffInMinutes = Math.floor((now.getTime() - date.getTime()) / (1000 * 60));
      return `${diffInMinutes}m ago`;
    } else if (diffInHours < 24) {
      return `${diffInHours}h ago`;
    } else {
      return date.toLocaleDateString('en-US', {
        month: 'short',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
      });
    }
  };

  const getPointsChip = (points: number) => {
    const isPositive = points > 0;
    return (
      <Chip
        label={`${isPositive ? '+' : ''}${points}`}
        color={isPositive ? 'success' : 'error'}
        size="small"
        variant="filled"
      />
    );
  };

  const getTransactionIcon = (points: number, description: string) => {
    if (points > 0) {
      if (description.toLowerCase().includes('scan')) {
        return <QrCodeScanner />;
      }
      return <Star />;
    } else {
      return <Redeem />; // Reward redemption
    }
  };

  return (
    <Card elevation={2} sx={{ height: 'fit-content' }}>
      <CardContent>
        <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 2 }}>
          <Typography variant="h6" component="h3">
            Recent Transactions
          </Typography>
          <Chip
            label={`${transactions.length} recent`}
            color="primary"
            variant="outlined"
            size="small"
          />
        </Box>

        {transactions.length === 0 ? (
          <Box sx={{ textAlign: 'center', py: 4 }}>
            <Typography variant="body2" color="text.secondary">
              No recent transactions
            </Typography>
          </Box>
        ) : (
          <>
            <List sx={{ maxHeight: 400, overflow: 'auto' }}>
              {transactions.map((transaction, index) => (
                <React.Fragment key={transaction.id}>
                  <ListItem alignItems="flex-start" sx={{ px: 0 }}>
                    <ListItemAvatar>
                      <Avatar
                        sx={{
                          bgcolor: transaction.points_amount > 0 ? 'success.main' : 'error.main',
                        }}
                      >
                        {getTransactionIcon(transaction.points_amount, transaction.description)}
                      </Avatar>
                    </ListItemAvatar>
                    <ListItemText
                      primary={
                        <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                          <Typography variant="body2" fontWeight="medium">
                            {transaction.customer_name || transaction.customer_email}
                          </Typography>
                          {getPointsChip(transaction.points_amount)}
                        </Box>
                      }
                      secondary={
                        <Box>
                          <Typography variant="caption" color="text.secondary">
                            {transaction.description}
                            {transaction.staff_name && ` • by ${transaction.staff_name}`}
                          </Typography>
                          <br />
                          <Typography variant="caption" color="text.secondary">
                            {formatDate(transaction.transaction_date)}
                          </Typography>
                        </Box>
                      }
                    />
                  </ListItem>
                  {index < transactions.length - 1 && <Divider variant="inset" component="li" />}
                </React.Fragment>
              ))}
            </List>

            <Divider sx={{ my: 2 }} />

            <Box sx={{ display: 'flex', gap: 2 }}>
              <Box sx={{ flex: 1 }}>
                <Paper elevation={0} sx={{ p: 1, textAlign: 'center', bgcolor: 'grey.50' }}>
                  <Typography variant="body2" fontWeight="bold">
                    {transactions.reduce((sum, t) => sum + t.points_amount, 0)}
                  </Typography>
                  <Typography variant="caption" color="text.secondary">
                    Total Points
                  </Typography>
                </Paper>
              </Box>
              <Box sx={{ flex: 1 }}>
                <Paper elevation={0} sx={{ p: 1, textAlign: 'center', bgcolor: 'success.50' }}>
                  <Typography variant="body2" fontWeight="bold" color="success.main">
                    +{transactions.filter(t => t.points_amount > 0).reduce((sum, t) => sum + t.points_amount, 0)}
                  </Typography>
                  <Typography variant="caption" color="text.secondary">
                    Earned
                  </Typography>
                </Paper>
              </Box>
              <Box sx={{ flex: 1 }}>
                <Paper elevation={0} sx={{ p: 1, textAlign: 'center', bgcolor: 'error.50' }}>
                  <Typography variant="body2" fontWeight="bold" color="error.main">
                    {transactions.filter(t => t.points_amount < 0).reduce((sum, t) => sum + t.points_amount, 0)}
                  </Typography>
                  <Typography variant="caption" color="text.secondary">
                    Redeemed
                  </Typography>
                </Paper>
              </Box>
            </Box>
          </>
        )}
      </CardContent>
    </Card>
  );
};

export default RecentTransactions;
