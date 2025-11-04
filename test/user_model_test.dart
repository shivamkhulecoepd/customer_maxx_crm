import 'package:flutter_test/flutter_test.dart';
import 'package:customer_maxx_crm/models/user.dart';

void main() {
  group('User', () {
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
      expect(json['name'], equals('John Doe'));
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

  group('UserRole', () {
    test('UserRole can be instantiated with required parameters', () {
      final userRole = UserRole(
        id: '1',
        name: 'Admin',
      );

      expect(userRole.id, equals('1'));
      expect(userRole.name, equals('Admin'));
    });

    test('UserRole can be created from JSON', () {
      final json = {
        'id': '1',
        'name': 'Admin',
      };

      final userRole = UserRole.fromJson(json);

      expect(userRole.id, equals('1'));
      expect(userRole.name, equals('Admin'));
    });

    test('UserRole can be converted to JSON', () {
      final userRole = UserRole(
        id: '1',
        name: 'Admin',
      );

      final json = userRole.toJson();

      expect(json['id'], equals('1'));
      expect(json['name'], equals('Admin'));
    });
  });
}