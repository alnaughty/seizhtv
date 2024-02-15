class CreatedbyModel {
  final int id;
  final String creditId;
  final String name;
  final int gender;
  final String? profile;

  const CreatedbyModel({
    required this.id,
    required this.creditId,
    required this.name,
    required this.gender,
    required this.profile,
  });
  factory CreatedbyModel.fromJson(Map<String, dynamic> json) => CreatedbyModel(
        id: json['id'].toInt(),
        creditId: json['credit_id'],
        name: json['name'],
        gender: json['gender'].toInt(),
        profile: json['profile_path'],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "credit_id": creditId,
        'gender': gender,
        "profile_path": profile,
      };

  @override
  String toString() => "${toJson()}";
}
