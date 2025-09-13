import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:flutter_thermal_printer/utils/printer.dart';

import '../../core/util/log.dart';

class PrinterStreamListener extends StatefulWidget {
  final Widget child;
  final Function(List<Printer> printers) onPrinterFound;

  const PrinterStreamListener({
    super.key,
    required this.child,
    required this.onPrinterFound,
  });

  @override
  State<PrinterStreamListener> createState() => _PrinterStreamListenerState();
}

class _PrinterStreamListenerState extends State<PrinterStreamListener> {
  final _flutterThermalPrinterPlugin = FlutterThermalPrinter.instance;

  StreamSubscription<List<Printer>>? _devicesStreamSubscription;

  void startScan() async {
    _devicesStreamSubscription?.cancel();
    await _flutterThermalPrinterPlugin.getPrinters(
      connectionTypes: [
        ConnectionType.USB,
        ConnectionType.BLE,
        ConnectionType.NETWORK,
      ],
    );
    _devicesStreamSubscription = _flutterThermalPrinterPlugin.devicesStream
        .listen((List<Printer> event) {
      logger.d(event);
      event.removeWhere(
        (element) => element.name == null || element.name == '',
      );
      widget.onPrinterFound(event);
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      startScan();
    });
  }


  @override
  void dispose() {
    stopScan();
    _devicesStreamSubscription?.cancel();
    super.dispose();
  }

  stopScan() {
    _flutterThermalPrinterPlugin.stopScan();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
