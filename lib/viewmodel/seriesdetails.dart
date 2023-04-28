import 'package:rxdart/rxdart.dart';

import '../models/tvseries_details.dart';

class SeriesDetailsViewModel {
  SeriesDetailsViewModel._pr();
  static final SeriesDetailsViewModel _instance = SeriesDetailsViewModel._pr();
  static SeriesDetailsViewModel get instance => _instance;

  BehaviorSubject<TVSeriesDetails> _subject =
      BehaviorSubject<TVSeriesDetails>();
  Stream<TVSeriesDetails> get stream => _subject.stream;
  TVSeriesDetails get current => _subject.value;

  void populate(TVSeriesDetails data) {
    _subject.add(data);
  }

  void dispose() {
    _subject = BehaviorSubject<TVSeriesDetails>();
  }
}
