import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc_pattern/flutter_bloc_pattern.dart';
import 'package:flutter_disposebag/flutter_disposebag.dart';
import 'package:flutter_provider/flutter_provider.dart';
import 'package:node_auth/domain/usecases/change_password_use_case.dart';
import 'package:node_auth/pages/home/change_password/change_password.dart';
import 'package:node_auth/pages/home/home.dart';
import 'package:node_auth/pages/home/home_profile_widget.dart';
import 'package:node_auth/pages/login/login.dart';
import 'package:node_auth/utils/snackbar.dart';
import 'package:rxdart_ext/rxdart_ext.dart';

class HomePage extends StatefulWidget {
  static const routeName = '/home_page';

  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin<HomePage>, DisposeBagMixin {
  late final AnimationController rotateLogoController;
  Object? listen;

  @override
  void initState() {
    super.initState();

    rotateLogoController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    listen ??= BlocProvider.of<HomeBloc>(context)
        .message$
        .flatMap(handleMessage)
        .collect()
        .disposedBy(bag);
  }

  @override
  void dispose() {
    rotateLogoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final homeBloc = BlocProvider.of<HomeBloc>(context);
    final logoSize = MediaQuery.of(context).size.width / 2;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/bg.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.5),
              BlendMode.darken,
            ),
          ),
        ),
        child: ListView(
          children: <Widget>[
            const HomeUserProfile(),
            Container(
              height: 54.0,
              margin: const EdgeInsets.only(left: 8.0, right: 8.0, top: 16.0),
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: showChangePassword,
                label: const Text('Change password'),
                icon: const Icon(Icons.lock_outline),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).backgroundColor,
                ),
              ),
            ),
            Container(
              height: 54.0,
              margin: const EdgeInsets.only(left: 8.0, right: 8.0, top: 16.0),
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: homeBloc.logout,
                label: const Text('Logout'),
                icon: const Icon(Icons.exit_to_app),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).backgroundColor,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Flutter auth BLoC pattern RxDart',
                  style: Theme.of(context)
                      .textTheme
                      .subtitle1!
                      .copyWith(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: RotationTransition(
                turns: rotateLogoController,
                child: FlutterLogo(size: logoSize),
              ),
            )
          ],
        ),
      ),
    );
  }

  Stream<void> handleMessage(HomeMessage message) async* {
    debugPrint('[DEBUG] homeBloc message=$message');

    if (message is LogoutMessage) {
      if (message is LogoutSuccessMessage) {
        context.showSnackBar('Logout successfully!');
        await delay(1000);
        yield null;

        // ignore: use_build_context_synchronously
        context.hideCurrentSnackBar();
        // ignore: use_build_context_synchronously
        await Navigator.of(context).pushNamedAndRemoveUntil(
          LoginPage.routeName,
          (_) => false,
        );
        return;
      }
      if (message is LogoutErrorMessage) {
        context.showSnackBar('Error when logout: ${message.message}');
        return;
      }
      return;
    }
    if (message is UpdateAvatarMessage) {
      if (message is UpdateAvatarSuccessMessage) {
        context.showSnackBar('Upload image successfully!');
        return;
      }
      if (message is UpdateAvatarErrorMessage) {
        context.showSnackBar('Error when upload image: ${message.message}');
        return;
      }
    }
  }

  void showChangePassword() {
    showModalBottomSheet(
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
          bottomLeft: Radius.zero,
          bottomRight: Radius.zero,
        ),
      ),
      context: context,
      builder: (context) {
        return BlocProvider<ChangePasswordBloc>(
          initBloc: (context) => ChangePasswordBloc(
            ChangePasswordUseCase(context.get()),
          ),
          child: const ChangePasswordBottomSheet(),
        );
      },
      backgroundColor: Theme.of(context).canvasColor,
    );
  }
}
