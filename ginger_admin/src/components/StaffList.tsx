import React, { useState } from 'react';
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
  Button,
  TextField,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  IconButton,
  Alert,
  Snackbar,
  CircularProgress,
} from '@mui/material';
import {
  AdminPanelSettings,
  Person,
  Verified,
  Warning,
  Add as AddIcon,
  PersonRemove as RemoveIcon,
  PersonAdd as AddPersonIcon,
} from '@mui/icons-material';
import { Staff, adminApi } from '../services/api';

interface StaffListProps {
  staff: Staff[];
  onStaffUpdate: () => void;
}

const StaffList: React.FC<StaffListProps> = ({ staff, onStaffUpdate }) => {
  const [addDialogOpen, setAddDialogOpen] = useState(false);
  const [removeDialogOpen, setRemoveDialogOpen] = useState(false);
  const [selectedStaff, setSelectedStaff] = useState<Staff | null>(null);
  const [email, setEmail] = useState('');
  const [loading, setLoading] = useState(false);
  const [snackbar, setSnackbar] = useState<{
    open: boolean;
    message: string;
    severity: 'success' | 'error';
  }>({ open: false, message: '', severity: 'success' });
  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    });
  };

  const handleAddStaff = async () => {
    if (!email.trim()) {
      setSnackbar({
        open: true,
        message: 'Please enter an email address',
        severity: 'error'
      });
      return;
    }

    setLoading(true);
    try {
      await adminApi.addStaffMember(email.trim());
      setSnackbar({
        open: true,
        message: 'Staff member added successfully',
        severity: 'success'
      });
      setAddDialogOpen(false);
      setEmail('');
      onStaffUpdate();
    } catch (error: any) {
      setSnackbar({
        open: true,
        message: error.message || 'Failed to add staff member',
        severity: 'error'
      });
    } finally {
      setLoading(false);
    }
  };

  const handleRemoveStaff = async () => {
    if (!selectedStaff) return;

    setLoading(true);
    try {
      await adminApi.removeStaffMember(selectedStaff.id);
      setSnackbar({
        open: true,
        message: 'Staff member removed successfully',
        severity: 'success'
      });
      setRemoveDialogOpen(false);
      setSelectedStaff(null);
      onStaffUpdate();
    } catch (error: any) {
      setSnackbar({
        open: true,
        message: error.message || 'Failed to remove staff member',
        severity: 'error'
      });
    } finally {
      setLoading(false);
    }
  };

  const openRemoveDialog = (staffMember: Staff) => {
    setSelectedStaff(staffMember);
    setRemoveDialogOpen(true);
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
            <Box sx={{ display: 'flex', gap: 2, alignItems: 'center' }}>
              <Chip
                label={`${staff.length} staff member${staff.length !== 1 ? 's' : ''}`}
                color="primary"
                variant="outlined"
              />
              <Button
                variant="contained"
                startIcon={<AddPersonIcon />}
                onClick={() => setAddDialogOpen(true)}
                sx={{
                  backgroundColor: '#603d22',
                  '&:hover': { backgroundColor: '#4a2f1a' }
                }}
              >
                Add Staff
              </Button>
            </Box>
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
                    <TableCell><strong>Actions</strong></TableCell>
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
                      <TableCell>
                        <IconButton
                          color="error"
                          onClick={() => openRemoveDialog(member)}
                          size="small"
                          title="Remove staff privileges"
                        >
                          <RemoveIcon />
                        </IconButton>
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

      {/* Add Staff Dialog */}
      <Dialog open={addDialogOpen} onClose={() => setAddDialogOpen(false)} maxWidth="sm" fullWidth>
        <DialogTitle>Add Staff Member</DialogTitle>
        <DialogContent>
          <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>
            Enter the email address of an existing user to grant them staff privileges.
          </Typography>
          <TextField
            autoFocus
            margin="dense"
            label="Email Address"
            type="email"
            fullWidth
            variant="outlined"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            disabled={loading}
            placeholder="user@example.com"
          />
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setAddDialogOpen(false)} disabled={loading}>
            Cancel
          </Button>
          <Button
            onClick={handleAddStaff}
            variant="contained"
            disabled={loading || !email.trim()}
            sx={{
              backgroundColor: '#603d22',
              '&:hover': { backgroundColor: '#4a2f1a' }
            }}
          >
            {loading ? <CircularProgress size={20} /> : 'Add Staff'}
          </Button>
        </DialogActions>
      </Dialog>

      {/* Remove Staff Dialog */}
      <Dialog open={removeDialogOpen} onClose={() => setRemoveDialogOpen(false)} maxWidth="sm" fullWidth>
        <DialogTitle>Remove Staff Member</DialogTitle>
        <DialogContent>
          <Typography variant="body1" sx={{ mb: 2 }}>
            Are you sure you want to remove staff privileges from{' '}
            <strong>{selectedStaff?.display_name || selectedStaff?.email}</strong>?
          </Typography>
          <Typography variant="body2" color="text.secondary">
            This action will revoke their staff access but will not delete their user account.
          </Typography>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setRemoveDialogOpen(false)} disabled={loading}>
            Cancel
          </Button>
          <Button
            onClick={handleRemoveStaff}
            variant="contained"
            color="error"
            disabled={loading}
          >
            {loading ? <CircularProgress size={20} /> : 'Remove Staff'}
          </Button>
        </DialogActions>
      </Dialog>

      {/* Snackbar for notifications */}
      <Snackbar
        open={snackbar.open}
        autoHideDuration={6000}
        onClose={() => setSnackbar({ ...snackbar, open: false })}
      >
        <Alert
          onClose={() => setSnackbar({ ...snackbar, open: false })}
          severity={snackbar.severity}
          sx={{ width: '100%' }}
        >
          {snackbar.message}
        </Alert>
      </Snackbar>
    </Box>
  );
};

export default StaffList;
