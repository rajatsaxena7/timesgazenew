import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timesgaze/common/constants.dart';
import 'package:timesgaze/controllers/auth_controller.dart';
import 'package:timesgaze/screens/google_photos_screen.dart';
import 'package:timesgaze/screens/localStoredPhotos.dart';

class EnableFacebook extends ConsumerWidget {
  List<Map<String, dynamic>> photos;
  EnableFacebook({super.key, required this.photos});

  void signInWithFacebook(BuildContext context, WidgetRef ref) {
    ref.read(authControllerProvider).signInWithFacebook(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devicewidth = MediaQuery.of(context).size.width;
    final deviceheight = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          title: Row(children: [
            Spacer(),
            InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: ((context) => GooglePhotos(
                            //  photos1: photos,
                            ))));
                //             Navigator.push(
                // context,
                // MaterialPageRoute(
                //     builder: ((context) =>  GetPhotosFromLocalStorage(

                //         ))));
              },
              child: Text(
                'Skip',
                style: TextStyle(color: Colors.black),
                textAlign: TextAlign.right,
              ),
            ),
          ]),
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
        ),
        backgroundColor: Colors.white,
        body: Column(children: [
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
                signInWithFacebook(context, ref);
              },
              icon: Image.asset(
                Constants.facebookPath,
                width: devicewidth * 0.0972,
              ),
              label: Text(
                'Login with Facebook',
                style: TextStyle(
                    fontSize: deviceheight * 0.0265, color: Colors.black),
              ),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  //backgroundColor: const Color.fromARGB(255, 240, 175, 89),
                  minimumSize: Size(double.infinity, deviceheight * 0.0737),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0.0295 * deviceheight),
                    side: BorderSide(
                      color: Color.fromARGB(255, 245, 166, 75),
                    ),
                  )),
            ),
          ),
        ]),
      ),
    );
  }
}
