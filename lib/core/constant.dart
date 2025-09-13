import 'dart:io';

import 'package:path/path.dart' as p;

getWebPath() {
  final webPath = p.join(
    Platform.environment['USERPROFILE'] ?? '', // C:\Users\<username>
    'Bridge',
    'web',
  );
  return webPath;
}

getRootWebPath() {
  final webPath = p.join(
    Platform.environment['USERPROFILE'] ?? '', // C:\Users\<username>
    'Bridge',
  );
  return webPath;
}
