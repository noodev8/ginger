class ApiConfig {


 //static const String baseUrl = 'http://10.0.2.2:3001'; // Android emulator
//static const String baseUrl = 'http://localhost:3001'; // iOS simulator / web
//static const String baseUrl = 'http://127.0.0.1:3001'; // Alternative localhost
 static const String baseUrl = 'http://192.168.0.15:3001'; // welshpool - updated to port 3001
 //static const String baseUrl = 'http://192.168.1.187:3001'; // work - updated to port 3001
//static const String baseUrl = 'http://192.168.1.173:3001'; // shrewsbury - updated to port 3001

  // Authentication endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String logoutEndpoint = '/auth/logout';
  static const String validateTokenEndpoint = '/auth/validate';

  // QR Code endpoints
  static const String qrCodesEndpoint = '/qr-codes';
  static const String validateQRCodeEndpoint = '/qr-codes/validate';

  // Points endpoints
  static const String pointsEndpoint = '/points';
  static const String addPointsEndpoint = '/points/add';
  static const String canScanEndpoint = '/points/can-scan';
  
  // Request timeout duration
  static const Duration requestTimeout = Duration(seconds: 30);
  
  // Common headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
  };
  
  /// Get authorization header with token
  static Map<String, String> getAuthHeaders(String token) {
    return {
      ...defaultHeaders,
      'Authorization': 'Bearer $token',
    };
  }
}
