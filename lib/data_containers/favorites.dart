import 'package:rxdart/subjects.dart';
import 'package:seizhtv/extensions/categorized_m3u.dart';
import 'package:z_m3u_handler/z_m3u_handler.dart';

class Favorites {
  Favorites._pr();
  static final Favorites _instance = Favorites._pr();
  static Favorites get instance => _instance;

  BehaviorSubject<CategorizedM3UData> _subject =
      BehaviorSubject<CategorizedM3UData>();
  Stream<CategorizedM3UData> get stream => _subject.stream;
  CategorizedM3UData get current => _subject.value;

  void dispose() {
    _subject = BehaviorSubject<CategorizedM3UData>();
  }

  void populate(CategorizedM3UData data) {
    _subject.add(data);
  }

  /// [src] is the key whether its movie,series, or live
  void appendIn(String src, {required M3uEntry entry}) {
    final CategorizedM3UData _f = current.clone();
    switch (src) {
      case "movie":
        _f.movies
            .where((element) => element.name == entry.attributes['title-clean'])
            .first
            .data
            .add(entry);
        populate(_f);
        return;

      case "series":
        _f.series
            .where((element) => element.name == entry.attributes['title-clean'])
            .first
            .data
            .add(entry);
        populate(_f);
        return;
      case "live":
        _f.live
            .where((element) => element.name == entry.attributes['title-clean'])
            .first
            .data
            .add(entry);
        populate(_f);
        return;
    }
  }

  void removeIn(String src, {required M3uEntry entry}) {
    final CategorizedM3UData _f = current;
    switch (src) {
      case "movie":
        _f.movies
            .where((element) => element.name == entry.attributes['title-clean'])
            .first
            .data
            .removeWhere((element) => element.link == entry.link);
        populate(_f);
        return;

      case "series":
        _f.series
            .where((element) => element.name == entry.attributes['title-clean'])
            .first
            .data
            .removeWhere((element) => element.link == entry.link);
        populate(_f);
        return;
      case "live":
        _f.live
            .where((element) => element.name == entry.attributes['title-clean'])
            .first
            .data
            .removeWhere((element) => element.link == entry.link);
        populate(_f);
        return;
    }
  }
}
