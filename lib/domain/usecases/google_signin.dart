import 'package:dartz/dartz.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:my_project/domain/repository/auth.dart';
import 'package:my_project/service_locator.dart';

class GoogleSignInUseCase {
  Future<Either> execute() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId: '1078441841474-69pja39usq8k5em0kggiroaaimf6lju1.apps.googleusercontent.com'
      );
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      
      if (googleUser == null) {
        return const Left('Google sign in cancelled');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      print('Google Auth ID Token: ${googleAuth.idToken}');
      print('Google Auth Access Token: ${googleAuth.accessToken}');
      print('Google Auth Server Token: ${googleAuth.serverAuthCode}');

      print('Google Auth Email: ${googleUser.email}');
      print('Google Auth DisplayName: ${googleUser.displayName}');
      print('Google Auth PhotoUrl: ${googleUser.photoUrl}');
      print('Google Auth ID: ${googleUser.id}');
      print('Google  authentication: ${googleUser.authentication.toString()}');
      print('Google  authHeaders: ${googleUser.authHeaders.toString()}');
      print('Google  domain: ${googleUser.serverAuthCode}');
      print('Google runtimeType: ${googleUser.runtimeType}');

      // Send token to your backend
      final result = await sl<AuthRepository>().googleSignIn(googleAuth.idToken!);

      return result;

    } catch (e) {
      return Left(e.toString());
    }
  }
}