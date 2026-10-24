import 'package:flutter/foundation.dart';

enum UserRole {
  visitor('Visitante'),
  collaborator('Colaborador');

  const UserRole(this.label);

  final String label;
}

class RoleSession extends ChangeNotifier {
  UserRole _role = UserRole.visitor;

  UserRole get role => _role;
  bool get canManageContent => _role == UserRole.collaborator;

  void selectRole(UserRole role) {
    if (_role == role) return;
    _role = role;
    notifyListeners();
  }
}
