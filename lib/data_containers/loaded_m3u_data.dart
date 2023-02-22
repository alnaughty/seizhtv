import 'package:rxdart/subjects.dart';
import 'package:z_m3u_handler/z_m3u_handler.dart';

class LoadedM3uData {
  LoadedM3uData._pr();
  static final LoadedM3uData _instance = LoadedM3uData._pr();
  static LoadedM3uData get instance => _instance;

  BehaviorSubject<CategorizedM3UData> _subject =
      BehaviorSubject<CategorizedM3UData>();
  Stream<CategorizedM3UData> get stream => _subject.stream;
  CategorizedM3UData? get current => _subject.value;

  void populate(CategorizedM3UData data) {
    _subject.add(data);
  }

  dispose() {
    _subject = BehaviorSubject<CategorizedM3UData>();
  }
}
