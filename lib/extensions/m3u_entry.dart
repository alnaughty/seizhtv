import 'package:seizhtv/data_containers/favorites.dart';
import 'package:seizhtv/extensions/categorized_m3u.dart';
import 'package:z_m3u_handler/z_m3u_handler.dart';

extension ENTRY on M3uEntry {
  static final Favorites _vm = Favorites.instance;
  bool existsInFavorites(String src) {
    try {
      final CategorizedM3UData _f = _vm.current.clone();
      // _vm.current.;
      print(_vm.current);
      switch (src) {
        case "series":
          return _f.series
              .expand((element) => element.data)
              .map((element) => element.link)
              .toList()
              .contains(link);
        case "movie":
          return _f.movies
              .expand((element) => element.data)
              .map((element) => element.link)
              .toList()
              .contains(link);
        case "live":
          return _f.live
              .expand((element) => element.data)
              .map((element) => element.link)
              .toList()
              .contains(link);
        default:
          return false;
      }
    } catch (e) {
      return false;
    }
  }
}
