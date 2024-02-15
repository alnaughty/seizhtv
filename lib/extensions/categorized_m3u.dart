import 'package:z_m3u_handler/z_m3u_handler.dart';

extension CAT on CategorizedM3UData {
  CategorizedM3UData clone() => CategorizedM3UData(
        live: List.from(live),
        movies: List.from(movies),
        series: List.from(series),
      );
}
