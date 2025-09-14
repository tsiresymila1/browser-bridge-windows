import 'dart:io';

import 'package:browser_bridge/generated/assets.dart';
import 'package:flutter/services.dart';

import '../constant.dart';

createWebFile() async {
  final dir = Directory(getWebPath());
  if (!dir.existsSync()) {
    await dir.create(recursive: true);
  }
  (await File("${dir.path}/index.html").create())
      .writeAsString(await rootBundle.loadString(Assets.appIndex));
}
