import 'package:seizhtv/models/details.dart';

class TopSeriesModel extends Details {
  const TopSeriesModel({
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

  factory TopSeriesModel.fromJson(Map<String, dynamic> json) {
    return TopSeriesModel(
      id: json['id'].toInt(),
      title: json['name'],
      backdropPath: json['backdrop_path'],
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
