import 'package:safespace/helpers/dart_enum_helper.dart';

enum Permission { DEV, DEFAULT, MOD }

class PermissionHelper {
  static bool isDev(String permission) {
    return (permission.compareTo(Permission.DEV.toString()) == 0);
  }

  static bool isDefault(String permission) {
    return (permission.compareTo(enumToString(Permission.DEFAULT)) == 0);
  }

  static bool isMod(String permission) {
    return (permission.compareTo(Permission.MOD.toString()) == 0);
  }
}
