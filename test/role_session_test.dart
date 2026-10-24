import 'package:flutter_test/flutter_test.dart';
import 'package:guia_turistica_cusco/services/role_session.dart';

void main() {
  test(
    'inicia como visitante y cambia permisos al seleccionar colaborador',
    () {
      final session = RoleSession();
      addTearDown(session.dispose);

      expect(session.role, UserRole.visitor);
      expect(session.canManageContent, isFalse);

      session.selectRole(UserRole.collaborator);

      expect(session.role, UserRole.collaborator);
      expect(session.canManageContent, isTrue);

      session.selectRole(UserRole.visitor);
      expect(session.canManageContent, isFalse);
    },
  );
}
