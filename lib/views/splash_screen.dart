// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:page_transition/page_transition.dart';
import 'package:seizhtv/globals/data.dart';
import 'package:seizhtv/globals/data_cacher.dart';
import 'package:seizhtv/globals/logo.dart';
import 'package:seizhtv/globals/palette.dart';
import 'package:seizhtv/views/landing_page/source_management.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final DataCacher _cacher = DataCacher.instance;
  Future<void> check() async {
    refId = _cacher.refId;
    user = _cacher.m3uUser;
    sourceUrl = _cacher.source;
    playlistName = _cacher.playlistName;
    language = _cacher.language;
    file = _cacher.filePath;

    print("REF ID: $refId");
    print("USER: $user");
    print("SOURCE URL: $sourceUrl");
    print("PLAYLIST NAME: $playlistName");
    print("LANGUAGE: $language");
    print("FILE: $file");

    if (file != null) {
      await Navigator.pushReplacementNamed(context, "/landing-page");
      return;
    }
    if (refId == null || user == null) {
      await Navigator.pushReplacementNamed(context, "/auth");
    } else {
      await Navigator.pushReplacement(
        context,
        PageTransition(
          child: const SourceManagementPage(),
          type: PageTransitionType.rightToLeft,
        ),
      );
    }
    return;
  }

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await check();
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: ColorPalette().gradient),
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.1,
            ),
            const Expanded(
              child: LogoSVG(),
            ),
            Expanded(
              flex: 2,
              child: Center(
                child: Image.asset(
                  "assets/images/transsplash.gif",
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
