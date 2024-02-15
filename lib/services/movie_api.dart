import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:seizhtv/models/cast.dart';

import '../globals/network.dart';
import '../models/get_video.dart';
import '../models/movie_details.dart';
import '../models/topmovie.dart';
import '../viewmodel/cast_vm.dart';
import '../viewmodel/movie_vm.dart';
import '../viewmodel/moviedetails.dart';
import '../viewmodel/video_vm.dart';

class MovieAPI {
  final Dio dio = Dio();
  static final String _apiKey = dotenv.get("TMDB_APIKEY");
  static final TopRatedMovieViewModel _topRatedMovieViewModel =
      TopRatedMovieViewModel.instance;
  static final MovieVideoViewModel _movieVideoViewModel =
      MovieVideoViewModel.instance;
  static final MovieDetailsViewModel _movieDetailsViewModel =
      MovieDetailsViewModel.instance;
  static final CastViewModel _castViewModel = CastViewModel.instance;

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
              .populate(data.map((e) => TopMovieModel.fromJson(e)).toList());
          return;
        }
        return;
      });
    } catch (e) {
      return;
    }
  }

  Future<void> getMovieVideos({required int id}) async {
    try {
      return dio
          .get("${Network.tmdbDomain}/movie/$id/videos?api_key=$_apiKey",
              options: Options(headers: {
                "accept": "application/json",
              }))
          .then((response) {
        if (response.statusCode == 200) {
          final List data = response.data['results'];
          _movieVideoViewModel
              .populate(data.map((e) => Video.fromJson(e)).toList());
          return;
        }
        return;
      });
    } catch (e) {
      return;
    }
  }

  Future<int?> searchMovie({required String title}) async {
    try {
      return dio.get(
        "${Network.tmdbDomain}/search/movie?api_key=$_apiKey",
        options: Options(headers: {
          "accept": "application/json",
        }),
        queryParameters: {"query": title},
      ).then((response) {
        if (response.statusCode == 200) {
          if (response.data['total_results'] != 0) {
            final int data = response.data['results'][0]['id'];
            return data;
          }
          return null;
        }
        return null;
      });
    } catch (e) {
      return null;
    }
  }

  Future<MovieDetails?> movieDetails(int id) async {
    try {
      return dio
          .get(
        "${Network.tmdbDomain}/movie/$id?api_key=$_apiKey",
        options: Options(headers: {
          "accept": "application/json",
        }),
      )
          .then((response) {
        if (response.statusCode == 200) {
          final Map<String, dynamic> data = response.data;
          final movieDetails = MovieDetails.fromJson(data);
          _movieDetailsViewModel.populate(movieDetails);
          return movieDetails;
        }
        return null;
      });
    } catch (e) {
      return null;
    }
  }

  Future<void> cast(int id) async {
    try {
      return dio
          .get(
        "${Network.tmdbDomain}/movie/$id/credits?api_key=$_apiKey",
        options: Options(headers: {
          "accept": "application/json",
        }),
      )
          .then((response) {
        if (response.statusCode == 200) {
          final List data = response.data['cast'];
          _castViewModel
              .populate(data.map((e) => CastModel.fromJson(e)).toList());
          return;
        }
      });
    } catch (e) {
      return;
    }
  }
}
