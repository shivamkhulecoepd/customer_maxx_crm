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
      final users = await _userService.getAllUsers();
      emit(state.copyWith(isLoading: false, users: users));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Error fetching users: $e',
      ));
    }
  }

  Future<void> _onAddUser(AddUser event, Emitter<UsersState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      // For now, we'll need to provide a default password
      final response = await _userService.createUser(event.user, 'defaultPassword123');
      final success = response['status'] == 'success';
      if (success) {
        final updatedUsers = List<User>.from(state.users)..add(event.user);
        emit(state.copyWith(isLoading: false, users: updatedUsers));
      } else {
        emit(state.copyWith(
          isLoading: false,
          error: 'Failed to add user',
        ));
      }
    } catch (e) {
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
        final updatedUsers = List<User>.from(state.users);
        final index = updatedUsers.indexWhere((u) => u.id == event.user.id);
        if (index != -1) {
          updatedUsers[index] = event.user;
        }
        emit(state.copyWith(isLoading: false, users: updatedUsers));
      } else {
        emit(state.copyWith(
          isLoading: false,
          error: 'Failed to update user',
        ));
      }
    } catch (e) {
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
        final updatedUsers =
            state.users.where((user) => user.id != event.id).toList();
        emit(state.copyWith(isLoading: false, users: updatedUsers));
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