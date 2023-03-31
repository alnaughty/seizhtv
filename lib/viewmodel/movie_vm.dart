import 'package:rxdart/rxdart.dart';
import '../models/movie_details.dart';

class TopRatedMovieViewModel {
  TopRatedMovieViewModel._pr();
  static final TopRatedMovieViewModel _instance = TopRatedMovieViewModel._pr();
  static TopRatedMovieViewModel get instance => _instance;

  BehaviorSubject<List<MovieDetails>> _subject =
      BehaviorSubject<List<MovieDetails>>();
  Stream<List<MovieDetails>> get stream => _subject.stream;
  List<MovieDetails> get current => _subject.value;

  void populate(List<MovieDetails> data) {
    _subject.add(data);
  }

  void dispose() {
    _subject = BehaviorSubject<List<MovieDetails>>();
  }
}
