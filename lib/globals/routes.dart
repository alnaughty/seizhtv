import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:seizhtv/views/auth/children/playlist.dart';
import 'package:seizhtv/views/auth/main_auth.dart';
import 'package:seizhtv/views/landing_page/children/home_children/history.dart';
import 'package:seizhtv/views/landing_page/children/profile.dart';
import 'package:seizhtv/views/landing_page/children/search/search_live.dart';
import 'package:seizhtv/views/landing_page/children/search/search_movies.dart';
import 'package:seizhtv/views/landing_page/children/search/search_series.dart';
import 'package:seizhtv/views/landing_page/children/series_children/series_details.dart';
import 'package:seizhtv/views/landing_page/main_landing_page.dart';
import 'package:seizhtv/views/splash_screen.dart';
import 'package:z_m3u_handler/z_m3u_handler.dart';

class Routes {
  Routes._pr();
  static final Routes _instance = Routes._pr();
  static Routes get instance => _instance;
  static const Duration _transitionDuration = Duration(milliseconds: 500);
  Route<dynamic>? Function(RouteSettings) settings = (RouteSettings settings) {
    switch (settings.name) {
      case "/search-live-page":
        return PageTransition(
          child: const SearchLive(),
          type: PageTransitionType.rightToLeft,
          duration: _transitionDuration,
          reverseDuration: _transitionDuration,
        );
      case "/search-movies-page":
        return PageTransition(
          child: const SearchMovies(),
          type: PageTransitionType.rightToLeft,
          duration: _transitionDuration,
          reverseDuration: _transitionDuration,
        );
      case "/search-series-page":
        return PageTransition(
          child: const SearchSeries(),
          type: PageTransitionType.rightToLeft,
          duration: _transitionDuration,
          reverseDuration: _transitionDuration,
        );
      case "/history-page":
        return PageTransition(
          child: const HistoryPage(),
          type: PageTransitionType.rightToLeft,
          duration: _transitionDuration,
          reverseDuration: _transitionDuration,
        );
      case "/series-details":
        final ClassifiedData data = settings.arguments as ClassifiedData;
        return PageTransition(
          child: SeriesDetails(
            data: data,
          ),
          type: PageTransitionType.rightToLeft,
          duration: _transitionDuration,
          reverseDuration: _transitionDuration,
        );
      case "/profile-page":
        return PageTransition(
          child: const ProfilePage(),
          type: PageTransitionType.rightToLeft,
          duration: _transitionDuration,
          reverseDuration: _transitionDuration,
        );
      case "/landing-page":
        return PageTransition(
          child: const MainLandingPage(),
          type: PageTransitionType.rightToLeft,
          duration: _transitionDuration,
          reverseDuration: _transitionDuration,
        );
      case "/load-playlist":
        return PageTransition(
          child: LoadPlaylist(),
          type: PageTransitionType.rightToLeft,
          duration: _transitionDuration,
          reverseDuration: _transitionDuration,
        );
      // case "/login":
      //   return PageTransition(
      //     child: const LoginPage(),
      //     type: PageTransitionType.rightToLeft,
      //     duration: _transitionDuration,
      //     reverseDuration: _transitionDuration,
      //   );

      case "/auth":
        return PageTransition(
          child: const MainAuthPage(),
          type: PageTransitionType.rightToLeft,
          duration: _transitionDuration,
          reverseDuration: _transitionDuration,
        );
      default:
        return PageTransition(
          child: const SplashScreen(),
          type: PageTransitionType.rightToLeft,
          duration: _transitionDuration,
          reverseDuration: _transitionDuration,
        );
    }
  };
}
