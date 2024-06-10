import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timesgaze/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timesgaze/login2.dart';
import 'package:timesgaze/login23.dart';
import 'package:timesgaze/screens/signInSilentlyScreen.dart';
import 'package:timesgaze/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  runApp(ProviderScope(child: MyApp(isLoggedIn: isLoggedIn)));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'TimesGaze',
        debugShowCheckedModeBanner: false,
        home:

            //  isLoggedIn ? GetPhotosFromLocalStorage() :

            // isLoggedIn ? SignInSilentlyScreen() :
            AuthPage());
  }
}
