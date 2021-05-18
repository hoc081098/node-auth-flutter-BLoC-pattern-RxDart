import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc_pattern/flutter_bloc_pattern.dart';
import 'package:image_picker/image_picker.dart';
import 'package:node_auth/data/constants.dart';
import 'package:node_auth/domain/models/auth_state.dart';
import 'package:node_auth/domain/models/user.dart';
import 'package:node_auth/pages/home/home_bloc.dart';
import 'package:octo_image/octo_image.dart';

class HomeUserProfile extends StatelessWidget {
  const HomeUserProfile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final homeBloc = BlocProvider.of<HomeBloc>(context);

    return Card(
      color: Colors.black.withOpacity(0.5),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: RxStreamBuilder<AuthenticationState?>(
          stream: homeBloc.authState$,
          builder: (context, data) {
            if (data == null) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            final user = data.userAndToken?.user;
            return user == null
                ? _buildUnauthenticated(context)
                : _buildProfile(user, homeBloc, context);
          },
        ),
      ),
    );
  }

  Widget _buildProfile(User user, HomeBloc homeBloc, BuildContext context) {
    final imageUrl = user.imageUrl;
    final provider = imageUrl != null
        ? NetworkImage(
            Uri.https(
              baseUrl,
              imageUrl,
            ).toString(),
          ) as ImageProvider
        : AssetImage('assets/user.png');
    final image = OctoImage(
      image: provider,
      fit: BoxFit.cover,
      width: 90.0,
      height: 90.0,
      progressIndicatorBuilder: (_, __) => Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
      ),
      errorBuilder: (_, __, ___) {
        final themeData = Theme.of(context);

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.error,
                color: themeData.accentColor,
              ),
              SizedBox(height: 4),
              Text(
                'Error',
                style: themeData.textTheme.subtitle2!.copyWith(fontSize: 12),
              ),
            ],
          ),
        );
      },
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        ClipOval(
          child: GestureDetector(
            child: image,
            onTap: () => _pickAndUploadImage(homeBloc),
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
              '${user.email}\n${user.createdAt}',
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
  }

  Widget _buildUnauthenticated(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircularProgressIndicator(
              valueColor: const AlwaysStoppedAnimation(Colors.white),
              strokeWidth: 2,
            ),
          ),
          Expanded(
            child: Text(
              'Loging out...',
              style: Theme.of(context).textTheme.subtitle1,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  void _pickAndUploadImage(HomeBloc homeBloc) async {
    final imageFile = await ImagePicker().getImage(
      source: ImageSource.gallery,
      maxWidth: 720.0,
      maxHeight: 720.0,
    );
    if (imageFile == null) {
      return;
    }
    homeBloc.changeAvatar(File(imageFile.path));
  }
}
