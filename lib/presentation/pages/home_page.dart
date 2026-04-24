import 'dart:convert';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:browser_bridge/generated/assets.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constant.dart';
import '../../core/services/printer.dart';
import '../../core/util/log.dart';
import '../../presentation/blocs/setting/setting_bloc.dart';
import '../blocs/printer/printer_bloc.dart';
import '../widget/printer_stream_listener.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey webViewKey = GlobalKey();
  bool _isLoading = true;
  double _progress = 0;
  InAppWebViewController? webViewController;

  final ContextMenu contextMenu = ContextMenu(
    menuItems: [
      ContextMenuItem(
        id: 1,
        title: "🔍 Search Google",
      ),
      ContextMenuItem(
        id: 2,
        title: "📋 Copy Link",
      ),
    ],
    onCreateContextMenu: (hitTestResult) async {
      debugPrint("Context menu created: ${hitTestResult.extra}");
    },
    onContextMenuActionItemClicked: (menuItem) async {
      debugPrint("Menu item clicked: ${menuItem.id} - ${menuItem.title}");
      // Example actions
      if (menuItem.id == 1) {
        // Search Google
        // You can inject JS or use controller
      } else if (menuItem.id == 2) {
        // Copy link to clipboard
      }
    },
    onHideContextMenu: () {
      debugPrint("Context menu hidden");
    },
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    webViewKey.currentState?.dispose();
    super.dispose();
  }
  clearCache() async {
    final cookieManager = CookieManager.instance();
    await  cookieManager.deleteAllCookies();
  }

  InAppWebViewSettings _getWebViewSettings(String webPath) {
    logger.i(webPath);
    return InAppWebViewSettings(
        supportMultipleWindows: true,
        javaScriptCanOpenWindowsAutomatically: true,
        allowUniversalAccessFromFileURLs: true,
        applicationNameForUserAgent: 'Browser bridge',
        allowFileAccessFromFileURLs: true,
        allowFileAccess: true,
        supportZoom: false,
        disableDefaultErrorPage: true,
        limitsNavigationsToAppBoundDomains: true,
        allowsInlineMediaPlayback: true,
        useOnDownloadStart: true,
        mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
        overScrollMode: OverScrollMode.NEVER,
        scrollBarStyle: ScrollBarStyle.SCROLLBARS_OUTSIDE_OVERLAY,
        useWideViewPort: true,
        databaseEnabled: true,
        domStorageEnabled: true,
        cacheEnabled: true,
        scrollbarFadingEnabled: true,
        scrollBarDefaultDelayBeforeFade: 0,
        thirdPartyCookiesEnabled: true,
        hardwareAcceleration: true,
        safeBrowsingEnabled: true,
        allowContentAccess: true,
        verticalScrollbarThumbColor: Colors.transparent,
        isInspectable: true,
        disableContextMenu: true,
        useHybridComposition: false,



    );
  }

  Future<void> _registerServices(BuildContext context) async {
    final services = {
      "Printer": PrinterService(),
    };

    services.forEach((name, service) {
      webViewController?.addJavaScriptHandler(
        handlerName: name,
        callback: (args) =>
            service.call(context: context, jsArgs: service.getJsArgs(args)),
      );
    });

    webViewController?.addJavaScriptHandler(
      handlerName: 'handlerFoo',
      callback: (_) => {'bar': 'bar_value', 'baz': 'baz_value'},
    );
    webViewController?.addJavaScriptHandler(
      handlerName: 'clearAllCache',
      callback: (_) async {
        return await clearCache();
      },
    );

    webViewController?.addJavaScriptHandler(
      handlerName: 'clearClientCertPreferences',
      callback: (_) async => {
        await InAppWebViewController.clearClientCertPreferences()
      },
    );
    await webViewController?.injectJavascriptFileFromAsset(
        assetFilePath: Assets.jsJsBridge);
    await webViewController?.addUserScript(
        userScript: UserScript(
            source: await rootBundle.loadString(Assets.jsJsBridge),
            injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START));
  }

  void _dispatchJsEvent(String eventName, dynamic data) {
    if (webViewController == null) return;
    final jsEvent = """
      window.dispatchEvent(
        new CustomEvent("$eventName", { detail: ${jsonEncode(data)} })
      );
    """;
    webViewController?.evaluateJavascript(source: jsEvent);
  }

  Widget buildContextMenuWrapper({
    required BuildContext context,
    required Widget child,
  }) {
    Future<void> openMenu(Offset position) async {
      final overlay =
      Overlay.of(context).context.findRenderObject() as RenderBox;

      final value = await showMenu(
        context: context,
        elevation: 8,
        position: RelativeRect.fromLTRB(
          position.dx,
          position.dy,
          overlay.size.width - position.dx,
          overlay.size.height - position.dy,
        ),
        items: const [
          PopupMenuItem(
            value: 'refresh',
            child: Row(
              children: [Icon(Icons.refresh), SizedBox(width: 8), Text("Refresh")],
            ),
          ),
          PopupMenuItem(
            value: 'clearCache',
            child: Row(
              children: [
                Icon(Icons.delete_forever),
                SizedBox(width: 8),
                Text("Clear cache")
              ],
            ),
          ),
          PopupMenuItem(
            value: 'setting',
            child: Row(
              children: [Icon(Icons.settings), SizedBox(width: 8), Text("Settings")],
            ),
          ),
          PopupMenuItem(
            value: 'inspect',
            child: Row(
              children: [Icon(Icons.settings), SizedBox(width: 8), Text("Inspect")],
            ),
          ),
        ],
      );

      if (value == 'setting') {
        context.pushNamed("setting");
      }
      else if (value == 'inspect') {
        await webViewController?.openDevTools();
      } else if (value == 'refresh') {
        await webViewController?.reload();
      } else if (value == 'clearCache') {
        await clearCache();
        await webViewController?.reload();
      }
    }
    return Listener(
      onPointerDown: (event) {
        if (event.kind == PointerDeviceKind.mouse &&
            event.buttons == kSecondaryMouseButton) {
          openMenu(event.position);
        }
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onLongPressStart: (details) {
          openMenu(details.globalPosition);
        },
        child: child,
      ),
    );
  }


    @override
  Widget build(BuildContext context) {
    return PrinterStreamListener(
      onPrinterFound: (printers) {
        context.read<PrinterBloc>().add(UpdatePrinterEvent(printers: printers));
        _dispatchJsEvent(
          "OnPrinterFound",
          printers.map((e) => e.toJson()).toList(),
        );
      },
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (canPop, data) async {
          if (await webViewController?.canGoBack() ?? false) {
            webViewController?.goBack();
          }
        },
        child: Scaffold(
          drawer: const Drawer(
            child: Column(children: [DrawerHeader(child: Text("JS Bridge"))]),
          ),
          body: SafeArea(
            child: Stack(
              children: [
                BlocConsumer<SettingBloc, SettingState>(
                  buildWhen: (p, r) =>
                      p.config['web_path'] != r.config['web_path'] ||
                      p.config['web_url'] != r.config['web_url'] ||
                      p.config['offline'] != r.config['offline'],
                  builder: (context2, state) {
                    final startUrl = state.config["web_url"] ??
                        getWebUrl();
                    return buildContextMenuWrapper(
                      context: context,
                      child: InAppWebView(
                        key: webViewKey,
                        contextMenu: contextMenu,
                        onProgressChanged: (_, progress) =>
                            setState(() => _progress = progress / 100),
                        initialSettings: _getWebViewSettings(
                          state.config["web_path"] ?? getWebPath(),
                        ),
                        initialUrlRequest: URLRequest(url: WebUri(startUrl)),
                        onWebViewCreated: (controller) async {
                          webViewController = controller;
                          await _registerServices(context);
                          // await controller
                          //     .requestFocusNodeHref();
                        },
                        onLoadStart: (_, __) =>
                            setState(() => _isLoading = true),
                        onLoadStop: (ctr, url) async {
                          setState(() => _isLoading = false);
                          await webViewController
                              ?.evaluateJavascript(source: """
                            document.body.focus();
                          """);
                        },
                        onReceivedError: (ctr, req, error) async {
                          logger.e(error.description);
                          logger.e(error.type);
                          if (req.isForMainFrame ?? false) {
                            final errorHtml = await rootBundle.loadString(
                              Assets.appError,
                            );
                            await ctr.loadData(
                              data: errorHtml,
                              mimeType: 'text/html',
                              encoding: 'utf-8',
                              baseUrl: req.url, // fake domain for local assets
                            );
                          }
                          setState(() => _isLoading = false);
                        },
                        onJsAlert: (_, js) async {
                          await showOkAlertDialog(
                              context: context,
                              message: js.message,
                              style: AdaptiveStyle.adaptive);
                          return JsAlertResponse(handledByClient: true);
                        },
                        onJsConfirm: (_, js) async {
                          final result = await showOkCancelAlertDialog(
                            context: context,
                            message: js.message,
                            title: "Confirmation",
                          );
                          return JsConfirmResponse(
                            handledByClient: true,
                            action: result.index == 0
                                ? JsConfirmResponseAction.CONFIRM
                                : JsConfirmResponseAction.CANCEL,
                          );
                        },
                        onConsoleMessage: (_, message) {
                          final logFn = switch (message.messageLevel) {
                            ConsoleMessageLevel.ERROR => logger.e,
                            ConsoleMessageLevel.WARNING => logger.w,
                            ConsoleMessageLevel.DEBUG => logger.d,
                            _ => logger.i,
                          };
                          logFn(message.message);
                        },
                        shouldInterceptRequest: (controller, request) async {
                          return null;
                        },
                        shouldOverrideUrlLoading:
                            (controller, navigationAction) async {
                          final uri = navigationAction.request.url;
                          if (uri == null) return NavigationActionPolicy.ALLOW;
                          if (!['http', 'https', 'file'].contains(uri.scheme)) {
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri,
                                  mode: LaunchMode.externalApplication);
                            }
                            return NavigationActionPolicy.CANCEL;
                          }

                          return NavigationActionPolicy.ALLOW;
                        },
                      ),
                    );
                  },
                  listener: (context, state) async {
                    final newUrl = state.config["web_url"] ??
                        getWebUrl();
                    webViewController?.setSettings(
                      settings: _getWebViewSettings(
                        state.config["web_path"] ?? getWebPath(),
                      ),
                    );
                    logger.i(newUrl);
                    webViewController?.loadUrl(
                      urlRequest: URLRequest(url: WebUri(newUrl)),
                    );
                  },
                ),
                 if (_isLoading)
                   const Center(child: CircularProgressIndicator()),
                if (_progress < 1)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: LinearProgressIndicator(
                      value: _progress,
                      minHeight: 6,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
