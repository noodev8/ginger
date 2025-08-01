import React from 'react';
import {
  Box,
  Card,
  CardContent,
  Typography,
  Chip,
  Avatar,
  Paper,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
} from '@mui/material';
import {
  AdminPanelSettings,
  Person,
  Verified,
  Warning,
} from '@mui/icons-material';
import { Staff } from '../services/api';

interface StaffListProps {
  staff: Staff[];
}

const StaffList: React.FC<StaffListProps> = ({ staff }) => {
  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    });
  };

  const getStatusChip = (isAdmin: boolean) => {
    return (
      <Chip
        icon={isAdmin ? <AdminPanelSettings /> : <Person />}
        label={isAdmin ? 'Admin' : 'Staff'}
        color={isAdmin ? 'primary' : 'secondary'}
        variant="filled"
        size="small"
      />
    );
  };

  const getVerificationChip = (isVerified: boolean) => {
    return (
      <Chip
        icon={isVerified ? <Verified /> : <Warning />}
        label={isVerified ? 'Verified' : 'Unverified'}
        color={isVerified ? 'success' : 'warning'}
        variant="outlined"
        size="small"
      />
    );
  };

  return (
    <Box>
      <Card elevation={2} sx={{ mb: 3 }}>
        <CardContent>
          <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 2 }}>
            <Typography variant="h5" component="h2">
              Staff Members
            </Typography>
            <Chip
              label={`${staff.length} staff member${staff.length !== 1 ? 's' : ''}`}
              color="primary"
              variant="outlined"
            />
          </Box>

          {staff.length === 0 ? (
            <Box sx={{ textAlign: 'center', py: 4 }}>
              <Typography variant="body1" color="text.secondary">
                No staff members found
              </Typography>
            </Box>
          ) : (
            <TableContainer component={Paper} elevation={0} sx={{ border: 1, borderColor: 'divider' }}>
              <Table>
                <TableHead>
                  <TableRow sx={{ bgcolor: 'grey.50' }}>
                    <TableCell><strong>Staff Member</strong></TableCell>
                    <TableCell><strong>Contact</strong></TableCell>
                    <TableCell><strong>Role</strong></TableCell>
                    <TableCell><strong>Status</strong></TableCell>
                    <TableCell><strong>Joined</strong></TableCell>
                    <TableCell><strong>Last Active</strong></TableCell>
                  </TableRow>
                </TableHead>
                <TableBody>
                  {staff.map((member) => (
                    <TableRow key={member.id} hover>
                      <TableCell>
                        <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
                          <Avatar sx={{ bgcolor: member.staff_admin ? 'primary.main' : 'secondary.main' }}>
                            {member.staff_admin ? <AdminPanelSettings /> : <Person />}
                          </Avatar>
                          <Box>
                            <Typography variant="body2" fontWeight="medium">
                              {member.display_name || 'No name set'}
                            </Typography>
                            <Typography variant="caption" color="text.secondary">
                              {member.email}
                            </Typography>
                          </Box>
                        </Box>
                      </TableCell>
                      <TableCell>
                        <Typography variant="body2">
                          {member.phone || 'Not provided'}
                        </Typography>
                      </TableCell>
                      <TableCell>
                        {getStatusChip(member.staff_admin)}
                      </TableCell>
                      <TableCell>
                        {getVerificationChip(member.email_verified)}
                      </TableCell>
                      <TableCell>
                        <Typography variant="body2">
                          {formatDate(member.created_at)}
                        </Typography>
                      </TableCell>
                      <TableCell>
                        <Typography variant="body2">
                          {member.last_active_at
                            ? formatDate(member.last_active_at)
                            : 'Never'
                          }
                        </Typography>
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </TableContainer>
          )}
        </CardContent>
      </Card>

      <Box sx={{ display: 'flex', gap: 2, flexDirection: { xs: 'column', sm: 'row' } }}>
        <Box sx={{ flex: 1 }}>
          <Paper elevation={1} sx={{ p: 2, textAlign: 'center' }}>
            <Typography variant="h4" color="primary.main" fontWeight="bold">
              {staff.length}
            </Typography>
            <Typography variant="body2" color="text.secondary">
              Total Staff
            </Typography>
          </Paper>
        </Box>
        <Box sx={{ flex: 1 }}>
          <Paper elevation={1} sx={{ p: 2, textAlign: 'center' }}>
            <Typography variant="h4" color="primary.main" fontWeight="bold">
              {staff.filter(s => s.staff_admin).length}
            </Typography>
            <Typography variant="body2" color="text.secondary">
              Administrators
            </Typography>
          </Paper>
        </Box>
        <Box sx={{ flex: 1 }}>
          <Paper elevation={1} sx={{ p: 2, textAlign: 'center' }}>
            <Typography variant="h4" color="success.main" fontWeight="bold">
              {staff.filter(s => s.email_verified).length}
            </Typography>
            <Typography variant="body2" color="text.secondary">
              Verified
            </Typography>
          </Paper>
        </Box>
      </Box>
    </Box>
  );
};

export default StaffList;
