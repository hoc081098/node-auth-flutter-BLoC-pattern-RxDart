import 'package:built_value/built_value.dart';

part 'change_password_state.g.dart';

abstract class ChangePasswordState
    implements Built<ChangePasswordState, ChangePasswordStateBuilder> {
  @nullable
  Object get error;

  @nullable
  String get message;

  bool get isLoading;

  ChangePasswordState._();

  factory ChangePasswordState(
          [void Function(ChangePasswordStateBuilder) updates]) =
      _$ChangePasswordState;
}
