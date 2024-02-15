import 'package:rxdart/rxdart.dart';
import 'package:seizhtv/extensions/categorized_m3u.dart';
import 'package:z_m3u_handler/z_m3u_handler.dart';

class History {
  History._pr();
  static final History _instance = History._pr();
  static History get instance => _instance;
  BehaviorSubject<CategorizedM3UData> _subject =
      BehaviorSubject<CategorizedM3UData>();
  Stream<CategorizedM3UData> get stream => _subject.stream;
  CategorizedM3UData get current => _subject.value;
  void populate(CategorizedM3UData data) {
    _subject.add(data);
  }

  void dispose() {
    _subject = BehaviorSubject<CategorizedM3UData>();
  }

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
}
