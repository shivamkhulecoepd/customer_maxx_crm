import 'dart:convert';
import 'dart:developer';
import 'package:customer_maxx_crm/utils/api_constants.dart';
import 'package:http/http.dart' as http;
import '../utils/api_exceptions.dart';

class ApiClient {
  final String baseUrl;
  String? authToken;
  
  static const int _timeout = 30; // seconds
  
  ApiClient({this.baseUrl = ApiConstants.baseUrl});
  
  // Set authentication token
  void setAuthToken(String token) {
    // Log the token setting
    // ignore: avoid_print
    print('Setting auth token. Previous token: $authToken, New token: $token');
    authToken = token;
    // ignore: avoid_print
    print('Auth token set. Current token: $authToken');
  }
  
  // Clear authentication token
  void clearAuthToken() {
    // Log the token clearing
    // ignore: avoid_print
    print('Clearing auth token. Current token: $authToken');
    authToken = null;
    // ignore: avoid_print
    print('Auth token cleared. New token: $authToken');
  }
  
  // Get headers with optional authentication
  Map<String, String> _getHeaders({bool authenticated = false}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (authenticated && authToken != null) {
      headers['Authorization'] = 'Bearer $authToken';
    }
    
    return headers;
  }
  
  // Generic GET request
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    bool authenticated = false,
  }) async {
    final headers = _getHeaders(authenticated: authenticated);
    log("Headers: $headers");
    try {
      // Parse the endpoint to extract existing query parameters
      final endpointUri = Uri.parse(endpoint);
      
      // Merge existing query parameters with new ones
      final mergedQueryParams = <String, dynamic>{};
      mergedQueryParams.addAll(endpointUri.queryParameters);
      if (queryParameters != null) {
        mergedQueryParams.addAll(queryParameters);
      }
      
      // Construct the full URI
      final fullUri = Uri.parse(baseUrl).replace(
        path: endpointUri.path,
        queryParameters: mergedQueryParams.isEmpty ? null : mergedQueryParams,
      );
      
      log("Full URI: $fullUri");
      final response = await http.get(fullUri, headers: headers).timeout(
        Duration(seconds: _timeout),
      );
      log("Response status code: ${response.statusCode}");
      log("Response body: ${response.body}");
      
      return _handleResponse(response);
    } on http.ClientException catch (e) {
      throw NetworkException('Network error: ${e.message}');
    } on Exception catch (e) {
      throw NetworkException('Request failed: $e');
    }
  }
  
  // Generic POST request
  Future<Map<String, dynamic>> post(
    String endpoint,
    dynamic body, {
    Map<String, dynamic>? queryParameters,
    bool authenticated = false,
  }) async {
    // Parse the endpoint to extract existing query parameters
    final endpointUri = Uri.parse(endpoint);
    
    // Merge existing query parameters with new ones
    final mergedQueryParams = <String, dynamic>{};
    mergedQueryParams.addAll(endpointUri.queryParameters);
    if (queryParameters != null) {
      mergedQueryParams.addAll(queryParameters);
    }
    
    // Construct the full URI
    final fullUri = Uri.parse(baseUrl).replace(
      path: endpointUri.path,
      queryParameters: mergedQueryParams.isEmpty ? null : mergedQueryParams,
    );
    
    final headers = _getHeaders(authenticated: authenticated);
    
    try {
      final response = await http.post(
        fullUri,
        headers: headers,
        body: jsonEncode(body),
      ).timeout(Duration(seconds: _timeout));
      
      return _handleResponse(response);
    } on http.ClientException catch (e) {
      throw NetworkException('Network error: ${e.message}');
    } on Exception catch (e) {
      throw NetworkException('Request failed: $e');
    }
  }
  
  // Generic POST multipart request for file uploads
  Future<Map<String, dynamic>> postMultiPart(
    String endpoint,
    List<int> fileBytes,
    String filename, {
    Map<String, dynamic>? queryParameters,
    bool authenticated = false,
  }) async {
    // Parse the endpoint to extract existing query parameters
    final endpointUri = Uri.parse(endpoint);
    
    // Merge existing query parameters with new ones
    final mergedQueryParams = <String, dynamic>{};
    mergedQueryParams.addAll(endpointUri.queryParameters);
    if (queryParameters != null) {
      mergedQueryParams.addAll(queryParameters);
    }
    
    // Construct the full URI
    final fullUri = Uri.parse(baseUrl).replace(
      path: endpointUri.path,
      queryParameters: mergedQueryParams.isEmpty ? null : mergedQueryParams,
    );
    
    final headers = _getHeaders(authenticated: authenticated);
    
    try {
      // Create multipart request
      final request = http.MultipartRequest('POST', fullUri);
      
      // Add headers
      request.headers.addAll(headers);
      
      // Add file
      final multipartFile = http.MultipartFile.fromBytes(
        'file', // Parameter name expected by the API
        fileBytes,
        filename: filename,
      );
      request.files.add(multipartFile);
      
      // Send request
      final response = await request.send().timeout(Duration(seconds: _timeout));
      
      // Get response body
      final responseBody = await response.stream.bytesToString();
      
      // Parse and handle response
      final decodedResponse = jsonDecode(responseBody);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return decodedResponse;
      } else {
        return _handleResponse(http.Response(responseBody, response.statusCode));
      }
    } on http.ClientException catch (e) {
      throw NetworkException('Network error: ${e.message}');
    } on Exception catch (e) {
      throw NetworkException('Request failed: $e');
    }
  }
  
  // Generic PUT request
  Future<Map<String, dynamic>> put(
    String endpoint,
    dynamic body, {
    Map<String, dynamic>? queryParameters,
    bool authenticated = false,
  }) async {
    // Parse the endpoint to extract existing query parameters
    final endpointUri = Uri.parse(endpoint);
    
    // Merge existing query parameters with new ones
    final mergedQueryParams = <String, dynamic>{};
    mergedQueryParams.addAll(endpointUri.queryParameters);
    if (queryParameters != null) {
      mergedQueryParams.addAll(queryParameters);
    }
    
    // Construct the full URI
    final fullUri = Uri.parse(baseUrl).replace(
      path: endpointUri.path,
      queryParameters: mergedQueryParams.isEmpty ? null : mergedQueryParams,
    );
    
    final headers = _getHeaders(authenticated: authenticated);
    
    try {
      final response = await http.put(
        fullUri,
        headers: headers,
        body: jsonEncode(body),
      ).timeout(Duration(seconds: _timeout));
      
      return _handleResponse(response);
    } on http.ClientException catch (e) {
      throw NetworkException('Network error: ${e.message}');
    } on Exception catch (e) {
      throw NetworkException('Request failed: $e');
    }
  }
  
  // Generic DELETE request
  Future<Map<String, dynamic>> delete(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    bool authenticated = false,
  }) async {
    // Parse the endpoint to extract existing query parameters
    final endpointUri = Uri.parse(endpoint);
    
    // Merge existing query parameters with new ones
    final mergedQueryParams = <String, dynamic>{};
    mergedQueryParams.addAll(endpointUri.queryParameters);
    if (queryParameters != null) {
      mergedQueryParams.addAll(queryParameters);
    }
    
    // Construct the full URI
    final fullUri = Uri.parse(baseUrl).replace(
      path: endpointUri.path,
      queryParameters: mergedQueryParams.isEmpty ? null : mergedQueryParams,
    );
    
    final headers = _getHeaders(authenticated: authenticated);
  
    try {
      final response = await http.delete(fullUri, headers: headers).timeout(
        Duration(seconds: _timeout),
      );
      
      return _handleResponse(response);
    } on http.ClientException catch (e) {
      throw NetworkException('Network error: ${e.message}');
    } on Exception catch (e) {
      throw NetworkException('Request failed: $e');
    }
  }
  
  // Handle HTTP response
  Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final responseBody = jsonDecode(response.body);
      
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseBody;
      } else if (response.statusCode == 401) {
        // Pass through the actual backend message if available
        String message = 'Unauthorized access';
        if (responseBody is Map && responseBody.containsKey('message')) {
          message = responseBody['message'];
        }
        throw UnauthorizedException(message);
      } else if (response.statusCode == 403) {
        // Pass through the actual backend message if available
        String message = 'Forbidden access';
        if (responseBody is Map && responseBody.containsKey('message')) {
          message = responseBody['message'];
        }
        throw ForbiddenException(message);
      } else if (response.statusCode == 404) {
        // Pass through the actual backend message if available
        String message = 'Resource not found';
        if (responseBody is Map && responseBody.containsKey('message')) {
          message = responseBody['message'];
        }
        throw NotFoundException(message);
      } else if (response.statusCode >= 400 && response.statusCode < 500) {
        // Pass through the actual backend message without technical prefixes
        String message = responseBody['message'] ?? 'Bad request';
        throw ClientException(message);
      } else if (response.statusCode >= 500) {
        // Pass through the actual backend message without technical prefixes
        String message = responseBody['message'] ?? 'Internal server error';
        throw ServerException(message);
      } else {
        // Pass through the actual backend message if available
        String message = 'HTTP ${response.statusCode}: ${response.reasonPhrase}';
        if (responseBody is Map && responseBody.containsKey('message')) {
          message = responseBody['message'];
        }
        throw ApiException(message);
      }
    } on FormatException {
      throw ApiException('Invalid response format');
    }
  }
}