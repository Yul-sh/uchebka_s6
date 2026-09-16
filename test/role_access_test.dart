import 'package:flutter_test/flutter_test.dart';
import 'package:fly_y/models/role.dart';

void main() {
  test('клиент видит каталог и свои брони, но не каталог на запись', () {
    expect(RoleAccess.allows(Role.client, AppOp.viewCatalog), isTrue);
    expect(RoleAccess.allows(Role.client, AppOp.viewOwnBookings), isTrue);
    expect(RoleAccess.allows(Role.client, AppOp.extendOwnBooking), isTrue);
    expect(RoleAccess.allows(Role.client, AppOp.manageCatalog), isFalse);
    expect(RoleAccess.allows(Role.client, AppOp.manageUsers), isFalse);
  });

  test('менеджер ведёт каталог и выдачи, без админки', () {
    expect(RoleAccess.allows(Role.manager, AppOp.manageCatalog), isTrue);
    expect(RoleAccess.allows(Role.manager, AppOp.manageClients), isTrue);
    expect(RoleAccess.allows(Role.manager, AppOp.closeBooking), isTrue);
    expect(RoleAccess.allows(Role.manager, AppOp.hardDelete), isFalse);
    expect(RoleAccess.allows(Role.manager, AppOp.manageUsers), isFalse);
    expect(RoleAccess.allows(Role.manager, AppOp.viewOwnBookings), isFalse);
  });

  test('админ удаляет навсегда, роли и статистику, без выдач', () {
    expect(RoleAccess.allows(Role.admin, AppOp.hardDelete), isTrue);
    expect(RoleAccess.allows(Role.admin, AppOp.restore), isTrue);
    expect(RoleAccess.allows(Role.admin, AppOp.manageUsers), isTrue);
    expect(RoleAccess.allows(Role.admin, AppOp.viewStats), isTrue);
    expect(RoleAccess.allows(Role.admin, AppOp.issueBooking), isFalse);
    expect(RoleAccess.allows(Role.admin, AppOp.manageClients), isFalse);
  });

  test('продление брони только у клиента', () {
    expect(RoleAccess.allows(Role.client, AppOp.extendOwnBooking), isTrue);
    expect(RoleAccess.allows(Role.manager, AppOp.extendOwnBooking), isFalse);
    expect(RoleAccess.allows(Role.admin, AppOp.extendOwnBooking), isFalse);
  });

  test('роли не являются «одной функцией с разным объёмом»', () {
    expect(RoleAccess.allows(Role.admin, AppOp.manageCatalog), isFalse);
    expect(RoleAccess.allows(Role.client, AppOp.closeBooking), isFalse);
    expect(RoleAccess.allows(Role.manager, AppOp.viewStats), isFalse);
  });
}
