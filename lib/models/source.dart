class M3uSource {
  final String source;
  final bool isFile;
  final String name;
  final DateTime? expDate;

  const M3uSource({
    required this.source,
    required this.isFile,
    required this.name,
    required this.expDate,
  });

  factory M3uSource.fromFirestore(Map<String, dynamic> json) => M3uSource(
        source: json['source'],
        isFile: json['is_file'],
        name: json['name'],
        expDate: DateTime.parse(json["exp_date"].toDate().toString()),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "is_file": isFile,
        "source": source,
        "exp_date": expDate,
      };

  @override
  String toString() => "${toJson()}";
}
