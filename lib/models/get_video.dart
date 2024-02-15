class Video {
  final String countryCode;
  final String name;
  final String key;
  final String type;
  final String id;

  const Video({
    required this.countryCode,
    required this.id,
    required this.key,
    required this.name,
    required this.type,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      countryCode: json['iso_3166_1'],
      id: json['id'],
      key: json['key'],
      name: json['name'],
      type: json['type'],
    );
  }
}
