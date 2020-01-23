// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'change_password_state.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ChangePasswordState extends ChangePasswordState {
  @override
  final Object error;
  @override
  final String message;
  @override
  final bool isLoading;

  factory _$ChangePasswordState(
          [void Function(ChangePasswordStateBuilder) updates]) =>
      (new ChangePasswordStateBuilder()..update(updates)).build();

  _$ChangePasswordState._({this.error, this.message, this.isLoading})
      : super._() {
    if (isLoading == null) {
      throw new BuiltValueNullFieldError('ChangePasswordState', 'isLoading');
    }
  }

  @override
  ChangePasswordState rebuild(
          void Function(ChangePasswordStateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ChangePasswordStateBuilder toBuilder() =>
      new ChangePasswordStateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ChangePasswordState &&
        error == other.error &&
        message == other.message &&
        isLoading == other.isLoading;
  }

  @override
  int get hashCode {
    return $jf(
        $jc($jc($jc(0, error.hashCode), message.hashCode), isLoading.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('ChangePasswordState')
          ..add('error', error)
          ..add('message', message)
          ..add('isLoading', isLoading))
        .toString();
  }
}

class ChangePasswordStateBuilder
    implements Builder<ChangePasswordState, ChangePasswordStateBuilder> {
  _$ChangePasswordState _$v;

  Object _error;
  Object get error => _$this._error;
  set error(Object error) => _$this._error = error;

  String _message;
  String get message => _$this._message;
  set message(String message) => _$this._message = message;

  bool _isLoading;
  bool get isLoading => _$this._isLoading;
  set isLoading(bool isLoading) => _$this._isLoading = isLoading;

  ChangePasswordStateBuilder();

  ChangePasswordStateBuilder get _$this {
    if (_$v != null) {
      _error = _$v.error;
      _message = _$v.message;
      _isLoading = _$v.isLoading;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ChangePasswordState other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$ChangePasswordState;
  }

  @override
  void update(void Function(ChangePasswordStateBuilder) updates) {
    if (updates != null) updates(this);
  }

  @override
  _$ChangePasswordState build() {
    final _$result = _$v ??
        new _$ChangePasswordState._(
            error: error, message: message, isLoading: isLoading);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
