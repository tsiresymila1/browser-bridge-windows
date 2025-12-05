import 'package:bloc/bloc.dart';
import 'package:flutter_thermal_printer/utils/printer.dart';
import 'package:meta/meta.dart';

part 'printer_event.dart';

part 'printer_state.dart';

class PrinterBloc extends Bloc<PrinterEvent, PrinterState> {
  PrinterBloc() : super(const PrinterInitial(printers: [])) {
    on<UpdatePrinterEvent>((event, emit) {
      emit(PrinterInitial(printers: event.printers));
    });
  }
}
