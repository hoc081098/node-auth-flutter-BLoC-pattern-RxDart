import 'dart:async';

import 'package:flutter/material.dart';
import 'package:node_auth/data/models/user.dart';
import 'package:node_auth/data/models/my_http_exception.dart';
import 'package:node_auth/data/remote/api_service.dart';

import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _token, _email, _createdAt;
  User _user;
  ApiService _apiService;

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    _createdAt = 'loading...';
    _apiService = ApiService();

    getUserInformation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Home'),
      ),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Card(
              color: Colors.black.withOpacity(0.5),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        ClipOval(
                          child: GestureDetector(
                            child: _user?.imageUrl != null
                                ? Image.network(
                                    Uri.https(
                                            ApiService.baseUrl, _user?.imageUrl)
                                        .toString(),
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
                              _user?.name ?? "loading...",
                              style: TextStyle(
                                fontSize: 24.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              "${_user?.email ?? "loading..."}\n$_createdAt",
                              style: TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w400,
                                  fontStyle: FontStyle.italic),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Container(
              height: 48.0,
              margin: EdgeInsets.only(left: 8.0, right: 8.0, top: 16.0),
              width: double.infinity,
              child: RaisedButton.icon(
                onPressed: () {
                  _showChangePassword();
                },
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
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/login_page',
                    ModalRoute.withName(Navigator.defaultRouteName),
                  );
                },
                label: Text('Logout'),
                icon: Icon(Icons.exit_to_app),
                color: Theme.of(context).backgroundColor,
                colorBrightness: Brightness.dark,
                splashColor: Colors.white.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  getUserInformation() async {
    try {
      final user = await _apiService.getUserProfile(_email, _token);
      setState(() {
        _user = user;
        _createdAt = user.createdAt.toString();
        debugPrint("getUserInformation $user");
      });
    } on MyHttpException catch (e) {
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text('Unknown error occurred'),
      ));
    }
  }

  _showChangePassword() {
    _scaffoldKey.currentState.showBottomSheet((context) {
      return ChangePasswordBottomSheet(
        email: _email,
        token: _token,
      );
    });
  }

  _pickAndUploadImage() async {
    try {
      final imageFile = await ImagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 720.0,
        maxHeight: 720.0,
      );
      final user = await _apiService.uploadImage(imageFile, _email);
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text('Changed avatar successfully!'),
        ),
      );
      setState(() {
        _user = user;
        debugPrint('After change avatar $user');
      });
    } on MyHttpException catch (e) {
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text(e.message),
        ),
      );
    } catch (e) {
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(content: Text('An unknown error occurred!')),
      );
    }
  }
}

class ChangePasswordBottomSheet extends StatefulWidget {
  final String email;
  final String token;

  const ChangePasswordBottomSheet({Key key, this.email, this.token})
      : super(key: key);

  @override
  _ChangePasswordBottomSheetState createState() =>
      _ChangePasswordBottomSheetState();
}

class _ChangePasswordBottomSheetState extends State<ChangePasswordBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  ApiService _apiService;
  bool _obscurePassword;
  bool _obscureNewPassword;
  String _password, _newPassword;
  bool _isLoading;
  String _msg;

  String _token, _email;

  @override
  void initState() {
    super.initState();
    _email = widget.email;
    _token = widget.token;
    _apiService = ApiService();
    _isLoading = false;
    _obscurePassword = true;
    _obscureNewPassword = true;
  }

  @override
  Widget build(BuildContext context) {
    final passwordTextField = TextFormField(
      autocorrect: true,
      autovalidate: true,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        suffixIcon: IconButton(
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          icon:
              Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
          iconSize: 18.0,
        ),
        labelText: 'Old password',
        prefixIcon: Padding(
          padding: const EdgeInsetsDirectional.only(end: 8.0),
          child: Icon(Icons.lock),
        ),
      ),
      keyboardType: TextInputType.text,
      maxLines: 1,
      style: TextStyle(fontSize: 16.0),
      onSaved: (s) => _password = s,
      validator: (s) => s.length < 6 ? "Minimum length of password is 6" : null,
    );

    final newPasswordTextField = TextFormField(
      autocorrect: true,
      autovalidate: true,
      obscureText: _obscureNewPassword,
      decoration: InputDecoration(
        suffixIcon: IconButton(
          onPressed: () =>
              setState(() => _obscureNewPassword = !_obscureNewPassword),
          icon: Icon(
              _obscureNewPassword ? Icons.visibility_off : Icons.visibility),
          iconSize: 18.0,
        ),
        labelText: 'New password',
        prefixIcon: Padding(
          padding: const EdgeInsetsDirectional.only(end: 8.0),
          child: Icon(Icons.lock),
        ),
      ),
      keyboardType: TextInputType.text,
      maxLines: 1,
      style: TextStyle(fontSize: 16.0),
      onSaved: (s) => _newPassword = s,
      validator: (s) => s.length < 6 ? "Minimum length of password is 6" : null,
    );

    final changePasswordButton = _isLoading
        ? CircularProgressIndicator()
        : _msg != null
            ? Text(
                _msg,
                style: TextStyle(
                  fontSize: 14.0,
                  fontStyle: FontStyle.italic,
                  color: Colors.amber,
                ),
              )
            : RaisedButton(
                color: Colors.teal.shade400,
                onPressed: _changePassword,
                child: Text(
                  "Change password",
                  style: TextStyle(fontSize: 16.0),
                ),
              );

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8.0),
          topRight: Radius.circular(8.0),
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: passwordTextField,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: newPasswordTextField,
            ),
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: changePasswordButton,
            )
          ],
        ),
      ),
    );
  }

  _changePassword() async {
    setState(() => _isLoading = true);

    if (!_formKey.currentState.validate()) {
      setState(() {
        _isLoading = false;
        _msg = 'Invalid information';
      });
      await Future.delayed(Duration(seconds: 1));
      setState(() {
        _msg = null;
      });
      return;
    }

    _formKey.currentState.save();
    debugPrint("$_password|$_newPassword");

    try {
      final response = await _apiService.changePassword(
          _email, _password, _newPassword, _token);

      setState(() {
        _isLoading = false;
        _msg = response.message;
      });
      await Future.delayed(Duration(seconds: 1));
      setState(() {
        _msg = null;
      });
    } on MyHttpException catch (e) {
      setState(() {
        _isLoading = false;
        _msg = e.message;
      });
      await Future.delayed(Duration(seconds: 1));
      setState(() {
        _msg = null;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _msg = 'Unknown error occurred';
      });
      await Future.delayed(Duration(seconds: 1));
      setState(() {
        _msg = null;
      });
      throw e;
    }
  }
}
