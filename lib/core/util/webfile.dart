import 'dart:io';

import 'package:browser_bridge/generated/assets.dart';
import 'package:flutter/services.dart';

import '../constant.dart';

createWebFile() async {
  final dir = Directory(getWebPath());
  if (!dir.existsSync()) {
    await dir.create(recursive: true);
  }
  final htmlFile = File("${dir.path}/index.html");
  if (!await htmlFile.exists()){
    (await htmlFile.create())
        .writeAsString(await rootBundle.loadString(Assets.appIndex));
  }
}
