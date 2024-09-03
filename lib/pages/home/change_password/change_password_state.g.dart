// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'change_password_state.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ChangePasswordState extends ChangePasswordState {
  @override
  final Object? error;
  @override
  final String? message;
  @override
  final bool isLoading;

  factory _$ChangePasswordState(
          [void Function(ChangePasswordStateBuilder)? updates]) =>
      (new ChangePasswordStateBuilder()..update(updates))._build();

  _$ChangePasswordState._({this.error, this.message, required this.isLoading})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(
        isLoading, r'ChangePasswordState', 'isLoading');
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
    var _$hash = 0;
    _$hash = $jc(_$hash, error.hashCode);
    _$hash = $jc(_$hash, message.hashCode);
    _$hash = $jc(_$hash, isLoading.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ChangePasswordState')
          ..add('error', error)
          ..add('message', message)
          ..add('isLoading', isLoading))
        .toString();
  }
}

class ChangePasswordStateBuilder
    implements Builder<ChangePasswordState, ChangePasswordStateBuilder> {
  _$ChangePasswordState? _$v;

  Object? _error;
  Object? get error => _$this._error;
  set error(Object? error) => _$this._error = error;

  String? _message;
  String? get message => _$this._message;
  set message(String? message) => _$this._message = message;

  bool? _isLoading;
  bool? get isLoading => _$this._isLoading;
  set isLoading(bool? isLoading) => _$this._isLoading = isLoading;

  ChangePasswordStateBuilder();

  ChangePasswordStateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _error = $v.error;
      _message = $v.message;
      _isLoading = $v.isLoading;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ChangePasswordState other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$ChangePasswordState;
  }

  @override
  void update(void Function(ChangePasswordStateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ChangePasswordState build() => _build();

  _$ChangePasswordState _build() {
    final _$result = _$v ??
        new _$ChangePasswordState._(
            error: error,
            message: message,
            isLoading: BuiltValueNullFieldError.checkNotNull(
                isLoading, r'ChangePasswordState', 'isLoading'));
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
