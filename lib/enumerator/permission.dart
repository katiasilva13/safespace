enum Permission { DEV, DEFAULT, MOD }

class PermissionHelper {
  static bool isDev(String permission) {
    return (permission.compareTo(Permission.DEV.toString()) == 0);
  }

  static bool isDefault(String permission) {
    return (permission.compareTo(Permission.DEFAULT.toString()) == 0);
  }

  static bool isMod(String permission) {
    return (permission.compareTo(Permission.MOD.toString()) == 0);
  }
}
