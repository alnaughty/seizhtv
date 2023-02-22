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
