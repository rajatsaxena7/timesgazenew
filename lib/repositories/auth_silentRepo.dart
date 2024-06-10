import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:timesgaze/repositories/auth_repositories.dart';

import 'package:http/http.dart' as http;
import 'package:timesgaze/screens/google_photos_screen.dart';


class authSilent {
  List<Map<String, String>> photosSilentfinal1 = [];
  GoogleSignIn? _googleSignIn;
  BuildContext? context;
  ProviderRef? ref;
  Future<void> signInSilentlywithFetchAlbum() async {
    final GoogleSignInAccount? user = await _googleSignIn!.signInSilently();
    print(user!.authHeaders);
    final googleAuth = (await user?.authentication);

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    final authHeaders1 = await user!.authHeaders;
    print(authHeaders1);
    print("access token silently ${googleAuth!.accessToken}");
    await fetchAlbums(authHeaders1);
    // Navigator.pushReplacement(
    //   context!,
    //   MaterialPageRoute(
    //       builder: ((context) => GooglePhotos(photos1: photosSilentfinal))),
    // );

    if (currentUser == null) {
      // User could not be signed in
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
}
