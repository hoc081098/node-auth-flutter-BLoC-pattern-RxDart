import 'package:flutter/material.dart';
import 'package:node_auth/data/user_repository.dart';

class DependencyInjector extends InheritedWidget {
  final UserRepository userRepository;

  const DependencyInjector(this.userRepository, {Key key, Widget child})
      : super(key: key, child: child);

  @override
  bool updateShouldNotify(DependencyInjector oldWidget) =>
      userRepository != oldWidget.userRepository;

  static DependencyInjector of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(DependencyInjector)
        as DependencyInjector;
  }
}
