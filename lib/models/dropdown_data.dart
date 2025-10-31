import 'user.dart';

class DropdownData {
  final List<UserRole> leadManagers;
  final List<UserRole> baSpecialists;

  DropdownData({
    required this.leadManagers,
    required this.baSpecialists,
  });

  factory DropdownData.fromJson(Map<String, dynamic> json) {
    final leadManagersList = (json['lead_managers'] as List)
        .map((item) => UserRole.fromJson(item))
        .toList();

    final baSpecialistsList = (json['ba_specialists'] as List)
        .map((item) => UserRole.fromJson(item))
        .toList();

    return DropdownData(
      leadManagers: leadManagersList,
      baSpecialists: baSpecialistsList,
    );
  }
}

class UserRolesResponse {
  final List<UserRole> roles;

  UserRolesResponse({
    required this.roles,
  });

  factory UserRolesResponse.fromJson(Map<String, dynamic> json) {
    final rolesList = (json['roles'] as List)
        .map((item) => UserRole.fromJson(item))
        .toList();

    return UserRolesResponse(
      roles: rolesList,
    );
  }
}