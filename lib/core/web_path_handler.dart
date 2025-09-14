import 'dart:io';

import 'package:browser_bridge/core/util/log.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:mime/mime.dart';

class CustomWebPathHandler extends CustomPathHandler {
  final String dir;

  CustomWebPathHandler({required super.path, required this.dir});

  @override
  Future<WebResourceResponse?> handle(String path) async {
    try {
      final data = await File("$dir/$path").readAsBytes();
      return WebResourceResponse(contentType: lookupMimeType(path), data: data);
    } catch (e, s) {
      logger.e("ERROR", error: e, stackTrace: s);
      try {
        final data = await rootBundle.load("assets/app/error.html");
        return WebResourceResponse(
          contentType: lookupMimeType(path),
          data: data.buffer.asUint8List(),
        );
      } catch (e) {
        if (kDebugMode) {
          logger.e(e);
        }
      }
    }
    return WebResourceResponse(data: null, statusCode: 200);
  }
}
