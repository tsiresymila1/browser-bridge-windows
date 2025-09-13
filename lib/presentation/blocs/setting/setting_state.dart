part of 'setting_bloc.dart';

@immutable
sealed class SettingState {
  final Map<String, dynamic> config;

  const SettingState({required this.config});
}

final class SettingInitial extends SettingState {
  const SettingInitial({required super.config});
}
