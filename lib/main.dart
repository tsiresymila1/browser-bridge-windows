import 'dart:io';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:window_manager/window_manager.dart';

import 'core/constant.dart';
import 'core/sl.dart';
import 'core/util/webfile.dart';
import 'presentation/blocs/printer/printer_bloc.dart';
import 'presentation/blocs/setting/setting_bloc.dart';
import 'presentation/router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isAndroid) {
    await forceStoragePermission();
  }

  // ---------------- WINDOWS ONLY ----------------
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
    await windowManager.ensureInitialized();

    const windowOptions = WindowOptions(
      title: "Browser bridge",
      windowButtonVisibility: true,
      center: true,
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }
  // ----------------------------------------------

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorageDirectory.web
        : HydratedStorageDirectory((await getTemporaryDirectory()).path),
  );

  setupDependencies();
  await createWebFile();

  // --------------- ANDROID ONLY -----------------
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    await InAppWebViewController.setWebContentsDebuggingEnabled(true);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor: Color(0xFF0784A9),
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarContrastEnforced: true,
        statusBarColor: Colors.transparent,
      ),
    );
  }
  // ----------------------------------------------

  AdaptiveDialog.instance.updateConfiguration(
    defaultStyle: AdaptiveStyle.material,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(lazy: false, create: (_) => sl.get<SettingBloc>()),
        BlocProvider(lazy: false, create: (_) => sl.get<PrinterBloc>()),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'JSBridge',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0784A9)),
          dialogTheme: DialogThemeData(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            actionsPadding: const EdgeInsets.symmetric(horizontal: 0),
            insetPadding: const EdgeInsets.symmetric(horizontal: 24),
            titleTextStyle: TextStyle(color: Colors.amber[900]),
          ),
          textTheme: Theme.of(context)
              .textTheme
              .apply(fontSizeDelta: 0.8, fontSizeFactor: 0.8),
        ),
        routerConfig: router,
      ),
    );
  }
}
