import 'dart:io';

import 'package:better_player/better_player.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:turbo/cubit/auth_cubit.dart';
import 'package:turbo/cubit/signup_cubit.dart';
import 'package:turbo/pages/image_viewer_page.dart';
import 'package:turbo/pages/mainPage.dart';
import 'package:turbo/pages/signup_page.dart';
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
  NetworkService _networkService = NetworkService();
  MainApp({super.key});

  void initState() {}

  @override
  Widget build(BuildContext context) {
    var router = GoRouter(initialLocation: '/login', routes: [
      GoRoute(
          path: '/login',
          pageBuilder: (context, state) => NoTransitionPage<void>(
                child: LoginPage(),
              )),
      GoRoute(
          path: '/signup',
          pageBuilder: (context, state) => NoTransitionPage<void>(
                child: SignupPage(),
              )),
      GoRoute(
          path: '/home',
          pageBuilder: (context, state) => NoTransitionPage<void>(
                child: MainPage(networkService: _networkService),
              )),
      GoRoute(
          path: '/image_viewer',
          pageBuilder: (context, state) => NoTransitionPage<void>(
                child: ImageViewerPage(_networkService),
              )),
    ]);
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (context) => AuthCubit(_networkService),
        ),
        BlocProvider<SignupCubit>(
          create: (context) => SignupCubit(_networkService),
        ),
        BlocProvider<DirectoryCubit>(
          create: (context) => DirectoryCubit(_networkService),
        ),
        BlocProvider<MediaCubit>(
          create: (context) => MediaCubit(),
        )
      ],
      child: MaterialApp.router(
        routerConfig: router,
        theme: ThemeData(
            primaryColor: Colors.indigo.shade300,
            colorScheme:
                ColorScheme.fromSeed(seedColor: Colors.indigo.shade300),
            textTheme: Typography.blackRedwoodCity),
      ),
    );
  }
}
