// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Success<T> extends Success<T> {
  @override
  final T? value;

  factory _$Success([void Function(SuccessBuilder<T>)? updates]) =>
      (new SuccessBuilder<T>()..update(updates)).build();

  _$Success._({this.value}) : super._() {
    if (T == dynamic) {
      throw new BuiltValueMissingGenericsError('Success', 'T');
    }
  }

  @override
  Success<T> rebuild(void Function(SuccessBuilder<T>) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SuccessBuilder<T> toBuilder() => new SuccessBuilder<T>()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Success && value == other.value;
  }

  @override
  int get hashCode {
    return $jf($jc(0, value.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('Success')..add('value', value))
        .toString();
  }
}

class SuccessBuilder<T> implements Builder<Success<T>, SuccessBuilder<T>> {
  _$Success<T>? _$v;

  T? _value;
  T? get value => _$this._value;
  set value(T? value) => _$this._value = value;

  SuccessBuilder();

  SuccessBuilder<T> get _$this {
    final $v = _$v;
    if ($v != null) {
      _value = $v.value;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Success<T> other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$Success<T>;
  }

  @override
  void update(void Function(SuccessBuilder<T>)? updates) {
    if (updates != null) updates(this);
  }

  @override
  _$Success<T> build() {
    final _$result = _$v ?? new _$Success<T>._(value: value);
    replace(_$result);
    return _$result;
  }
}

class _$Failure<T> extends Failure<T> {
  @override
  final String message;
  @override
  final Object error;

  factory _$Failure([void Function(FailureBuilder<T>)? updates]) =>
      (new FailureBuilder<T>()..update(updates)).build();

  _$Failure._({required this.message, required this.error}) : super._() {
    BuiltValueNullFieldError.checkNotNull(message, 'Failure', 'message');
    BuiltValueNullFieldError.checkNotNull(error, 'Failure', 'error');
    if (T == dynamic) {
      throw new BuiltValueMissingGenericsError('Failure', 'T');
    }
  }

  @override
  Failure<T> rebuild(void Function(FailureBuilder<T>) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  FailureBuilder<T> toBuilder() => new FailureBuilder<T>()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Failure && message == other.message && error == other.error;
  }

  @override
  int get hashCode {
    return $jf($jc($jc(0, message.hashCode), error.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('Failure')
          ..add('message', message)
          ..add('error', error))
        .toString();
  }
}

class FailureBuilder<T> implements Builder<Failure<T>, FailureBuilder<T>> {
  _$Failure<T>? _$v;

  String? _message;
  String? get message => _$this._message;
  set message(String? message) => _$this._message = message;

  Object? _error;
  Object? get error => _$this._error;
  set error(Object? error) => _$this._error = error;

  FailureBuilder();

  FailureBuilder<T> get _$this {
    final $v = _$v;
    if ($v != null) {
      _message = $v.message;
      _error = $v.error;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Failure<T> other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$Failure<T>;
  }

  @override
  void update(void Function(FailureBuilder<T>)? updates) {
    if (updates != null) updates(this);
  }

  @override
  _$Failure<T> build() {
    final _$result = _$v ??
        new _$Failure<T>._(
            message: BuiltValueNullFieldError.checkNotNull(
                message, 'Failure', 'message'),
            error: BuiltValueNullFieldError.checkNotNull(
                error, 'Failure', 'error'));
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
