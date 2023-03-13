import 'package:seizhtv/data_containers/favorites.dart';
import 'package:seizhtv/extensions/categorized_m3u.dart';
import 'package:z_m3u_handler/z_m3u_handler.dart';

extension CLS on ClassifiedData {
  static final Favorites _vm = Favorites.instance;
  bool isInFavorite(String src) {
    try {
      final CategorizedM3UData _f = _vm.current.clone();
      switch (src) {
        case "series":
          final List<ClassifiedData> _src = List.from(_f.series);
          try {
            final ClassifiedData _s =
                _src.where((element) => element.name == name).first;
            return _s.data.length == data.length;
          } on StateError {
            return false;
          }
        case "movie":
          final List<ClassifiedData> _src = List.from(_f.movies);
          try {
            final ClassifiedData _s =
                _src.where((element) => element.name == name).first;
            return _s.data.length == data.length;
          } on StateError {
            return false;
          }
        default:
          return false;
      }
    } catch (e) {
      return false;
    }
  }
}
