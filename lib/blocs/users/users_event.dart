import 'package:equatable/equatable.dart';
import 'package:customer_maxx_crm/models/user.dart';

abstract class UsersEvent extends Equatable {
  const UsersEvent();

  @override
  List<Object?> get props => [];
}

class LoadAllUsers extends UsersEvent {}

class AddUser extends UsersEvent {
  final User user;

  const AddUser(this.user);

  @override
  List<Object?> get props => [user];
}

class UpdateUser extends UsersEvent {
  final User user;

  const UpdateUser(this.user);

  @override
  List<Object?> get props => [user];
}

class DeleteUser extends UsersEvent {
  final int id;

  const DeleteUser(this.id);

  @override
  List<Object?> get props => [id];
}