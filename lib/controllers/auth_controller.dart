import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timesgaze/repositories/auth_repositories.dart';
import 'package:timesgaze/screens/enable_facebook_screen.dart';
import 'package:timesgaze/screens/google_photos_screen.dart';

final authControllerProvider = Provider((ref) => AuthController(
      authRepository: ref.read(authRepositoryProvider),
    ));

class AuthController {
  final AuthRepository _authRepository;
  AuthController({required AuthRepository authRepository})
      : _authRepository = authRepository;

   signInWithGoogle(BuildContext context) async{
    await  _authRepository.signInWithGoogle(context);
  }
    void signInSilently(BuildContext context) async{
   await  _authRepository.signInSilently(context);
  }

  void signInWithFacebook(BuildContext context) {
    _authRepository.signInWithFacebook(context);
  }

  void logOut(BuildContext context) {
    _authRepository.logOut(context);
  }

  void logoutFromFacebook(BuildContext context) {
    _authRepository.logoutFromFacebook(context);
  }
}
