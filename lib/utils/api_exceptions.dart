class ApiException implements Exception {
  final String message;
  
  ApiException(this.message);
  
  @override
  // String toString() => 'ApiException: $message';
  String toString() => message;
}

class NetworkException implements Exception {
  final String message;
  
  NetworkException(this.message);
  
  @override
  // String toString() => 'NetworkException: $message';
  String toString() => message;
}

class UnauthorizedException implements Exception {
  final String message;
  
  UnauthorizedException(this.message);
  
  @override
  // String toString() => 'UnauthorizedException: $message';
  String toString() => message;
}

class ForbiddenException implements Exception {
  final String message;
  
  ForbiddenException(this.message);
  
  @override
  // String toString() => 'ForbiddenException: $message';
  String toString() => message;
}

class NotFoundException implements Exception {
  final String message;
  
  NotFoundException(this.message);
  
  @override
  // String toString() => 'NotFoundException: $message';
  String toString() => message;
}

class ClientException implements Exception {
  final String message;
  
  ClientException(this.message);
  
  @override
  // String toString() => 'ClientException: $message';
  String toString() => message;
}

class ServerException implements Exception {
  final String message;
  
  ServerException(this.message);
  
  @override
  // String toString() => 'ServerException: $message';
  String toString() => message;
}

class ValidationException implements Exception {
  final String message;
  
  ValidationException(this.message);
  
  @override
  // String toString() => 'ValidationException: $message';
  String toString() => message;
}