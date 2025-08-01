# Ginger Admin Dashboard

A React-based admin dashboard for managing the Ginger coffee loyalty app. This dashboard allows managers to view staff members, customer analytics, and recent transactions.

## Features

- **Staff Management**: View all staff members with their roles, verification status, and activity
- **Customer Analytics**: Track customer engagement, points distribution, and growth metrics
- **Recent Transactions**: Monitor point transactions and reward redemptions in real-time
- **Secure Authentication**: Staff admin privileges required for access

## Getting Started

### Prerequisites

- Node.js (v14 or higher)
- The Ginger server running on port 3001
- Staff admin account in the database

### Installation

1. Install dependencies:
```bash
npm install
```

2. Set up environment variables:
Create a `.env` file with:
```
REACT_APP_API_URL=http://localhost:3001
```

3. Start the development server:
```bash
npm start
```

The dashboard will open at [http://localhost:3000](http://localhost:3000).

## Usage

### Login
- Only users with `staff_admin = true` can access the dashboard
- Use your staff email and password to log in

### Dashboard Sections

#### Overview Tab
- Quick summary of customer analytics
- Recent transaction activity
- Key performance metrics

#### Staff Management Tab
- Complete list of all staff members
- Role assignments (Staff vs Admin)
- Email verification status
- Join dates and last activity

#### Customer Analytics Tab
- Total customer count
- Customer engagement rates
- Points distribution statistics
- Growth trends and insights

## API Endpoints Used

The dashboard connects to these server endpoints:

- `POST /auth/login` - Authentication
- `GET /admin/dashboard` - Combined dashboard data
- `GET /admin/staff` - Staff member list
- `GET /admin/analytics` - Customer analytics
- `GET /admin/transactions` - Recent transactions

## Development

### Available Scripts

- `npm start` - Development server
- `npm run build` - Production build
- `npm test` - Run tests

### Project Structure

```
src/
├── components/          # React components
│   ├── Login.tsx       # Login form
│   ├── Dashboard.tsx   # Main dashboard
│   ├── StaffList.tsx   # Staff management
│   ├── Analytics.tsx   # Customer analytics
│   └── RecentTransactions.tsx
├── services/
│   └── api.ts          # API service layer
└── App.tsx             # Main app component
```

## Security

- JWT token-based authentication
- Staff admin privilege verification
- Secure token storage in localStorage
- Automatic logout on token expiration

## Deployment

1. Build the production version:
```bash
npm run build
```

2. Deploy the `build` folder to your web server
3. Update `REACT_APP_API_URL` to point to your production API

## Support

For issues or questions, please refer to the main Ginger project documentation.
