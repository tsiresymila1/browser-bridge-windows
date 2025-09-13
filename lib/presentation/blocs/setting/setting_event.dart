part of 'setting_bloc.dart';

@immutable
sealed class SettingEvent {}

class UpdateSettingEvent extends SettingEvent {
  final Map<String, dynamic> config;
  UpdateSettingEvent({required this.config});
}
