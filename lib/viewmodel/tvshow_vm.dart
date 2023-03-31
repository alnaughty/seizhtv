import 'package:rxdart/rxdart.dart';
import '../models/tvshow_details.dart';

class TopRatedTVShowViewModel {
  TopRatedTVShowViewModel._pr();
  static final TopRatedTVShowViewModel _instance =
      TopRatedTVShowViewModel._pr();
  static TopRatedTVShowViewModel get instance => _instance;

  BehaviorSubject<List<TVShowDetails>> _subject =
      BehaviorSubject<List<TVShowDetails>>();
  Stream<List<TVShowDetails>> get stream => _subject.stream;
  List<TVShowDetails> get current => _subject.value;

  void populate(List<TVShowDetails> data) {
    _subject.add(data);
  }

  void dispose() {
    _subject = BehaviorSubject<List<TVShowDetails>>();
  }
}
