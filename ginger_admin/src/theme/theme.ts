import { createTheme } from '@mui/material/styles';

// Material Design 3 inspired theme for Ginger Admin
export const theme = createTheme({
  palette: {
    mode: 'light',
    primary: {
      main: '#6750A4', // Material 3 primary
      light: '#7F67BE',
      dark: '#4F378B',
      contrastText: '#FFFFFF',
    },
    secondary: {
      main: '#625B71', // Material 3 secondary
      light: '#7A7289',
      dark: '#4A4458',
      contrastText: '#FFFFFF',
    },
    tertiary: {
      main: '#7D5260',
      light: '#9A6B79',
      dark: '#633B48',
      contrastText: '#FFFFFF',
    },
    error: {
      main: '#BA1A1A',
      light: '#DE3730',
      dark: '#93000A',
      contrastText: '#FFFFFF',
    },
    warning: {
      main: '#BC6C00',
      light: '#E08B00',
      dark: '#8C5000',
      contrastText: '#FFFFFF',
    },
    success: {
      main: '#006E1C',
      light: '#00A532',
      dark: '#004F15',
      contrastText: '#FFFFFF',
    },
    background: {
      default: '#FEF7FF', // Material 3 surface
      paper: '#FFFFFF',
    },
    surface: {
      main: '#FEF7FF',
      variant: '#E7E0EC',
    },
    outline: {
      main: '#79747E',
      variant: '#CAC4D0',
    },
    text: {
      primary: '#1D1B20',
      secondary: '#49454F',
    },
  },
  typography: {
    fontFamily: '"Roboto", "Helvetica", "Arial", sans-serif',
    h1: {
      fontSize: '2.25rem',
      fontWeight: 400,
      lineHeight: 1.2,
      letterSpacing: '-0.02em',
    },
    h2: {
      fontSize: '2rem',
      fontWeight: 400,
      lineHeight: 1.3,
      letterSpacing: '-0.01em',
    },
    h3: {
      fontSize: '1.75rem',
      fontWeight: 400,
      lineHeight: 1.3,
    },
    h4: {
      fontSize: '1.5rem',
      fontWeight: 400,
      lineHeight: 1.4,
    },
    h5: {
      fontSize: '1.25rem',
      fontWeight: 400,
      lineHeight: 1.4,
    },
    h6: {
      fontSize: '1.125rem',
      fontWeight: 500,
      lineHeight: 1.4,
    },
    body1: {
      fontSize: '1rem',
      fontWeight: 400,
      lineHeight: 1.5,
    },
    body2: {
      fontSize: '0.875rem',
      fontWeight: 400,
      lineHeight: 1.43,
    },
    button: {
      fontSize: '0.875rem',
      fontWeight: 500,
      lineHeight: 1.25,
      textTransform: 'none' as const,
    },
    caption: {
      fontSize: '0.75rem',
      fontWeight: 400,
      lineHeight: 1.33,
    },
  },
  shape: {
    borderRadius: 12, // Material 3 uses more rounded corners
  },
  components: {
    MuiButton: {
      styleOverrides: {
        root: {
          borderRadius: 20,
          textTransform: 'none',
          fontWeight: 500,
          padding: '10px 24px',
        },
        contained: {
          boxShadow: 'none',
          '&:hover': {
            boxShadow: '0px 1px 2px rgba(0, 0, 0, 0.3), 0px 1px 3px 1px rgba(0, 0, 0, 0.15)',
          },
        },
        outlined: {
          borderWidth: '1px',
          '&:hover': {
            borderWidth: '1px',
          },
        },
      },
    },
    MuiCard: {
      styleOverrides: {
        root: {
          borderRadius: 12,
          boxShadow: '0px 1px 2px rgba(0, 0, 0, 0.3), 0px 1px 3px 1px rgba(0, 0, 0, 0.15)',
          border: 'none',
        },
      },
    },
    MuiPaper: {
      styleOverrides: {
        root: {
          borderRadius: 12,
        },
        elevation1: {
          boxShadow: '0px 1px 2px rgba(0, 0, 0, 0.3), 0px 1px 3px 1px rgba(0, 0, 0, 0.15)',
        },
        elevation2: {
          boxShadow: '0px 1px 2px rgba(0, 0, 0, 0.3), 0px 2px 6px 2px rgba(0, 0, 0, 0.15)',
        },
      },
    },
    MuiChip: {
      styleOverrides: {
        root: {
          borderRadius: 8,
          fontWeight: 500,
        },
      },
    },
    MuiTextField: {
      styleOverrides: {
        root: {
          '& .MuiOutlinedInput-root': {
            borderRadius: 12,
          },
        },
      },
    },
    MuiTab: {
      styleOverrides: {
        root: {
          textTransform: 'none',
          fontWeight: 500,
          fontSize: '0.875rem',
        },
      },
    },
    MuiAppBar: {
      styleOverrides: {
        root: {
          boxShadow: '0px 1px 2px rgba(0, 0, 0, 0.3), 0px 1px 3px 1px rgba(0, 0, 0, 0.15)',
        },
      },
    },
  },
});

// Extend the theme to include custom colors
declare module '@mui/material/styles' {
  interface Palette {
    tertiary: Palette['primary'];
    surface: {
      main: string;
      variant: string;
    };
    outline: {
      main: string;
      variant: string;
    };
  }

  interface PaletteOptions {
    tertiary?: PaletteOptions['primary'];
    surface?: {
      main?: string;
      variant?: string;
    };
    outline?: {
      main?: string;
      variant?: string;
    };
  }
}
