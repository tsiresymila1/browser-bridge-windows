import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../models/args/args.dart';
import 'service.dart';

class FileService extends JsService {
  @override
  FutureOr call({required BuildContext context, required JsArgs jsArgs}) async {
    if (jsArgs.method == "pick") {
      final dialogTitle = jsArgs.args['title'];

      final result = await FilePicker.platform.pickFiles(
        dialogTitle: dialogTitle,
        withData: true,
      );

      if (result == null || result.files.isEmpty) return null;

      final file = result.files.first;

      return {
        "path": file.path,
        "name": file.name,
        "type": file.extension != null
            ? "application/${file.extension}"
            : "application/octet-stream",
        "size": file.size,
      };
    }

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
        await file.create(recursive: true);
        await file.writeAsString(contents);
        return true;

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
        final stat = await FileStat.stat(path);
        return {
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
          return dir
              .listSync()
              .map((e) => {"path": e.path, "name": e.uri.pathSegments.last})
              .toList();
        }
        return [];

      case 'readBinary':
        final bytes = await file.readAsBytes();
        return base64Encode(bytes);

      case 'writeBinary':
        final contents = jsArgs.args['content'];
        final bytes = base64Decode(contents);
        await file.create(recursive: true);
        await file.writeAsBytes(bytes);
        return true;

      default:
        return null;
    }
  }
}
