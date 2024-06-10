import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timesgaze/controllers/auth_controller.dart';
import 'package:timesgaze/repositories/auth_repositories.dart';
import 'package:timesgaze/repositories/auth_silentRepo.dart';
import 'package:timesgaze/screens/google_photos_screen.dart';

class SignInSilentlyScreen extends ConsumerStatefulWidget {
  const SignInSilentlyScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SignInSilentlyScreenState();
}

class _SignInSilentlyScreenState extends ConsumerState<SignInSilentlyScreen> {
  final authSilent AuthSilent = authSilent();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    signInSilently();
  }

  // void signInSilently(BuildContext context, WidgetRef ref) {
  //   ref.read(authControllerProvider).signInSilently(context);
  // }

  Future<void> signInSilently() async {
    try {
      // authSilent auth = authSilent();
      // await auth.signInSilentlywithFetchAlbum();
      ref.read(authControllerProvider).signInSilently(context);
      // void signInSilently(BuildContext context, WidgetRef ref) {
      //   ref.read(authControllerProvider).signInSilently(context);
      //   signInSilently(context, ref);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void showLoadingScreen(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/images/load.gif'),
                SizedBox(height: 20),
                Text("Configuring your Device..."),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    showLoadingScreen(context);

    //print(ref.read(photosSilentProvider));
    //return GooglePhotos(photos1: ref.read(photosSilentProvider));
    return Scaffold(
        body: Container(
      color: Colors.white,
    ));
  }
}
