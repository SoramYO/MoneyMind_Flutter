import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_project/presentation/auth/bloc/auth_state.dart';
import 'package:my_project/presentation/auth/bloc/auth_state_cubit.dart';
import 'presentation/auth/pages/signin.dart';
import 'presentation/main/main_tab_view.dart';
import 'service_locator.dart';
import 'dart:io';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupServiceLocator();
  
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
    return BlocProvider(
      create: (context) => AuthStateCubit()..appStarted(),
      child: BlocBuilder<AuthStateCubit, AuthState>(
        builder: (context, state) {
          return MaterialApp(
            title: 'Money Mind',
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            debugShowCheckedModeBanner: false,

            home: state is AuthenticatedState 
                ? const MainTabView()
                : const SigninPage(),
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
