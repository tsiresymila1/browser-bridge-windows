part of 'printer_bloc.dart';

@immutable
sealed class PrinterEvent {}

class UpdatePrinterEvent extends PrinterEvent {
  final List<Printer> printers;
  UpdatePrinterEvent({required this.printers});
}
