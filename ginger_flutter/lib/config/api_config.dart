class ApiConfig {
  // Update this URL to match your server configuration
 
  static const String baseUrl = 'http://192.168.1.186:3000'; // work
  static const String baseUrl = 'http://192.168.1.173:3000'; // shrewsbury
  
  // API endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String logoutEndpoint = '/auth/logout';
  static const String validateTokenEndpoint = '/auth/validate';
  
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
