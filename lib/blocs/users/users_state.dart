import 'package:equatable/equatable.dart';
import 'package:customer_maxx_crm/models/user.dart';

class UsersState extends Equatable {
  final List<User> users;
  final bool isLoading;
  final String? error;

  const UsersState({
    required this.users,
    required this.isLoading,
    this.error,
  });

  factory UsersState.initial() {
    return const UsersState(
      users: [],
      isLoading: false,
    );
  }

  UsersState copyWith({
    List<User>? users,
    bool? isLoading,
    String? error,
  }) {
    return UsersState(
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [users, isLoading, error];
}