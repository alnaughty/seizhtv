import 'package:rxdart/rxdart.dart';
import '../models/get_video.dart';

class MovieVideoViewModel {
  MovieVideoViewModel._pr();
  static final MovieVideoViewModel _instance = MovieVideoViewModel._pr();
  static MovieVideoViewModel get instance => _instance;

  BehaviorSubject<List<Video>> _subject = BehaviorSubject<List<Video>>();
  Stream<List<Video>> get stream => _subject.stream;
  List<Video> get current => _subject.value;

  void populate(List<Video> data) {
    _subject.add(data);
  }

  void dispose() {
    _subject = BehaviorSubject<List<Video>>();
  }
}

class TVVideoViewModel {
  TVVideoViewModel._pr();
  static final TVVideoViewModel _instance = TVVideoViewModel._pr();
  static TVVideoViewModel get instance => _instance;

  BehaviorSubject<List<Video>> _subject = BehaviorSubject<List<Video>>();
  Stream<List<Video>> get stream => _subject.stream;
  List<Video> get current => _subject.value;

  void populate(List<Video> data) {
    _subject.add(data);
  }

  void dispose() {
    _subject = BehaviorSubject<List<Video>>();
  }
}
