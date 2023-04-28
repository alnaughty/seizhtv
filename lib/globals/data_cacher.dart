import 'dart:io';

import 'package:seizhtv/data_containers/favorites.dart';
import 'package:seizhtv/data_containers/history.dart';
import 'package:seizhtv/globals/data.dart';
import 'package:seizhtv/models/m3u_user.dart';
import 'package:seizhtv/services/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataCacher {
  DataCacher._private();
  static final DataCacher _instance = DataCacher._private();
  static final GoogleSignInService _google = GoogleSignInService.instance;
  static DataCacher get instance => _instance;
  static late final SharedPreferences sharedPreferences;
  final Favorites _favVm = Favorites.instance;
  final History _hisVm = History.instance;
  Future<void> saveLoginType(int i) async => await sharedPreferences.setInt(
        "login-type",
        i,
      );
  Future<void> saveDate(String data) async =>
      await sharedPreferences.setString("date", data);
  Future<void> removeData() async => await sharedPreferences.remove("date");
  DateTime? get date {
    final String? d = sharedPreferences.getString("date");
    if (d == null) return null;
    return DateTime.parse(d);
  }

  Future<void> removeLoginType() async =>
      await sharedPreferences.remove("login-type");
  int? get savedLoginType => sharedPreferences.getInt("login-type");
  Future<void> init() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  Future<void> saveFile(File file) async =>
      await sharedPreferences.setString("file", file.path);
  String? get filePath => sharedPreferences.getString("file");
  Future<void> removeFile() async => await sharedPreferences.remove('file');
  Future<void> clearData() async {
    _favVm.dispose();
    _hisVm.dispose();
    if (savedLoginType == 1) {
      await _google.signOut();
    }
    user = null;
    await Future.wait([
      removePlaylistName(),
      removeRefID(),
      removeUrl(),
      removeFile(),
      removeLoginType(),
      removeM3uUser()
    ]);
  }

  Future<void> saveUrl(String url) async =>
      await sharedPreferences.setString("url", url);
  String? get savedUrl => sharedPreferences.getString("url");
  Future<void> removeUrl() async => await sharedPreferences.remove("url");
  Future<bool> removeM3uUser() async =>
      await sharedPreferences.remove("m3u-user");
  Future<void> saveM3uUser(M3uUser user) async {
    await sharedPreferences.setStringList("m3u-user", [
      user.uid,
      user.email ?? "",
      user.displayName ?? "",
      user.photoUrl ?? ""
    ]);
  }

  M3uUser? get m3uUser {
    final List<String>? _d = sharedPreferences.getStringList("m3u-user");
    if (_d == null) return null;
    return M3uUser(
      displayName: _d[2].isEmpty ? null : _d[2],
      email: _d[1].isEmpty ? null : _d[1],
      photoUrl: _d[3].isEmpty ? null : _d[3],
      uid: _d[0],
    );
  }

  /// REFERENCE ID FUNCTIONS
  Future<bool> saveRefID(String ref) async =>
      await sharedPreferences.setString("ref_id", ref);

  String? get refId => sharedPreferences.getString("ref_id");

  Future<bool> removeRefID() async => await sharedPreferences.remove("ref_id");

  /// Playlist functions
  Future<bool> savePlaylistName(String n) async =>
      await sharedPreferences.setString("playlist_name", n);

  String? get playlistName => sharedPreferences.getString("playlist_name");

  Future<bool> removePlaylistName() async =>
      await sharedPreferences.remove("playlist_name");

  /// Exp. Date functions
  Future<bool> saveExpDate(String date) async =>
      await sharedPreferences.setString("exp_date", date);

  String? get expDate => sharedPreferences.getString("exp_date");

  Future<bool> removeExpDate() async =>
      await sharedPreferences.remove("exp_date");
}
