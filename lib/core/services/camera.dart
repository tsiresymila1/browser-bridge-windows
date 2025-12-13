import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../models/args/args.dart';
import 'service.dart';

class CameraService extends JsService {
  @override
  FutureOr call({required BuildContext context, required JsArgs jsArgs}) async {
    switch (jsArgs.method) {
      case 'pickPhoto':
        final result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          withData: true,
        );

        if (result == null || result.files.isEmpty) return null;

        final file = result.files.first;
        final bytes = file.bytes!;

        return {
          "path": file.path,
          "name": file.name,
          "type": file.extension != null
              ? "image/${file.extension}"
              : "image/jpeg",
          "size": bytes.length,
          "base64":
          "data:image/${file.extension ?? 'jpeg'};base64,${base64Encode(bytes)}",
        };

      default:
        return null;
    }
  }
}
