import 'package:rxdart/rxdart.dart';
import '../models/topmovie.dart';

class TopRatedMovieViewModel {
  TopRatedMovieViewModel._pr();
  static final TopRatedMovieViewModel _instance = TopRatedMovieViewModel._pr();
  static TopRatedMovieViewModel get instance => _instance;

  BehaviorSubject<List<TopMovieModel>> _subject =
      BehaviorSubject<List<TopMovieModel>>();
  Stream<List<TopMovieModel>> get stream => _subject.stream;
  List<TopMovieModel> get current => _subject.value;

  void populate(List<TopMovieModel> data) {
    _subject.add(data);
  }

  void dispose() {
    _subject = BehaviorSubject<List<TopMovieModel>>();
  }
}
