import 'package:rxdart/rxdart.dart';
import '../models/topseries.dart';

class TopRatedTVShowViewModel {
  TopRatedTVShowViewModel._pr();
  static final TopRatedTVShowViewModel _instance =
      TopRatedTVShowViewModel._pr();
  static TopRatedTVShowViewModel get instance => _instance;

  BehaviorSubject<List<TopSeriesModel>> _subject =
      BehaviorSubject<List<TopSeriesModel>>();
  Stream<List<TopSeriesModel>> get stream => _subject.stream;
  List<TopSeriesModel> get current => _subject.value;

  void populate(List<TopSeriesModel> data) {
    _subject.add(data);
  }

  void dispose() {
    _subject = BehaviorSubject<List<TopSeriesModel>>();
  }
}
