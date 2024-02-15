import 'package:flutter_dotenv/flutter_dotenv.dart';

class Network {
  static final String tmdbDomain = dotenv.get("URL");
  static const String imageUrl = "https://image.tmdb.org/t/p/w500//";
}
