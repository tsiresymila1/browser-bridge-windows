import 'package:get_it/get_it.dart';

import '../presentation/blocs/printer/printer_bloc.dart';
import '../presentation/blocs/setting/setting_bloc.dart';

final sl = GetIt.instance;

setupDependencies() {
  sl.registerSingleton<SettingBloc>(SettingBloc());
  sl.registerSingleton<PrinterBloc>(PrinterBloc());
}
