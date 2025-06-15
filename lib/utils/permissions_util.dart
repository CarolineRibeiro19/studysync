import 'package:permission_handler/permission_handler.dart';

class PermissionsUtil {
  /// Solicita todas as permissões necessárias para Nearby + acesso a galeria/armazenamento.
  static Future<bool> requestNearbyAndStoragePermissions() async {
    final permissions = [
      Permission.bluetooth,
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.storage,
      Permission.photos, // para iOS
    ];

    Map<Permission, PermissionStatus> statuses = await permissions.request();

    // Verifica se todas foram concedidas
    return statuses.values.every((status) => status.isGranted);
  }

  /// Verifica se as permissões necessárias já foram concedidas
  static Future<bool> hasPermissions() async {
    final permissions = [
      Permission.bluetooth,
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.storage,
      Permission.photos, // para iOS
    ];

    for (final permission in permissions) {
      if (!await permission.isGranted) return false;
    }
    return true;
  }
}


