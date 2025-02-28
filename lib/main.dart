import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_project/common/bloc/auth/auth_state.dart';
import 'package:my_project/common/bloc/auth/auth_state_cubit.dart';
import 'package:my_project/core/configs/theme/app_theme.dart';
import 'presentation/auth/pages/signin.dart';
import 'presentation/main/main_tab_view.dart';
import 'service_locator.dart';
import 'dart:io';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupServiceLocator();
  // await dotenv.load(fileName: ".env");
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  // await initFirebaseMessaging();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black));

  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom]);
    return BlocProvider(
      create: (context) => AuthStateCubit()..appStarted(),
      child: BlocBuilder<AuthStateCubit, AuthState>(
        builder: (context, state) {
          return MaterialApp(
            title: 'Money Mind',
            theme: AppTheme.appTheme,
            debugShowCheckedModeBanner: false,
            home: BlocBuilder<AuthStateCubit, AuthState>(
              builder: (context, state) {
                if (state is Authenticated) {
                  return MainTabView();
                }
                if (state is UnAuthenticated) {
                  return SigninPage();
                }
                return Container();
              },
            ),
            routes: {
              '/signin': (context) => const SigninPage(),
              '/main': (context) => const MainTabView(),
            },
          );
        },
      ),
    );
  }
}
