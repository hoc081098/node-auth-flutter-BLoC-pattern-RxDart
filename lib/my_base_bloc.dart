import 'package:flutter_bloc_pattern/flutter_bloc_pattern.dart';
import 'package:node_auth/utils/type_defs.dart';

class MyBaseBloc implements BaseBloc {
  bool _calledDispose = false;
  final Function0<void> _dispose;

  MyBaseBloc(this._dispose);

  @override
  void dispose() {
    if (_calledDispose) {
      throw Exception('[$runtimeType] dispose called more once');
    }
    _dispose();
    _calledDispose = true;
    print('[$runtimeType] disposed');
  }
}
