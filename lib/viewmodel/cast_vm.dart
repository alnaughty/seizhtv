import 'package:rxdart/rxdart.dart';

import '../models/cast.dart';

class CastViewModel {
  CastViewModel._pr();
  static final CastViewModel _instance = CastViewModel._pr();
  static CastViewModel get instance => _instance;

  BehaviorSubject<List<CastModel>> _subject =
      BehaviorSubject<List<CastModel>>();
  Stream<List<CastModel>> get stream => _subject.stream;
  List<CastModel> get current => _subject.value;

  void populate(List<CastModel> data) {
    _subject.add(data);
  }

  void dispose() {
    _subject = BehaviorSubject<List<CastModel>>();
  }
}
