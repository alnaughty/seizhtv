import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../globals/network.dart';
import '../models/movie_details.dart';
import '../models/tvshow_details.dart';
import '../viewmodel/movie_vm.dart';
import '../viewmodel/tvshow_vm.dart';

class FeaturedAPI {
  final Dio dio = Dio();
  static final String _apiKey = dotenv.get("TMDB_APIKEY");
  static final TopRatedMovieViewModel _topRatedMovieViewModel =
      TopRatedMovieViewModel.instance;
  static final TopRatedTVShowViewModel _topRatedTVShowViewModel =
      TopRatedTVShowViewModel.instance;

  Future<void> topRatedMovie() async {
    try {
      return dio
          .get(
        "${Network.tmdbDomain}/movie/top_rated?api_key=$_apiKey",
        options: Options(headers: {
          "accept": "application/json",
        }),
      )
          .then((response) {
        if (response.statusCode == 200) {
          final List data = response.data['results'];
          _topRatedMovieViewModel
              .populate(data.map((e) => MovieDetails.fromJson(e)).toList());
          return;
        }
        return;
      });
    } catch (e) {
      print("LATEST MOVIE ERROR $e");
      return;
    }
  }

  Future<void> topRatedTVShow() async {
    try {
      return dio
          .get("${Network.tmdbDomain}/tv/top_rated?api_key=$_apiKey",
              options: Options(headers: {
                "accept": "application/json",
              }))
          .then((response) {
        if (response.statusCode == 200) {
          final List data = response.data['results'];
          _topRatedTVShowViewModel
              .populate(data.map((e) => TVShowDetails.fromJson(e)).toList());
          return;
        }
        return;
      });
    } catch (e) {
      return;
    }
  }

  // Future<void> getVideos({required int id}) async{
  //   try{
  //     return dio
  //         .get("${Network.tmdbDomain}/movie/$id/videos?api_key=$_apiKey",
  //             options: Options(headers: {
  //               "accept": "application/json",
  //             }))
  //         .then((response) {
  //       if (response.statusCode == 200) {
  //         final List data = response.data['results'];
  //         _topRatedTVShowViewModel
  //             .populate(data.map((e) => TVShowDetails.fromJson(e)).toList());
  //         return;
  //       }
  //       return;
  //     });
  //   }
  //   catch (e){
  //     return;
  //   }
  // }
}
