import 'dart:io';

import 'package:flutter/cupertino.dart' as cup;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:seizhtv/data_containers/favorites.dart';
import 'package:seizhtv/data_containers/history.dart';
import 'package:seizhtv/data_containers/loaded_m3u_data.dart';
import 'package:seizhtv/globals/data.dart';
import 'package:seizhtv/globals/data_cacher.dart';
import 'package:seizhtv/globals/palette.dart';
import 'package:seizhtv/views/landing_page/children/favorites.dart';
import 'package:seizhtv/views/landing_page/children/home.dart';
import 'package:seizhtv/views/landing_page/children/live.dart';
import 'package:seizhtv/views/landing_page/children/movie.dart';
import 'package:seizhtv/views/landing_page/children/series.dart';
import 'package:z_m3u_handler/z_m3u_handler.dart';
import 'package:znavbar/znavbar.dart';

class MainLandingPage extends StatefulWidget {
  const MainLandingPage({super.key});

  @override
  State<MainLandingPage> createState() => _MainLandingPageState();
}

class _MainLandingPageState extends State<MainLandingPage> with ColorPalette {
  final DataCacher _cacher = DataCacher.instance;
  final ZM3UHandler _handler = ZM3UHandler.instance;
  final LoadedM3uData _vm = LoadedM3uData.instance;
  final Favorites _favVm = Favorites.instance;
  final History _hisVm = History.instance;
  late final PageController _controller;
  final GlobalKey<ZNavbarState> _kNavState = GlobalKey<ZNavbarState>();
  final List<ZTab> _tabs = [
    ZTabImage(
      text: "Home",
      path: "assets/icons/home.svg",
      imgType: ZImageType.svgAsset,
    ),
    ZTabIcon(
      text: "Live",
      icon: const Icon(
        cup.CupertinoIcons.tv,
      ),
    ),
    ZTabImage(
      text: "Movies",
      path: "assets/icons/movies.svg",
      imgType: ZImageType.svgAsset,
    ),
    ZTabIcon(
      text: "Series",
      icon: const Icon(
        cup.CupertinoIcons.film,
      ),
    ),
    ZTabImage(
      text: "Favorites",
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
  Future<void> initPlatform() async {
    String? file = _cacher.filePath;
    refId = _cacher.refId;
    if (mounted) setState(() {});
    if (file == null) {
      await Navigator.pushReplacementNamed(context, "/auth");
      await _cacher.clearData();
      return;
    }
    await _handler.getData(File(file)).then((value) async {
      if (value == null) {
        await Navigator.pushReplacementNamed(context, "/auth");
        await _cacher.clearData();
      } else {
        _vm.populate(value);
      }
    });
    _handler
        .getDataFrom(type: CollectionType.favorites, refId: refId!)
        .then((value) {
      if (value != null) {
        print("FETCH DATA FROM FAV: $value");
        _favVm.populate(value);
      }
    });
    _handler
        .getDataFrom(type: CollectionType.history, refId: refId!)
        .then((value) {
      if (value != null) {
        print("FETCH DATA FROM HISTORY: $value");
        _hisVm.populate(value);
      }
    });
  }

  @override
  void initState() {
    _controller = PageController();
    refId = _cacher.refId;
    print("REF ID : $refId");
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await initPlatform();
    });
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    // TODO: implement dispose
    super.dispose();
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
