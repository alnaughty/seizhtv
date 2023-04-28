import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:seizhtv/viewmodel/cast_vm.dart';
import '../globals/network.dart';
import '../models/cast.dart';
import '../models/get_video.dart';
import '../models/topseries.dart';
import '../models/tvseries_details.dart';
import '../viewmodel/seriesdetails.dart';
import '../viewmodel/tvshow_vm.dart';
import '../viewmodel/video_vm.dart';

class TVSeriesAPI {
  final Dio dio = Dio();
  static final String _apiKey = dotenv.get("TMDB_APIKEY");
  static final TopRatedTVShowViewModel _topRatedTVShowViewModel =
      TopRatedTVShowViewModel.instance;
  static final TVVideoViewModel _tvVideoViewModel = TVVideoViewModel.instance;
  static final SeriesDetailsViewModel _detailsviewModel =
      SeriesDetailsViewModel.instance;
  static final CastViewModel _castViewModel = CastViewModel.instance;

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
              .populate(data.map((e) => TopSeriesModel.fromJson(e)).toList());
          return;
        }
        return;
      });
    } catch (e) {
      return;
    }
  }

  Future<void> getTVVideos({required int id}) async {
    try {
      return dio
          .get("${Network.tmdbDomain}/tv/$id/videos?api_key=$_apiKey",
              options: Options(headers: {
                "accept": "application/json",
              }))
          .then((response) {
        if (response.statusCode == 200) {
          final List data = response.data['results'];
          _tvVideoViewModel
              .populate(data.map((e) => Video.fromJson(e)).toList());
          return;
        }
        return;
      });
    } catch (e) {
      return;
    }
  }

  Future<int?> searchTV({required String title}) async {
    try {
      return dio.get(
        "${Network.tmdbDomain}/search/tv?api_key=$_apiKey",
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

  Future<TVSeriesDetails?> seriesDetails(int id) async {
    try {
      return dio
          .get(
        "${Network.tmdbDomain}/tv/$id?api_key=$_apiKey",
        options: Options(headers: {
          "accept": "application/json",
        }),
      )
          .then((response) {
        if (response.statusCode == 200) {
          final Map<String, dynamic> data = response.data;
          final seriesDetails = TVSeriesDetails.fromJson(data);
          print("DETAILSSS: $seriesDetails");
          _detailsviewModel.populate(seriesDetails);
          return seriesDetails;
        }
        return null;
      });
    } catch (e) {
      return null;
    }
  }

  Future<void> tvSeriesCast(int id) async {
    try {
      return dio
          .get(
        "${Network.tmdbDomain}/tv/$id/credits?api_key=$_apiKey",
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
