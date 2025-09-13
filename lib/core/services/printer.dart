import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import '../../presentation/blocs/printer/printer_bloc.dart';
import '../models/args/args.dart';
import '../util/log.dart';
import '../util/printer_parser.dart';
import 'service.dart';

final mediaQuery = MediaQueryData.fromView(
  ui.PlatformDispatcher.instance.views.first,
);

class PrinterService extends JsService {
  @override
  FutureOr call({required BuildContext context, required JsArgs jsArgs}) async {
    logger.i(jsArgs.args);
    logger.i(jsArgs.method);
    switch (jsArgs.method) {
      case 'get':
        return context
            .read<PrinterBloc>()
            .state
            .printers
            .map((e) => e.toJson())
            .toList();
      case "test":
        final contents = jsArgs.args['content'];
        final address = jsArgs.args['index'].toString();
        final printers = context.read<PrinterBloc>().state.printers;
        final printer = printers.where((p) => p.address == address).firstOrNull;
        if (printer != null) {
          if (!(printer.isConnected ?? true)) {
            logger.i("Connecting ....");
             await FlutterThermalPrinter.instance.connect(
              printer,
            );
            logger.i("Printing ....");
          }
          final profile = await CapabilityProfile.load();
          final generator = Generator(PaperSize.mm80, profile);
          List<int> bytes = generator.reset();
          bytes+= await PrinterCommandParser(generator).parse(contents);
          await FlutterThermalPrinter.instance.printData(printer, bytes, longData: true);
        }

      case "print":
        // params
        final contents = jsArgs.args['content'];
        final address = jsArgs.args['index'].toString();
        final printers = context.read<PrinterBloc>().state.printers;
        final printer = printers.where((p) => p.address == address).firstOrNull;
        if (printer != null) {
          if (!(printer.isConnected ?? true)) {
            logger.i("Connecting ....");
            await FlutterThermalPrinter.instance.connect(
              printer,
            );
            logger.i("Printing ....");
          }
          final profile = await CapabilityProfile.load();
          final generator = Generator(PaperSize.mm80, profile);
          List<int> bytes = generator.reset();
          bytes+= await PrinterCommandParser(generator).parse(contents);
          await FlutterThermalPrinter.instance.printData(printer, bytes, longData: true);
        }
        break;
      case "printNetwork":
        // params
        final contents = jsArgs.args['content'];
        final port = jsArgs.args['port'].toString();
        final host = jsArgs.args['host'].toString();

        final service = FlutterThermalPrinterNetwork(
          host,
          port: int.parse(port),
        );
        await service.connect();
        final profile = await CapabilityProfile.load();
        final generator = Generator(PaperSize.mm80, profile);
        List<int> bytes = generator.reset();
        bytes+= await PrinterCommandParser(generator).parse(contents);
        await service.printTicket(bytes);
        await service.disconnect();
        break;
      default:
        return null;
    }
  }
}
