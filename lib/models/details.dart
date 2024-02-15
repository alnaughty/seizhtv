class Details {
  final int id;
  final String title;
  final String? backdropPath;
  final DateTime? date;
  final String origLanguage;
  final String originalName;
  final String? overview;
  final String? posterPath;
  final double voteAverage;
  final int voteCount;
  final double popularity;

  const Details({
    required this.id,
    required this.title,
    required this.backdropPath,
    this.date,
    required this.overview,
    required this.origLanguage,
    required this.originalName,
    required this.posterPath,
    required this.popularity,
    required this.voteAverage,
    required this.voteCount,
  });
}
