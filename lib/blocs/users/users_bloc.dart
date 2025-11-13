import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:customer_maxx_crm/models/user.dart';
import 'package:customer_maxx_crm/services/user_service.dart';
import 'package:customer_maxx_crm/utils/api_service_locator.dart';
import 'users_event.dart';
import 'users_state.dart';

class UsersBloc extends Bloc<UsersEvent, UsersState> {
  final UserService _userService = ServiceLocator.userService;

  UsersBloc() : super(UsersState.initial()) {
    on<LoadAllUsers>(_onLoadAllUsers);
    on<AddUser>(_onAddUser);
    on<UpdateUser>(_onUpdateUser);
    on<DeleteUser>(_onDeleteUser);
  }

  Future<void> _onLoadAllUsers(
    LoadAllUsers event,
    Emitter<UsersState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      print('Loading all users...');
      final users = await _userService.getAllUsersNoPagination();
      print('Users loaded successfully: ${users.length} users');
      emit(state.copyWith(isLoading: false, users: users));
    } catch (e) {
      print('Error fetching users: $e');
      log('Error fetching users: $e');
      emit(state.copyWith(
        isLoading: false,
        error: 'Error fetching users: $e',
      ));
    }
  }

  Future<void> _onAddUser(AddUser event, Emitter<UsersState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      // Use the password from the user object if available, otherwise use a default
      final password = event.user.password ?? 'defaultPassword123';
      log('Password: $password');
      final response = await _userService.createUser(event.user, password);
      log('Response from createUser: $response');
      final success = response['status'] == 'success';
      if (success) {
        // Instead of manually adding the user to the list, reload all users from the server
        // This ensures consistency and that we have the most up-to-date data
        try {
          final users = await _userService.getAllUsersNoPagination();
          emit(state.copyWith(isLoading: false, users: users));
        } catch (e) {
          // If reloading fails, fall back to adding the user manually
          final userId = response['user_id']?.toString() ?? '0';
          final createdUser = User(
            id: userId,
            name: event.user.name,
            email: event.user.email,
            role: event.user.role,
            password: event.user.password,
          );
          final updatedUsers = List<User>.from(state.users)..add(createdUser);
          emit(state.copyWith(isLoading: false, users: updatedUsers));
        }
      } else {
        emit(state.copyWith(
          isLoading: false,
          error: 'Failed to add user: ${response['message'] ?? 'Unknown error'}',
        ));
      }
    } catch (e) {
      log('Error adding user: $e');
      emit(state.copyWith(
        isLoading: false,
        error: 'Error adding user: $e',
      ));
    }
  }

  Future<void> _onUpdateUser(
    UpdateUser event,
    Emitter<UsersState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final response = await _userService.updateUser(event.user);
      final success = response['status'] == 'success';
      if (success) {
        // Instead of manually updating the user in the list, reload all users from the server
        // This ensures consistency and that we have the most up-to-date data
        try {
          final users = await _userService.getAllUsersNoPagination();
          emit(state.copyWith(isLoading: false, users: users));
        } catch (e) {
          // If reloading fails, fall back to updating the user manually
          final updatedUsers = List<User>.from(state.users);
          final index = updatedUsers.indexWhere((u) => u.id == event.user.id);
          if (index != -1) {
            updatedUsers[index] = event.user;
          }
          emit(state.copyWith(isLoading: false, users: updatedUsers));
        }
      } else {
        emit(state.copyWith(
          isLoading: false,
          error: 'Failed to update user: ${response['message'] ?? 'Unknown error'}',
        ));
      }
    } catch (e) {
      log('Error updating user: $e');
      emit(state.copyWith(
        isLoading: false,
        error: 'Error updating user: $e',
      ));
    }
  }

  Future<void> _onDeleteUser(
    DeleteUser event,
    Emitter<UsersState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final response = await _userService.deleteUser(int.parse(event.id));
      final success = response['status'] == 'success';
      if (success) {
        // Instead of manually removing the user from the list, reload all users from the server
        // This ensures consistency and that we have the most up-to-date data
        try {
          final users = await _userService.getAllUsersNoPagination();
          emit(state.copyWith(isLoading: false, users: users));
        } catch (e) {
          // If reloading fails, fall back to removing the user manually
          final updatedUsers =
              state.users.where((user) => user.id != event.id).toList();
          emit(state.copyWith(isLoading: false, users: updatedUsers));
        }
      } else {
        emit(state.copyWith(
          isLoading: false,
          error: 'Failed to delete user',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Error deleting user: $e',
      ));
    }
  }
}