import 'package:rxdart/rxdart.dart';
import 'package:seizhtv/models/movie_details.dart';

class MovieDetailsViewModel {
  MovieDetailsViewModel._pr();
  static final MovieDetailsViewModel _instance = MovieDetailsViewModel._pr();
  static MovieDetailsViewModel get instance => _instance;

  BehaviorSubject<MovieDetails> _subject = BehaviorSubject<MovieDetails>();
  Stream<MovieDetails> get stream => _subject.stream;
  MovieDetails get current => _subject.value;

  void populate(MovieDetails data) {
    _subject.add(data);
  }

  void dispose() {
    _subject = BehaviorSubject<MovieDetails>();
  }
}
