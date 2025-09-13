import 'package:freezed_annotation/freezed_annotation.dart';

part 'args.freezed.dart';

part 'args.g.dart';

@freezed
abstract class JsArgs with _$JsArgs {
  const factory JsArgs({
    required String method,
    @Default({}) Map<String, dynamic> args,
  }) = _JsArgs;

  factory JsArgs.fromJson(Map<String, dynamic> json) => _$JsArgsFromJson(json);
}
