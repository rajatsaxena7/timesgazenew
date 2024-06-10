import 'package:flutter/material.dart';
import 'package:timesgaze/common/constants.dart';

import 'package:timesgaze/screens/login_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String version = '';
  @override
  void initState() {
    getVersionInfo();
    super.initState();
  }

  Future<void> getVersionInfo() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        version = packageInfo.version;
      });
      print(version);
    } catch (e) {
      print('Error fetching version: $e');
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
 
    final deviceheight = MediaQuery.of(context).size.height; //678

    void navigateToPhotoScreen() {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => LoginScreen(),
        
        ),
      );
    }


    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
          child: Center(
        child: TweenAnimationBuilder(
          onEnd: () {
            navigateToPhotoScreen();
          },
          tween: Tween<double>(
              begin: deviceheight * 0.1474, end: 500), //deviceheight*0.1474
          curve: Curves.bounceInOut,
          duration: Duration(seconds: 3),
          builder: (context, value, child) => Image.asset(
            Constants.logoPath,
            height: value,
            width: value,
          ),
        ),
      )),
    );
  }
}
