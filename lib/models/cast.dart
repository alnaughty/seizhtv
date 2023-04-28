class CastModel {
  final bool? isAdult;
  final int gender;
  final int id;
  final String department;
  final String name;
  final String origName;
  final double popularity;
  final String? profilePath;
  final String character;
  final String creditId;
  final int order;

  CastModel({
    required this.character,
    required this.creditId,
    required this.department,
    required this.gender,
    required this.id,
    required this.isAdult,
    required this.name,
    required this.order,
    required this.origName,
    required this.popularity,
    required this.profilePath,
  });

  factory CastModel.fromJson(Map<String, dynamic> json) => CastModel(
        character: json['character'],
        creditId: json['credit_id'],
        department: json['known_for_department'],
        gender: json['gender'].toInt(),
        id: json['id'],
        isAdult: json['adult'],
        name: json['name'],
        order: json['order'].toInt(),
        origName: json['original_name'],
        popularity: json['popularity'].toDouble(),
        profilePath: json['profile_path'],
      );

  Map<String, dynamic> toJson() => {
        "character": character,
        "credit_id": creditId,
        "known_for_department": department,
        "gender": gender,
        "id": id,
        "adult": isAdult,
        "name": name,
        "order": order,
        "original_name": origName,
        "popularity": popularity,
        "profile_path": profilePath,
      };

  @override
  String toString() => "${toJson()}";
}
