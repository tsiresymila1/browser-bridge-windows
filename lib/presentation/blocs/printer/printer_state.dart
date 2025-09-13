part of 'printer_bloc.dart';

@immutable
sealed class PrinterState {
  final List<Printer> printers;

  const PrinterState({required this.printers});
}

final class PrinterInitial extends PrinterState {
  const PrinterInitial({required super.printers});
}
