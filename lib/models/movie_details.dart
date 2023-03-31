import 'package:seizhtv/models/details.dart';

class MovieDetails extends Details {
  final bool video;
  final bool isForAdult;

  const MovieDetails({
    required super.backdropPath,
    required super.genres,
    required super.id,
    required super.origLanguage,
    required super.originalName,
    required super.overview,
    required super.popularity,
    required super.posterPath,
    required this.isForAdult,
    required super.date,
    required super.title,
    required this.video,
    required super.voteAverage,
    required super.voteCount,
  });

  factory MovieDetails.fromJson(Map<String, dynamic> json) {
    final List genres = json['genre_ids'] ?? [];

    return MovieDetails(
      id: json['id'].toInt(),
      title: json['title'],
      backdropPath: json['backdrop_path'],
      isForAdult: json['adult'] ?? false,
      genres: genres.map((e) => int.parse(e.toString())).toList(),
      originalName: json['original_title'],
      origLanguage: json["original_language"],
      overview: json['overview'],
      popularity: json['popularity'].toDouble(),
      posterPath: json['poster_path'],
      date: json['release_date'] == null
          ? null
          : DateTime.parse(json['release_date'].toString()),
      video: json['video'] ?? false,
      voteAverage: json['vote_average'].toDouble(),
      voteCount: json['vote_count'].toInt(),
    );
  }
}
