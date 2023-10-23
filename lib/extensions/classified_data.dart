import 'package:seizhtv/data_containers/favorites.dart';
import 'package:seizhtv/extensions/categorized_m3u.dart';
import 'package:z_m3u_handler/z_m3u_handler.dart';

extension CLS on ClassifiedData {
  static final Favorites _vm = Favorites.instance;
  bool isInFavorite(String src) {
    try {
      final CategorizedM3UData f = _vm.current.clone();
      switch (src) {
        case "series":
          final List<ClassifiedData> src = List.from(f.series);
          try {
            print("SRC: ${src.length}");
            print("NAME: $name");
            List<M3uEntry> s = [];

            // final ClassifiedData _s =
            //     src.where((element) => element.name == name).first;
            // print("NAME: $_s");
            // return _s.data.length == data.length;
            for (final ClassifiedData sdata in src) {
              print("SDATAAAA: $sdata");
              for (final M3uEntry mdata in sdata.data) {
                if (mdata.title.contains(name)) {
                  s.add(mdata);
                  print("M#U DATA: $s");
                }
              }
            }
            print("SDATAAAA LENGHT: ${s.length} - ${data.length}");
            return s.length == data.length;
            // return false;
          } on StateError {
            return false;
          }
        case "movie":
          final List<ClassifiedData> src0 = List.from(f.movies);
          try {
            final ClassifiedData s =
                src0.where((element) => element.name == name).first;
            return s.data.length == data.length;
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
