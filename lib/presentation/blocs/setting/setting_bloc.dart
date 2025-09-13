import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:meta/meta.dart';

part 'setting_event.dart';

part 'setting_state.dart';

class SettingBloc extends HydratedBloc<SettingEvent, SettingState> {
  SettingBloc() : super(const SettingInitial(config: {"offline": false})) {
    on<UpdateSettingEvent>((event, emit) {
      emit(SettingInitial(config: {...state.config, ...event.config}));
    });
  }

  @override
  SettingState? fromJson(Map<String, dynamic> json) {
    return SettingInitial(config: json);
  }

  @override
  Map<String, dynamic>? toJson(SettingState state) {
    return state.config;
  }
}
