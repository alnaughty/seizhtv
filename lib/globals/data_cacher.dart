import 'package:seizhtv/models/m3u_user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataCacher {
  DataCacher._private();
  static final DataCacher _instance = DataCacher._private();
  static DataCacher get instance => _instance;
  static late final SharedPreferences sharedPreferences;
  Future<void> init() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  Future<void> clearData() async {
    await removePlaylistName();
    await removeRefID();
  }

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
}
