import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';

const String ANDROID_BRIDGE_ROOT = "/storage/emulated/0/Android/bridge";
const String ANDROID_BRIDGE_WEB_PATH = "/storage/emulated/0/Android/bridge/web";


String getRootWebPath() {
  if (Platform.isAndroid) return ANDROID_BRIDGE_ROOT;

  return p.join(
    Platform.environment['USERPROFILE'] ?? '',
    'Bridge',
  );
}

String getWebPath() {
  if (Platform.isAndroid) return ANDROID_BRIDGE_WEB_PATH;

  return p.join(
    Platform.environment['USERPROFILE'] ?? '',
    'Bridge',
    'web',
  );
}

String getWebUrl() {
  final path = getWebPath().replaceAll(r'\', '/');
  if(Platform.isAndroid) return "http://172.16.20.201/TLPTAB/";
  return "file://$path/index.html";
}


Future<void> forceStoragePermission() async {
  while (true) {
    final status = await Permission.storage.request();
    if (status.isGranted) {
      break; // permission OK → sortie
    }
    // Optionnel : ouvrir les paramètres si refus permanent
    if (status.isPermanentlyDenied) {
      await openAppSettings();
    }
    await Future.delayed(const Duration(milliseconds: 300));
  }
}

