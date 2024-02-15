// ignore_for_file: depend_on_referenced_packages

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:seizhtv/globals/palette.dart';
import 'package:seizhtv/globals/routes.dart';
import 'package:seizhtv/views/splash_screen.dart';

class SeizhTv extends StatelessWidget with ColorPalette {
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  static final Routes _route = Routes.instance;
  SeizhTv({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Seizh TV',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: "Poppins",
        scaffoldBackgroundColor: card,
        primaryColor: Colors.orange,
        brightness: Brightness.dark,
        radioTheme: RadioThemeData(
          fillColor: MaterialStateColor.resolveWith(
              (states) => Colors.orange), //<-- SEE HERE
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: InputBorder.none,
          isDense: true,
        ),
      ),
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      navigatorObservers: <NavigatorObserver>[observer],
      home: const SplashScreen(),
      onGenerateRoute: _route.settings,
    );
  }
}
