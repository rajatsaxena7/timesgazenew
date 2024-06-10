import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timesgaze/common/constants.dart';
import 'package:timesgaze/controllers/auth_controller.dart';
import 'package:timesgaze/repositories/auth_repositories.dart';
import 'package:timesgaze/screens/enable_facebook_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();

    _startSignInTimer();
  }

  void _startSignInTimer() {
    _timer = Timer.periodic(Duration(hours: 1), (Timer timer) {
      signInSilently(context, ref);
    });
  }

  void signInWithGoogle(BuildContext context, WidgetRef ref)async {
   await  ref.read(authControllerProvider).signInWithGoogle(context);


  await signInSilently(context, ref);
 Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: ((context) => EnableFacebook(photos: photosfinal))),
      );


  }

   signInSilently(BuildContext context, WidgetRef ref) {
    ref.read(authControllerProvider).signInSilently(context);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final devicewidth = MediaQuery.of(context).size.width;
    final deviceheight = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Container(
                height: deviceheight * 0.4424,
                width: devicewidth * 0.6944,
                child: Image.asset(
                  'assets/images/Logo.jpg',
                  fit: BoxFit.fill,
                ),
              ),
            ),
            SizedBox(
              height: 0.0295 * deviceheight,
            ),
            Padding(
              padding: EdgeInsets.all(0.0442 * deviceheight),
              child: ElevatedButton.icon(
                onPressed: () {
                  //  SigninAndPhotos().signInWithGoogle(context);
                  // AuthRepository(
                  //         firestore: FirebaseFirestore.instance,
                  //         auth: FirebaseAuth.instance,
                  //         googleSignIn: GoogleSignIn())
                  //     .signInWithGoogle(context);
                  signInWithGoogle(context, ref);
                },
                icon: Image.asset(
                  Constants.googlePath,
                  width: devicewidth * 0.0972,
                ),
                label: Text(
                  'Continue with Google',
                  style: TextStyle(
                      fontSize: deviceheight * 0.0265, color: Colors.black),
                ),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    minimumSize: Size(double.infinity, deviceheight * 0.0737),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: Color.fromARGB(255, 245, 166, 75),
                      ),
                      borderRadius:
                          BorderRadius.circular(0.0295 * deviceheight),
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
