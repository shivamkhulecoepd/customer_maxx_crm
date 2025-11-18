import 'package:flutter_test/flutter_test.dart';
import 'package:customer_maxx_crm/services/user_service.dart';
import 'package:customer_maxx_crm/models/user.dart';
import 'package:customer_maxx_crm/api/api_client.dart';

void main() {
  group('UserService', () {
    late UserService userService;
    late ApiClient apiClient;

    setUp(() {
      apiClient = ApiClient();
      userService = UserService(apiClient);
    });

    test('UserService can be instantiated', () {
      expect(userService, isNotNull);
    });

    test('User can be instantiated with required parameters', () {
      final user = User(
        id: '1',
        name: 'John Doe',
        email: 'john@example.com',
        role: 'admin',
      );

      expect(user.id, equals('1'));
      expect(user.name, equals('John Doe'));
      expect(user.email, equals('john@example.com'));
      expect(user.role, equals('admin'));
      expect(user.password, isNull);
    });

    test('User can be instantiated with optional password', () {
      final user = User(
        id: '1',
        name: 'John Doe',
        email: 'john@example.com',
        role: 'admin',
        password: 'secret123',
      );

      expect(user.password, equals('secret123'));
    });

    test('User can be created from JSON', () {
      final json = {
        'id': '1',
        'fullname': 'John Doe',
        'email': 'john@example.com',
        'role': 'admin',
      };

      final user = User.fromJson(json);

      expect(user.id, equals('1'));
      expect(user.name, equals('John Doe'));
      expect(user.email, equals('john@example.com'));
      expect(user.role, equals('admin'));
      expect(user.password, isNull);
    });

    test('User can be converted to JSON', () {
      final user = User(
        id: '1',
        name: 'John Doe',
        email: 'john@example.com',
        role: 'admin',
        password: 'secret123',
      );

      final json = user.toJson();

      expect(json['id'], equals('1'));
      expect(json['fullname'], equals('John Doe'));
      expect(json['email'], equals('john@example.com'));
      expect(json['role'], equals('admin'));
      expect(json['password'], equals('secret123'));
    });

    test('User.fromJson handles missing name field', () {
      final json = {
        'id': '1',
        'email': 'john@example.com',
        'role': 'admin',
      };

      final user = User.fromJson(json);

      expect(user.id, equals('1'));
      expect(user.name, equals(''));
      expect(user.email, equals('john@example.com'));
      expect(user.role, equals('admin'));
    });
  });
}