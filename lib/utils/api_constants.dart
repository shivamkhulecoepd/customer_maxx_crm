class ApiConstants {
  // Base URL for the API
  static const String baseUrl = 'https://flutter.customermaxxcrm.com';
  
  // Timeout for API requests (in seconds)
  static const int requestTimeout = 30;
  
  // Pagination defaults
  static const int defaultPage = 1;
  static const int defaultLimit = 10;
  
  // Storage keys
  static const String authTokenKey = 'auth_token';
  static const String userRoleKey = 'user_role';
  static const String userIdKey = 'user_id';
  static const String userFullNameKey = 'user_full_name';
}

class HttpStatusCodes {
  static const int ok = 200;
  static const int created = 201;
  static const int noContent = 204;
  static const int badRequest = 400;
  static const int unauthorized = 401;
  static const int forbidden = 403;
  static const int notFound = 404;
  static const int methodNotAllowed = 405;
  static const int internalServerError = 500;
  static const int badGateway = 502;
  static const int serviceUnavailable = 503;
}