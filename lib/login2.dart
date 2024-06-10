import 'package:flutter/material.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart'; // Import the url_launcher package

class Login3 extends StatefulWidget {
  const Login3({Key? key}) : super(key: key);

  @override
  State<Login3> createState() => _Login3State();
}

class _Login3State extends State<Login3> {
  final storage = FlutterSecureStorage();
  String? _refreshToken;

  Future<void> _handleSignIn() async {
    final url = 'https://timesgaze-oauth.vercel.app/auth/google';

    try {
      final result = await FlutterWebAuth.authenticate(
          url: url, callbackUrlScheme: "http");
      final code = Uri.parse(result).queryParameters['code'];

      final response = await http.get(Uri.parse(
          'https://timesgaze-oauth.vercel.app/auth/google/callback?code=$code'));

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final accessToken = responseBody['accessToken'];
        final refreshToken = responseBody['refreshToken'];

        // Save tokens securely
        await storage.write(key: 'accessToken', value: accessToken);
        await storage.write(key: 'refreshToken', value: refreshToken);

        setState(() {
          _refreshToken = refreshToken;
        });

        print('Access Token: $accessToken');
        print('Refresh Token: $refreshToken');
        print('Response: $responseBody'); // Print the response

        // Now launch your application's URL to navigate back to your app
        _launchAppUrl(); // Function to launch your app's URL
      } else {
        print('Failed to retrieve tokens from server');
      }
    } catch (error) {
      print('Error signing in: $error');
    }
  }

  // Function to launch your application's URL
  _launchAppUrl() async {
    const url =
        'timesgaze://timesgaze.com'; // Replace 'yourapp' with your app's URL scheme
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Google Sign-In'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: ElevatedButton(
              onPressed: _handleSignIn,
              child: Text('Sign in with Google'),
            ),
          ),
          SizedBox(height: 20),
          if (_refreshToken != null) ...[
            Text('Refresh Token:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            SelectableText(_refreshToken ?? 'No refresh token',
                textAlign: TextAlign.center),
          ],
        ],
      ),
    );
  }
}
