import 'package:seizhtv/models/details.dart';
import 'createdby.dart';
import 'genre.dart';

class TVSeriesDetails extends Details {
  final List<String> originCountry;
  final List<Genre>? genres;
  final List<CreatedbyModel>? createdby;
  final int? numOfSeason;

  const TVSeriesDetails({
    required super.backdropPath,
    required this.genres,
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
    required this.createdby,
    required super.voteCount,
    required this.numOfSeason,
  });

  factory TVSeriesDetails.fromJson(Map<String, dynamic> json) {
    final List genres = json['genres'] ?? [];
    final List country = json['origin_country'] ?? [];
    final List creator = json['created_by'] ?? [];

    return TVSeriesDetails(
      id: json['id'].toInt(),
      title: json['name'],
      backdropPath: json['backdrop_path'],
      createdby: creator.map((e) => CreatedbyModel.fromJson(e)).toList(),
      genres: genres.map((e) => Genre.fromJson(e)).toList(),
      numOfSeason: json['number_of_seasons'].toInt(),
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
