import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:http/http.dart' as http;
import 'package:uni_links/uni_links.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

String? accessToken123 = "";

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();

    _initUniLinks();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _initUniLinks() async {
    try {
      final initialLink = await getInitialLink();
      if (initialLink != null) {
        print('Initial link: $initialLink');
        _handleDeepLink(Uri.parse(initialLink));
      } else {
        print('No initial link found.');
      }

      _sub = linkStream.listen((String? link) {
        if (link != null) {
          print('Stream link: $link');
          _handleDeepLink(Uri.parse(link));
        }
      });
    } on PlatformException catch (e) {
      print('PlatformException: $e');
    }
  }

  void _handleDeepLink(Uri uri) {
    // Print the full URL received
    print('Received deep link: $uri');

    final code = uri.queryParameters['code'];
    final accessToken = uri.queryParameters['accessToken'];
    final refreshToken = uri.queryParameters['refreshToken'];
    final profile = uri.queryParameters['profile'];

    if (code != null) {
      print('Received code: $code');
      // Exchange the code for tokens if needed
      _handleCodeExchange(code);
    } else {
      print('No code found in deep link.');
    }

    if (accessToken != null) {
      print('Received access token: $accessToken');
      accessToken123 = accessToken;
    } else {
      print('No access token found in deep link.');
    }

    if (refreshToken != null) {
      print('Received refresh token: $refreshToken');
    } else {
      print('No refresh token found in deep link.');
    }

    if (profile != null) {
      print('Received profile: $profile');
    } else {
      print('No profile found in deep link.');
    }
  }

  Future<void> _authenticate() async {
    final storage =
        FlutterSecureStorage(); // Create an instance of secure storage

    try {
      // The scheme should be just "timesgaze" as registered in your app configuration
      final callbackUrlScheme = 'timesgaze';

      // Start the authentication process
      final result = await FlutterWebAuth.authenticate(
        url: 'https://timesgaze-oauth.vercel.app/auth/google',
        callbackUrlScheme: callbackUrlScheme,
      );

      // Log the result
      print('Authentication result: $result');

      // Parse the result URL to extract the tokens and other parameters
      final uri = Uri.parse(result);
      final accessTokennew = uri.queryParameters['accessToken'];
      final refreshToken = uri.queryParameters['refreshToken'];
      // accessToken123 = uri.queryParameters['accessToken'].toString();
      if (accessTokennew != null && refreshToken != null) {
        // Print the tokens (for debugging purposes)

        print('Access Token: $accessTokennew');
        print('Refresh Token: $refreshToken');

        // Store tokens securely
        await storage.write(key: 'access_token', value: accessTokennew);
        await storage.write(key: 'refresh_token', value: refreshToken);

        // Additional data can be extracted if needed
        final profile = uri.queryParameters['profile'];
        print('Profile Data: $profile');

        // You can parse and use profile data if needed, e.g., to display user info
      } else {
        print('Tokens are missing in the callback URL');
      }
    } catch (e) {
      print('Authentication error: $e');
    }
  }

  Future<String?> _getStoredAccessToken() async {
    final storage = FlutterSecureStorage();
    String? accessToken = await storage.read(key: 'access_token');
    return accessToken;
  }

  Future<String?> _getStoredRefreshToken() async {
    final storage = FlutterSecureStorage();
    String? refreshToken = await storage.read(key: 'refresh_token');
    return refreshToken;
  }

  Future<void> _fetchAlbums(String accessToken) async {
    print("acess token album $accessToken123");
    final authHeaders = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };

    try {
      var res = await http.get(
        Uri.parse('https://photoslibrary.googleapis.com/v1/albums'),
        headers: authHeaders,
      );
      final result = json.decode(res.body);

      if (result.containsKey('albums') && result['albums'] is List) {
        print('Albums found:');
        for (var album in result['albums']) {
          final albumId = album['id'];
          final title = album['title'];
          print('Album ID: $albumId, Title: $title');
          // Optionally, you can fetch photos for each album here
          // await fetchPhotosForAlbum(albumId, authHeaders);
        }
      } else {
        print('No albums found.');
      }
    } catch (e) {
      print('Error fetching albums: $e');
    }
  }

  Future<void> fetchPhotosForAlbum(
      String albumId, Map<String, String> authHeaders) async {
    try {
      String nextPageToken = '';
      do {
        final url = Uri.parse(
            'https://photoslibrary.googleapis.com/v1/mediaItems:search?pageToken=$nextPageToken');
        final response = await http.post(
          url,
          headers: authHeaders,
          body: jsonEncode({
            "albumId": albumId,
          }),
        );
        final result = json.decode(response.body);

        if (result.containsKey('mediaItems') && result['mediaItems'] is List) {
          for (var item in result['mediaItems']) {
            print('Photo URL: ${item['baseUrl']}');
            // Process each photo's data as needed
          }
        }

        nextPageToken = result['nextPageToken'] ?? '';
      } while (nextPageToken.isNotEmpty);
    } catch (e) {
      print('Error fetching photos for album $albumId: $e');
    }
  }

  Future<void> _handleCodeExchange(String code) async {
    final response = await http.get(
      Uri.parse(
          'https://timesgaze-oauth.vercel.app/auth/google/callback?code=$code'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // Handle authentication data (e.g., save tokens)
      print('Authentication successful!');
      print('Access Token: ${data['accessToken']}');
      print('Refresh Token: ${data['refreshToken']}');
    } else {
      print(
          'Failed to exchange code for tokens: ${response.statusCode} ${response.reasonPhrase}');
      print('Response body: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Authentication'),
      ),
      body: Column(children: [
        Center(
          child: ElevatedButton(
            onPressed: _authenticate,
            child: Text('Sign in with Google'),
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            // String? accessTokentest = await _getStoredAccessToken();
            _fetchAlbums(accessToken123!);
          },
          child: Text('Sign in with Google'),
        ),
      ]),
    );
  }
}
