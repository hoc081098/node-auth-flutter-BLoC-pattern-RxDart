import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_provider/flutter_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:node_auth/data/data.dart';
import 'package:node_auth/pages/home/change_password/change_password.dart';
import 'package:node_auth/pages/home/home.dart';

class HomePage extends StatefulWidget {
  final HomeBloc Function() initBloc;

  const HomePage({Key key, @required this.initBloc}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin<HomePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  AnimationController _rotateLogoController;

  HomeBloc _homeBloc;
  StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();

    _rotateLogoController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 4),
    )..repeat();

    _homeBloc = widget.initBloc();
    _subscription = _homeBloc.message$.listen(_handleMessage);
  }

  @override
  void dispose() {
    _rotateLogoController.dispose();
    _subscription.cancel();
    _homeBloc.dispose();
    super.dispose();
  }

  void _handleMessage(HomeMessage message) async {
    print('[DEBUG] homeBloc message=$message');

    if (message is LogoutMessage) {
      if (message is LogoutSuccessMessage) {
        _showMessage('Logout successfully!');
        await Future.delayed(const Duration(seconds: 1));
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login_page',
          (Route<dynamic> route) => false,
        );
      }
      if (message is LogoutErrorMessage) {
        await _showMessage('Error when logout: ${message.message}');
      }
    }
    if (message is UpdateAvatarMessage) {
      if (message is UpdateAvatarSuccessMessage) {
        _showMessage('Upload image successfully!');
      }
      if (message is UpdateAvatarErrorMessage) {
        _showMessage('Error when upload image: ${message.message}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final logoSize = MediaQuery.of(context).size.width / 2;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Home'),
      ),
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bg.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withAlpha(0xBF),
              BlendMode.darken,
            ),
          ),
        ),
        child: ListView(
          children: <Widget>[
            Card(
              color: Colors.black.withOpacity(0.5),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: StreamBuilder<User>(
                  stream: _homeBloc.user$,
                  initialData: _homeBloc.user$.value,
                  builder: (context, snapshot) {
                    final user = snapshot.data;

                    if (user == null) {
                      return Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(
                                valueColor:
                                    const AlwaysStoppedAnimation(Colors.white),
                                strokeWidth: 2,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'Loging out...',
                                style: Theme.of(context).textTheme.subhead,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        ClipOval(
                          child: GestureDetector(
                            child: user.imageUrl != null
                                ? Image.network(
                                    Uri.https(
                                      baseUrl,
                                      user.imageUrl,
                                    ).toString(),
                                    fit: BoxFit.cover,
                                    width: 90.0,
                                    height: 90.0,
                                  )
                                : Image.asset(
                                    'assets/user.png',
                                    width: 90.0,
                                    height: 90.0,
                                  ),
                            onTap: _pickAndUploadImage,
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            title: Text(
                              user.name,
                              style: TextStyle(
                                fontSize: 24.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              "${user.email}\n${user.createdAt}",
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            Container(
              height: 48.0,
              margin: EdgeInsets.only(left: 8.0, right: 8.0, top: 16.0),
              width: double.infinity,
              child: RaisedButton.icon(
                onPressed: _showChangePassword,
                label: Text('Change password'),
                icon: Icon(Icons.lock_outline),
                color: Theme.of(context).backgroundColor,
                colorBrightness: Brightness.dark,
                splashColor: Colors.white.withOpacity(0.5),
              ),
            ),
            Container(
              height: 48.0,
              margin: EdgeInsets.only(left: 8.0, right: 8.0, top: 16.0),
              width: double.infinity,
              child: RaisedButton.icon(
                onPressed: _homeBloc.logout,
                label: Text('Logout'),
                icon: Icon(Icons.exit_to_app),
                color: Theme.of(context).backgroundColor,
                colorBrightness: Brightness.dark,
                splashColor: Colors.white.withOpacity(0.5),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Flutter auth BLoC pattern RxDart',
                  style: Theme.of(context)
                      .textTheme
                      .subhead
                      .copyWith(fontSize: 16),
                ),
              ),
            ),
            Center(
              child: RotationTransition(
                turns: _rotateLogoController,
                child: FlutterLogo(size: logoSize),
              ),
            )
          ],
        ),
      ),
    );
  }

  _showChangePassword() {
    showModalBottomSheet(
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
          bottomLeft: Radius.zero,
          bottomRight: Radius.zero,
        ),
      ),
      context: context,
      builder: (context) {
        final repository = Provider.of<UserRepository>(context);
        return ChangePasswordBottomSheet(
          initBloc: () => ChangePasswordBloc(repository),
        );
      },
      backgroundColor: Theme.of(context).canvasColor,
    );
  }

  _pickAndUploadImage() async {
    final imageFile = await ImagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 720.0,
      maxHeight: 720.0,
    );
    _homeBloc.changeAvatar(imageFile);
  }

  Future<void> _showMessage(String message) => _scaffoldKey.currentState
      ?.showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
        ),
      )
      ?.closed;
}
