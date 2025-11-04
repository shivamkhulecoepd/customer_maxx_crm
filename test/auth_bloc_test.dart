import 'package:flutter_test/flutter_test.dart';
import 'package:customer_maxx_crm/blocs/auth/auth_bloc.dart';

void main() {
  group('AuthEvent', () {
    test('AppStarted event has no props', () {
      final event = AppStarted();
      expect(event.props, isEmpty);
    });

    test('LoginRequested event has correct props', () {
      final event = LoginRequested(
        email: 'test@example.com',
        password: 'password123',
      );
      expect(event.props, containsAll(['test@example.com', 'password123', '']));
    });

    test('RegisterRequested event has correct props', () {
      final event = RegisterRequested(
        name: 'Test User',
        email: 'test@example.com',
        password: 'password123',
      );
      expect(event.props, containsAll(['Test User', 'test@example.com', 'password123', '']));
    });
  });

  group('AuthState', () {
    test('AuthInitial state has no props', () {
      final state = AuthInitial();
      expect(state.props, isEmpty);
    });

    test('AuthLoading state has no props', () {
      final state = AuthLoading();
      expect(state.props, isEmpty);
    });

    test('Unauthenticated state has no props', () {
      final state = Unauthenticated();
      expect(state.props, isEmpty);
    });

    test('AuthError state has correct props', () {
      final state = AuthError('Test error message');
      expect(state.props, contains('Test error message'));
    });
  });
}