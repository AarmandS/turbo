import 'dart:io';

import 'package:better_player/better_player.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:turbo/cubit/auth_cubit.dart';
import 'package:turbo/pages/mainPage.dart';
import 'package:turbo/pages/videoPage.dart';
import 'package:video_player_win/video_player_win_plugin.dart';

import 'cubit/directory_cubit.dart';
import 'cubit/media_cubit.dart';
import 'network_service.dart';
import 'pages/loginPage.dart';

void main() {
  if (!kIsWeb && Platform.isWindows) WindowsVideoPlayer.registerWith();
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  MainApp({super.key});

  final _networkService = NetworkService();

  void initState() {}

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (context) => AuthCubit(_networkService),
        ),
        BlocProvider<DirectoryCubit>(
          create: (context) => DirectoryCubit(_networkService),
        ),
        BlocProvider<MediaCubit>(
          create: (context) => MediaCubit(),
        )
      ],
      child: MaterialApp(
          theme: ThemeData(
              primaryColor: Colors.indigo.shade300,
              colorScheme:
                  ColorScheme.fromSeed(seedColor: Colors.indigo.shade300),
              textTheme: Typography.blackRedwoodCity),
          home: Scaffold(
            backgroundColor: Colors.blueGrey.shade50,
            body: BlocBuilder<AuthCubit, AuthState>(
              builder: (context, authState) {
                var mediaCubit = context.watch<MediaCubit>();
                if (authState is AuthLoggedIn &&
                    mediaCubit.state is MediaInitial) {
                  context
                      .read<DirectoryCubit>()
                      .navigateToDirectory(authState.username);
                  return MainPage(networkService: _networkService);
                } else if (authState is AuthLoggedIn &&
                    mediaCubit.state is MediaVideoPlaying) {
                  return VideoPage();
                }
                // return BetterPlayer.network(
                //   ''
                // )
                return Center(child: LoginPage());
              },
            ),
          )),
    );
  }
}
