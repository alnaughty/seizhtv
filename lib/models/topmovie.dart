import 'details.dart';

class TopMovieModel extends Details {
  const TopMovieModel({
    required super.backdropPath,
    required super.id,
    required super.origLanguage,
    required super.originalName,
    required super.overview,
    required super.popularity,
    required super.posterPath,
    required super.date,
    required super.title,
    required super.voteAverage,
    required super.voteCount,
  });

  factory TopMovieModel.fromJson(Map<String, dynamic> json) {
    return TopMovieModel(
      id: json['id'].toInt(),
      title: json['title'],
      backdropPath: json['backdrop_path'],
      originalName: json['original_title'],
      origLanguage: json["original_language"],
      overview: json['overview'],
      popularity: json['popularity'].toDouble(),
      posterPath: json['poster_path'],
      date: json['release_date'] == null
          ? null
          : DateTime.parse(json["release_date"]),
      voteAverage: json['vote_average'].toDouble(),
      voteCount: json['vote_count'].toInt(),
    );
  }

  void add(TopMovieModel result) {}
}
