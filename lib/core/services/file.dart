import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/args/args.dart';
import 'service.dart';

class FileService extends JsService {
  @override
  FutureOr call({required BuildContext context, required JsArgs jsArgs}) async {
    if (jsArgs.method == "pick") {
      final dialogTitle = jsArgs.args['title'];
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        dialogTitle: dialogTitle,
      );
      if (result != null && result.files.isNotEmpty) {
        XFile file = result.files.first.xFile;
        return {
          "path": file.path,
          "name": file.name,
          "type": file.mimeType,
          "size": await file.length(),
        };
      }
      return null;
    } else {
      final path = jsArgs.args['path'];
      final file = File(path);
      final dir = Directory(path);
      switch (jsArgs.method) {
        case 'read':
          if (await file.exists()) {
            return await file.readAsString();
          }
          break;
        case 'write':
          final contents = jsArgs.args['content'];
          if (!await file.exists()) {
            await file.create(recursive: true);
          }
          await file.writeAsString(contents);
          break;
        case 'deleteFile':
          if (await file.exists()) await file.delete();
          return true;
        case 'createDir':
          await dir.create(recursive: true);
          return true;
        case 'deleteDir':
          if (await dir.exists()) await dir.delete(recursive: true);
          return true;
        case 'exists':
          return await file.exists() || await dir.exists();
        case 'stat':
          final entity = await FileSystemEntity.type('$path');
          final stat = await FileStat.stat('$path');
          return {
            'type': entity.toString().split('.').last,
            'size': stat.size,
            'modified': stat.modified.toIso8601String(),
          };
        case 'rename':
          final newPath = jsArgs.args['newPath'];
          if (await file.exists()) {
            await file.rename(newPath);
          } else if (await dir.exists()) {
            await dir.rename(newPath);
          }
          return true;
        case 'list':
          if (await dir.exists()) {
            return (await dir.list().toList()).map((e) {
              return {"path": e.path, "name": e.absolute};
            }).toList();
          }
          return [];
        case 'readBinary':
          {
            final bytes = await file.readAsBytes();
            return base64Encode(bytes);
          }
        case 'writeBinary':
          {
            final contents = jsArgs.args['content'];
            final bytes = base64Decode(contents);
            await file.create(recursive: true);
            await file.writeAsBytes(bytes);
            return true;
          }
        default:
          return null;
      }
    }
  }
}
