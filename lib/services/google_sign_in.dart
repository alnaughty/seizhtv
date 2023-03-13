import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:seizhtv/globals/data_cacher.dart';
import 'package:z_m3u_handler/z_m3u_handler.dart';

class GoogleSignInService {
  GoogleSignInService._pr();
  static final GoogleSignInService _instance = GoogleSignInService._pr();
  static final DataCacher _cacher = DataCacher.instance;
  static GoogleSignInService get instance => _instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  static final FirebaseAuth auth = FirebaseAuth.instance;
  Future<void> _handleGetContact(GoogleSignInAccount user) async {
    final http.Response response = await http.get(
      Uri.parse('https://people.googleapis.com/v1/people/me/connections'
          '?requestMask.includeField=person.names'),
      headers: await user.authHeaders,
    );
    if (response.statusCode != 200) {
      return;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }

  Future<CredentialProvider?> signIn() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;
      _handleGetContact(googleUser);
      final GoogleSignInAuthentication? googleAuth =
          await googleUser.authentication;
      if (googleAuth == null) return null;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final authResult = await auth.signInWithCredential(credential);
      final firebaseUser = authResult.user;
      return CredentialProvider(url: "url", user: firebaseUser!);
      // return firebaseUser;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        Fluttertoast.showToast(msg: "User not found");
      } else if (e.code == 'wrong-password') {
        Fluttertoast.showToast(msg: "Incorrect password");
      } else if (e.code == "account-exists-with-different-credential") {
        Fluttertoast.showToast(
            msg: "Account exists, but with different credentials");
      }
      return null;
    } on SocketException {
      Fluttertoast.showToast(msg: "No Internet Connection");
      return null;
    } on HttpException {
      Fluttertoast.showToast(
          msg: "An error has occured while processing your request");
      return null;
    } on FormatException {
      Fluttertoast.showToast(msg: "Format error: Contact Developer");
      return null;
    } on TimeoutException {
      Fluttertoast.showToast(
          msg: "No Internet Connection : Connection Timeout");
      return null;
    }
  }
}
