import 'package:seizhtv/models/details.dart';

class TVShowDetails extends Details {
  final List<String> originCountry;

  const TVShowDetails({
    required super.backdropPath,
    required super.genres,
    required super.id,
    required this.originCountry,
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

  factory TVShowDetails.fromJson(Map<String, dynamic> json) {
    final List genres = json['genre_ids'] ?? [];
    final List country = json['origin_country'] ?? [];

    return TVShowDetails(
      id: json['id'].toInt(),
      title: json['name'],
      backdropPath: json['backdrop_path'],
      genres: genres.map((e) => int.parse(e.toString())).toList(),
      originCountry: country.map((e) => e.toString()).toList(),
      originalName: json['original_name'],
      origLanguage: json["original_language"],
      overview: json['overview'],
      popularity: json['popularity'].toDouble(),
      posterPath: json['poster_path'],
      date: json['first_air_date'] == null
          ? null
          : DateTime.parse(json['first_air_date'].toString()),
      voteAverage: json['vote_average'].toDouble(),
      voteCount: json['vote_count'].toInt(),
    );
  }
}
