import 'dart:async';
import 'package:flutter/cupertino.dart';

import '../models/args/args.dart';

abstract class JsService {
  FutureOr call({required BuildContext context, required JsArgs jsArgs});

  JsArgs getJsArgs(List<dynamic> data) {
    if (data.isNotEmpty) {
      final params = data.elementAt(0);
      final jsArgs = JsArgs.fromJson(params);
      return jsArgs;
    }
    return const JsArgs(method: "unknown");
  }
}
