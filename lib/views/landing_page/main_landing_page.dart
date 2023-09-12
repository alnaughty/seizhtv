import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart' as cup;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:seizhtv/data_containers/loaded_m3u_data.dart';
import 'package:seizhtv/globals/data.dart';
import 'package:seizhtv/globals/data_cacher.dart';
import 'package:seizhtv/globals/palette.dart';
import 'package:seizhtv/views/landing_page/firestore_listener.dart';
import 'package:seizhtv/views/landing_page/children/favorites.dart';
import 'package:seizhtv/views/landing_page/children/home.dart';
import 'package:seizhtv/views/landing_page/children/live.dart';
import 'package:seizhtv/views/landing_page/children/series.dart';
import 'package:seizhtv/views/landing_page/movie.dart';
import 'package:z_m3u_handler/z_m3u_handler.dart';
import 'package:znavbar/znavbar.dart';
import '../../services/tv_series_api.dart';
import '../../services/movie_api.dart';

class MainLandingPage extends StatefulWidget {
  const MainLandingPage({super.key});

  @override
  State<MainLandingPage> createState() => _MainLandingPageState();
}

class _MainLandingPageState extends State<MainLandingPage>
    with ColorPalette, TVSeriesAPI, MovieAPI {
  final DataCacher _cacher = DataCacher.instance;
  final ZM3UHandler _handler = ZM3UHandler.instance;
  final LoadedM3uData _vm = LoadedM3uData.instance;
  final FirestoreListener _firestoreListener = FirestoreListener.instance;

  late final PageController _controller;
  final GlobalKey<ZNavbarState> _kNavState = GlobalKey<ZNavbarState>();
  final List<ZTab> _tabs = [
    ZTabImage(
      text: "Home".tr(),
      path: "assets/icons/home.svg",
      imgType: ZImageType.svgAsset,
    ),
    ZTabIcon(
      text: "Live_Tv".tr(),
      icon: const Icon(
        cup.CupertinoIcons.tv,
      ),
    ),
    ZTabImage(
      text: "Movies".tr(),
      path: "assets/icons/movies.svg",
      imgType: ZImageType.svgAsset,
    ),
    ZTabIcon(
      text: "Series".tr(),
      icon: const Icon(
        cup.CupertinoIcons.film,
      ),
    ),
    ZTabImage(
      text: "favorites".tr(),
      path: "assets/icons/favourites.svg",
      imgType: ZImageType.svgAsset,
    ),
  ];
  late final List<Widget> _content = [
    HomePage(
      onPagePressed: (int page) async {
        _kNavState.currentState!.updateIndex(page);
        await _controller.animateToPage(
          page,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      },
    ),
    const LivePage(),
    const MoviePage(),
    const SeriesPage(),
    const FavoritesPage(),
  ];
  // const Movie1Page(),

  Future<void> initPlatform() async {
    print("RFID IN INIT PLATFORM LANDING PAGE: $refId");
    String? file = _cacher.filePath;
    refId = _cacher.refId;
    if (mounted) setState(() {});
    if (file == null) {
      await Navigator.pushReplacementNamed(context, "/auth");
      await _cacher.clearData();
      return;
    }
    try {
      final CategorizedM3UData? value = await runExpensiveOperation(File(file));

      if (value == null) {
        // ignore: use_build_context_synchronously
        await Navigator.pushReplacementNamed(context, "/auth");
        await _cacher.clearData();
      } else {
        _vm.populate(value);
      }
    } catch (e) {
      // handle error
      await Navigator.pushReplacementNamed(context, "/auth");
      await _cacher.clearData();
      return;
    }
  }

  Future<CategorizedM3UData?> runExpensiveOperation(File file) async {
    return await compute(_handler.getData, file);
  }

  @override
  void initState() {
    init();
    _controller = PageController();
    refId = _cacher.refId;
    print("RFID IN INIT STATE LANDING PAGE: $refId");
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await initPlatform();
    });
    _firestoreListener.listen();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  init() async {
    await topRatedMovie();
    await topRatedTVShow();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    return Scaffold(
      backgroundColor: card,
      // body: ZTab,
      body: PageView.builder(
        controller: _controller,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (_, i) => _content[i],
      ),
      bottomNavigationBar: ZNavbar(
        key: _kNavState,
        indicatorColor: orange,
        backgroundColor: highlight,
        activeColor: white,
        indicatorSize: 3,
        indexCallback: (int i) {
          _controller.animateToPage(
            i,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        },
        inactiveColor: white.withOpacity(0.5),
        tabs: _tabs,
      ),
    );
  }
}
