import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:timesgaze/screens/google_photos_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

final googlephotosProvider = StateProvider<List<String>>((ref) {
  return [];
});
//List<String> photos = [];

final fbphotosProvider = StateProvider<List<String>>((ref) {
  return [];
});
GoogleSignInAccount? currentUser;
final currentUserGoogle = StateProvider<String>((ref) => '');
final albumEmpty = StateProvider<bool>((ref) => true);
final photosSilentProvider = StateProvider<List<Map<String, String>>>((ref) {
  return [];
});

final photosAppProvider = StateProvider<List<Map<String, String>>>((ref) {
  return [];
});

final defaultPhotos = StateProvider<String>((ref) => 'Last In');
// final storedPhotosProvider =
//     StateProvider<List<Map<String, dynamic>>>((ref) => []);

final userName = StateProvider<String>((ref) => '');
final userEmail = StateProvider<String>((ref) => '');
final photoUrl = StateProvider((ref) => '');

List<Map<String, String>> photosfinal = [];

List<Map<String, String>> photosSilentfinal = [];
//List<Map<String, String>> photos = [];
//List<Map<String, dynamic>> albums = [];
//List<Map<String, String>> threeYearPhotos = [];
//List<Map<String, String>> fiveYearPhotos = [];
final authRepositoryProvider = Provider((ref) => AuthRepository(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
    googleSignIn: GoogleSignIn(),
    ref: ref));

class AuthRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  GoogleSignIn _googleSignIn;
  ProviderRef ref;
  AuthRepository(
      {required FirebaseFirestore firestore,
      required FirebaseAuth auth,
      required GoogleSignIn googleSignIn,
      required this.ref})
      : _auth = auth,
        _firestore = firestore,
        _googleSignIn = googleSignIn;
  Future<String> exchangeAuthCodeForTokens(String serverAuthCode) async {
    final response = await http.post(
      Uri.parse('https://oauth2.googleapis.com/token'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'client_id':
            '318926159367-roj26tf943ojr2b4n3ppang230cd5g0j.apps.googleusercontent.com',
        // 'client_secret': 'YOUR_CLIENT_SECRET', // Make sure to add your client secret here
        'code': serverAuthCode,
        'grant_type': 'authorization_code',
        'redirect_uri':
            'http://localhost', // This must match the one configured in Google Cloud Console
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return jsonResponse['refresh_token'];
    } else {
      print(
          'Failed with status: ${response.statusCode} and reason: ${response.body}');
      throw Exception(
          'Failed to exchange authorization code for tokens: ${response.body}');
    }
  }

  signInWithGoogle(BuildContext context) async {
    try {
      _googleSignIn = GoogleSignIn(
          scopes: [
            'https://www.googleapis.com/auth/photoslibrary',
            // 'https://www.googleapis.com/auth/photoslibrary.sharing',
          ],
          clientId:
              "318926159367-roj26tf943ojr2b4n3ppang230cd5g0j.apps.googleusercontent.com",
          forceCodeForRefreshToken: true);
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      currentUser = _googleSignIn.currentUser!;
      final googleAuth = (await googleUser?.authentication);
      final serverAuthCode = googleAuth?.serverAuthCode;
      print(googleAuth.toString());
      final refreshToken = await exchangeAuthCodeForTokens(serverAuthCode!);
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      final authHeaders = await googleUser!.authHeaders;
      //  print("Auth headers $authHeaders");
      print("access token ${googleAuth!.accessToken}");

//print("id token ${googleAuth!.idToken}");
      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('googleRefreshToken', refreshToken);
      print("refresh token is $refreshToken");
      await prefs.setBool('isLoggedIn', true);
      ref.watch(userEmail.notifier).update((state) => googleUser.email);

      ref
          .watch(userName.notifier)
          .update((state) => userCredential.user!.displayName ?? '');
      ref
          .watch(photoUrl.notifier)
          .update((state) => userCredential.user!.photoURL ?? '');

      showLoadingScreen(context);

      await fetchAlbums(authHeaders);

      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(
      //       builder: ((context) => EnableFacebook(photos: photosfinal))),
      // );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load photos $e'),
        ),
      );
    }
    // await storePhotosInLocalStorage(photos);
    //threeYearPhotos = shuffleList(photos);
    //await storeThreeYearsphotos(threeYearPhotos);
  }

  signInSilently(BuildContext context) async {
    final GoogleSignInAccount? user = await _googleSignIn.signInSilently();
    // print(user!.authHeaders);
    final googleAuth = (await user?.authentication);

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    final authHeaders2 = await user!.authHeaders;
    print(authHeaders2);
    print("access token silently ${googleAuth!.accessToken}");
    await fetchAlbums(authHeaders2);
    if (photosfinal.isEmpty) {
      ref.watch(albumEmpty.notifier).update((state) => true);
    }
    ref
        .watch(photosSilentProvider.notifier)
        .update((state) => photosSilentfinal);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: ((context) => GooglePhotos())),
    );
    if (currentUser == null) {
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: ((context) => LoginScreen())),
      // );
      return;
    }
    print('User signed in silently.');
  }

  Future<void> fetchAlbums(Map<String, String> authHeaders) async {
    try {
      var res = await http.get(
        Uri.parse('https://photoslibrary.googleapis.com/v1/albums'),
        headers: authHeaders,
      );
      final result = json.decode(res.body);
      photosfinal = [];
      ref.watch(photosAppProvider.notifier).update((state) => photosfinal);
      print(ref.read(photosAppProvider));
      if (result.containsKey('albums') && result['albums'] is List) {
        for (var album in result['albums']) {
          final albumId = album['id'];
          // print(albumId);
          await fetchPhotosForAlbum(albumId, authHeaders);
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
          for (var i in result['mediaItems']) {
            photosfinal.add({
              'baseUrl': i['baseUrl'],
              'creationTime': i['mediaMetadata']['creationTime'],
            });
            ref
                .watch(photosAppProvider.notifier)
                .update((state) => photosfinal);

            photosSilentfinal.add({
              'baseUrl': i['baseUrl'],
              'creationTime': i['mediaMetadata']['creationTime'],
            });
            //   print(photosfinal);
            // print(i['mediaMetadata']['creationTime']);
          }
        }

        nextPageToken = result['nextPageToken'] ?? '';
      } while (nextPageToken.isNotEmpty);
    } catch (e) {
      print('Error fetching photos for album $albumId: $e');
    }
  }

  void logOut(BuildContext context) {
    ref.watch(photosAppProvider.notifier).update((state) => []);
    photosfinal = [];
    print(ref.read(photosAppProvider));
    GoogleSignIn? googleSignIn = GoogleSignIn();

    googleSignIn.signOut();
    _auth.signOut();

    Navigator.pop(context);
  }

  Future<void> signInWithFacebook(BuildContext context) async {
    try {
      final LoginResult loginResult = await FacebookAuth.instance
          // .login(permissions: ['email']);
          .login(permissions: ['email', 'user_posts']);
      if (loginResult.status == LoginStatus.success) {
        final AccessToken accessToken = loginResult.accessToken!;
        final String facebookToken = accessToken.token;
        print('Access Token: ${accessToken.token}');
        final OAuthCredential facebookCredential =
            FacebookAuthProvider.credential(accessToken.token);
        await FirebaseAuth.instance.signInWithCredential(facebookCredential);
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithCredential(facebookCredential);
        //   Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //       builder: ((context) => GooglePhotos(photos: photos))),
        // );
        List<String> fphotos = [];
        var res = await http.get(
          Uri.parse(
              'https://graph.facebook.com/v2.12/me?fields=posts{link,full_picture}&access_token=$facebookToken'),
          //Uri.parse('https:www.googleapis.com/auth/drive.photos.readonly'),
        );
        final result = json.decode(res.body);
        List<dynamic> posts = result['posts']['data'];
        for (var post in posts) {
          print('Link: ${post['full_picture']}');
          fphotos.add(post['full_picture']);
          photosfinal.add(post['full_picture']);

          ref.watch(googlephotosProvider.notifier).update((state) => fphotos);
          Navigator.push(
            context,
            MaterialPageRoute(builder: ((context) => GooglePhotos())),
          );
        }
      } else {
        print('Facebook Login Failed');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> logoutFromFacebook(BuildContext context) async {
    try {
      await FacebookAuth.instance.logOut();
      Navigator.pop(context);
      print('Logged out from Facebook');
    } catch (e) {
      print('Error logging out from Facebook: $e');
    }
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
