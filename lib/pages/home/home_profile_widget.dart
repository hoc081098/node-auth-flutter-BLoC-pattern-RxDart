import 'package:flutter/material.dart';
import 'package:flutter_bloc_pattern/flutter_bloc_pattern.dart';
import 'package:node_auth/data/constants.dart';
import 'package:node_auth/domain/models/app_error.dart';
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
        child: RxStreamBuilder<Result<AuthenticationState>?>(
          stream: homeBloc.authState$,
          builder: (context, result) {
            if (result == null) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            final user = result.orNull()?.userAndToken?.user;
            return user == null
                ? _buildUnauthenticated(context)
                : RxStreamBuilder<bool>(
                    stream: homeBloc.isUploading$,
                    builder: (context, isUploading) =>
                        _buildProfile(user, homeBloc, context, isUploading),
                  );
          },
        ),
      ),
    );
  }

  Widget _buildProfile(
    User user,
    HomeBloc homeBloc,
    BuildContext context,
    bool isUploading,
  ) {
    final imageUrl = user.imageUrl;

    final provider = imageUrl != null
        ? NetworkImage(
            Uri.https(
              baseUrl,
              imageUrl,
            ).toString(),
          ) as ImageProvider
        : const AssetImage('assets/user.png');

    final image = OctoImage(
      image: provider,
      fit: BoxFit.cover,
      width: 90.0,
      height: 90.0,
      progressIndicatorBuilder: (_, __) => const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
      ),
      errorBuilder: (context, e, st) {
        debugPrint('$e $st');
        final themeData = Theme.of(context);

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.error,
                color: themeData.colorScheme.secondary,
              ),
              const SizedBox(height: 4),
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
        if (isUploading)
          const ImageUploadingWidget()
        else
          ClipOval(
            child: GestureDetector(
              onTap: homeBloc.changeAvatar,
              child: image,
            ),
          ),
        Expanded(
          child: ListTile(
            title: Text(
              user.name,
              style: const TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              '${user.email}\n${user.createdAt}',
              style: const TextStyle(
                fontSize: 16.0,
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
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.white),
              strokeWidth: 2,
            ),
          ),
          Expanded(
            child: Text(
              'Logging out...',
              style: Theme.of(context).textTheme.subtitle1,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class ImageUploadingWidget extends StatelessWidget {
  const ImageUploadingWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      height: 90,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Uploading',
            style: Theme.of(context).textTheme.overline,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
