# Testing CustomerMaxx CRM

This directory contains tests for the CustomerMaxx CRM Flutter application.

## Running Tests

To run all tests, use the following command from the project root:

```bash
flutter test
```

To run a specific test file:

```bash
flutter test test/widget_test.dart
```

To run tests with coverage:

```bash
flutter test --coverage
```

## Test Structure

- `widget_test.dart` - Basic widget tests
- `auth_bloc_test.dart` - Tests for authentication BLoC events and states
- `user_model_test.dart` - Tests for User model serialization and instantiation

## Writing New Tests

1. Create a new test file in the `test/` directory
2. Follow the naming convention: `<unit>_test.dart`
3. Import necessary packages and the code under test
4. Group related tests using `group()`
5. Use `test()` or `testWidgets()` for individual test cases

## Dependencies

Tests use the standard Flutter testing framework:
- `flutter_test` - Core testing utilities
- `flutter_lints` - Linting rules for consistent code style