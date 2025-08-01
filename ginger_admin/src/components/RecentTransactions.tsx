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
  // Split transactions into points added and rewards redeemed
  const pointsAdded = transactions.filter(t => t.points_amount > 0);
  const rewardsRedeemed = transactions.filter(t => t.points_amount < 0);

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

  const renderTransactionList = (transactionList: Transaction[], maxHeight: number = 300) => {
    if (transactionList.length === 0) {
      return (
        <Box sx={{ textAlign: 'center', py: 3 }}>
          <Typography variant="body2" color="text.secondary">
            No transactions
          </Typography>
        </Box>
      );
    }

    return (
      <List sx={{ maxHeight, overflow: 'auto', py: 0 }}>
        {transactionList.map((transaction, index) => (
          <React.Fragment key={transaction.id}>
            <ListItem alignItems="flex-start" sx={{ px: 0, py: 1 }}>
              <ListItemAvatar>
                <Avatar
                  sx={{
                    bgcolor: transaction.points_amount > 0 ? 'success.main' : 'error.main',
                    width: 32,
                    height: 32,
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
            {index < transactionList.length - 1 && <Divider variant="inset" component="li" />}
          </React.Fragment>
        ))}
      </List>
    );
  };

  return (
    <Box sx={{ display: 'flex', gap: 3, flexDirection: { xs: 'column', lg: 'row' } }}>
      {/* Points Added Section */}
      <Card elevation={2} sx={{ flex: 1 }}>
        <CardContent>
          <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 2 }}>
            <Typography variant="h6" component="h3" color="success.main">
              Points Added
            </Typography>
            <Chip
              label={`${pointsAdded.length} transactions`}
              color="success"
              variant="outlined"
              size="small"
            />
          </Box>

          {renderTransactionList(pointsAdded)}

          {pointsAdded.length > 0 && (
            <Box sx={{ mt: 2 }}>
              <Paper elevation={0} sx={{ p: 2, textAlign: 'center', bgcolor: 'success.50' }}>
                <Typography variant="h6" fontWeight="bold" color="success.main">
                  +{pointsAdded.reduce((sum, t) => sum + t.points_amount, 0)}
                </Typography>
                <Typography variant="caption" color="text.secondary">
                  Total Points Added
                </Typography>
              </Paper>
            </Box>
          )}
        </CardContent>
      </Card>

      {/* Coffees Redeemed Section */}
      <Card elevation={2} sx={{ flex: 1 }}>
        <CardContent>
          <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 2 }}>
            <Typography variant="h6" component="h3" color="error.main">
              Coffees Redeemed
            </Typography>
            <Chip
              label={`${rewardsRedeemed.length} redemptions`}
              color="error"
              variant="outlined"
              size="small"
            />
          </Box>

          {renderTransactionList(rewardsRedeemed)}

          {rewardsRedeemed.length > 0 && (
            <Box sx={{ mt: 2 }}>
              <Paper elevation={0} sx={{ p: 2, textAlign: 'center', bgcolor: 'error.50' }}>
                <Typography variant="h6" fontWeight="bold" color="error.main">
                  {rewardsRedeemed.reduce((sum, t) => sum + t.points_amount, 0)}
                </Typography>
                <Typography variant="caption" color="text.secondary">
                  Total Points Redeemed
                </Typography>
              </Paper>
            </Box>
          )}
        </CardContent>
      </Card>
    </Box>
  );
};

export default RecentTransactions;
