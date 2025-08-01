import axios from 'axios';

// API Configuration
const API_BASE_URL = process.env.REACT_APP_API_URL || 'http://localhost:3001';

// Create axios instance
const api = axios.create({
  baseURL: API_BASE_URL,
  timeout: 30000,
});

// Types
export interface Staff {
  id: number;
  email: string;
  phone?: string;
  display_name?: string;
  created_at: string;
  last_active_at?: string;
  staff_admin: boolean;
  email_verified: boolean;
}

export interface Analytics {
  total_customers: number;
  customers_with_points: number;
  total_points_distributed: number;
  recent_registrations: number;
}

export interface Transaction {
  id: number;
  points_amount: number;
  description: string;
  transaction_date: string;
  customer_id: number;
  customer_email: string;
  customer_name?: string;
  staff_id?: number;
  staff_email?: string;
  staff_name?: string;
}

export interface DashboardData {
  staff: Staff[];
  analytics: Analytics;
  recent_transactions: Transaction[];
}

export interface LoginResponse {
  return_code: string;
  message: string;
  user?: {
    id: number;
    email: string;
    display_name?: string;
    staff: boolean;
    staff_admin: boolean;
    auth_token: string;
    auth_token_expires: string;
  };
}

// Auth token management
let authToken: string | null = localStorage.getItem('admin_auth_token');

export const setAuthToken = (token: string) => {
  authToken = token;
  localStorage.setItem('admin_auth_token', token);
  api.defaults.headers.common['Authorization'] = `Bearer ${token}`;
};

export const clearAuthToken = () => {
  authToken = null;
  localStorage.removeItem('admin_auth_token');
  delete api.defaults.headers.common['Authorization'];
};

// Initialize auth token if exists
if (authToken) {
  api.defaults.headers.common['Authorization'] = `Bearer ${authToken}`;
}

// API Functions
export const adminApi = {
  // Authentication
  login: async (email: string, password: string): Promise<LoginResponse> => {
    const response = await api.post('/auth/login', { email, password });
    return response.data as LoginResponse;
  },

  logout: async (): Promise<void> => {
    if (authToken) {
      await api.post('/auth/logout', {});
    }
    clearAuthToken();
  },

  // Admin endpoints
  getDashboardData: async (): Promise<DashboardData> => {
    const response = await api.get('/admin/dashboard');
    const data = response.data as any;
    if (data.return_code === 'SUCCESS') {
      return data.dashboard;
    }
    throw new Error(data.message || 'Failed to fetch dashboard data');
  },

  getStaff: async (): Promise<Staff[]> => {
    const response = await api.get('/admin/staff');
    const data = response.data as any;
    if (data.return_code === 'SUCCESS') {
      return data.staff;
    }
    throw new Error(data.message || 'Failed to fetch staff data');
  },

  getAnalytics: async (): Promise<Analytics> => {
    const response = await api.get('/admin/analytics');
    const data = response.data as any;
    if (data.return_code === 'SUCCESS') {
      return data.analytics;
    }
    throw new Error(data.message || 'Failed to fetch analytics data');
  },

  getTransactions: async (limit: number = 20): Promise<Transaction[]> => {
    const response = await api.get(`/admin/transactions?limit=${limit}`);
    const data = response.data as any;
    if (data.return_code === 'SUCCESS') {
      return data.transactions;
    }
    throw new Error(data.message || 'Failed to fetch transactions');
  },
};

// Response interceptor for handling auth errors
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      clearAuthToken();
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

export default api;
