import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:timesgaze/common/constants.dart';
import 'package:timesgaze/repositories/auth_repositories.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devicewidth = MediaQuery.of(context).size.width; //360
    final deviceheight = MediaQuery.of(context).size.height; //678

    //  User? user = FirebaseAuth.instance.currentUser;
    String name = ref.read(userName);

    String email = ref.read(userEmail);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0.0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: FaIcon(
            FontAwesomeIcons.angleLeft,
            color: Colors.black,
            size: deviceheight * 0.0368,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(deviceheight * 0.03), //deviceheight * 0.04719
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  backgroundImage: NetworkImage(ref.read(photoUrl)),
                  radius: deviceheight * 0.06637,
                ),
              ),
              SizedBox(
                height: deviceheight * 0.08849,
              ),
              Row(
                children: [
                  Text(
                    'Email',
                    style: TextStyle(fontSize: deviceheight * 0.02654),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  FittedBox(
                    fit: BoxFit.fitWidth,
                    child: Text(
                      email,
                      style: TextStyle(fontSize: deviceheight * 0.02654),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: deviceheight * 0.05899,
              ),
              Row(
                children: [
                  Text(
                    'Name',
                    style: TextStyle(fontSize: deviceheight * 0.02654),
                  ),
                  SizedBox(
                    width: devicewidth * 0.0555,
                  ),
                  Text(
                    name,
                    style: TextStyle(fontSize: deviceheight * 0.02654),
                  )
                ],
              ),
            ]),
      ),
    );
  }
}
