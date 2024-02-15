class M3uSource {
  final String source;
  final bool isFile;
  final String name;

  const M3uSource({
    required this.source,
    required this.isFile,
    required this.name,
  });

  factory M3uSource.fromFirestore(Map<String, dynamic> json) => M3uSource(
        source: json['source'],
        isFile: json['is_file'],
        name: json['name'],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "is_file": isFile,
        "source": source,
      };

  @override
  String toString() => "${toJson()}";
}
