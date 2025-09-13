import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/args/args.dart';
import 'service.dart';

class CameraService extends JsService {
  final ImagePicker _picker = ImagePicker();

  @override
  FutureOr call({required BuildContext context, required JsArgs jsArgs}) async {
    switch (jsArgs.method) {
      case 'takePicture':
        XFile? file = await _picker.pickImage(source: ImageSource.camera);
        if (file != null) {
          return {
            "path": file.path,
            "name": file.name,
            "type": file.mimeType,
            "size": await file.length(),
            "base64":
                "data:${file.mimeType ?? 'image/jpeg'};base64,${base64Encode(await file.readAsBytes())}",
          };
        }
        break;
      case 'pickPhoto':
        XFile? file = await _picker.pickImage(source: ImageSource.gallery);
        if (file != null) {
          return {
            "path": file.path,
            "name": file.name,
            "type": file.mimeType,
            "size": await file.length(),
            "base64":
                "data:${file.mimeType ?? 'image/jpeg'};base64,${base64Encode(await file.readAsBytes())}",
          };
        }
        break;
      default:
        return null;
    }
  }
}
