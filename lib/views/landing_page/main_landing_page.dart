import 'package:flutter/cupertino.dart' as cup;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:seizhtv/data_containers/favorites.dart';
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
  late final PageController _controller;
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
  final List<Widget> _content = [
    const HomePage(),
    const LivePage(),
    const MoviePage(),
    const SeriesPage(),
    const FavoritesPage(),
  ];
  initPlatform() async {
    print("REFID : $refId");
    await _handler
        .getDataFrom(type: CollectionType.favorites, refId: refId!)
        .then((value) {
      if (value != null) {
        print("FETCH DATA FROM FAV: $value");
        _favVm.populate(value);
      }
    });

    await _handler
        .getDataFrom(type: CollectionType.history, refId: refId!)
        .then((value) => null);
    await _handler.savedData.then((v) {
      if (v == null) return;
      print("SAVED DATA : $v");
      _vm.populate(v);
    });
  }

  @override
  void initState() {
    _controller = PageController();
    initPlatform();
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
      backgroundColor: Colors.red,
      // body: ZTab,
      body: PageView.builder(
        controller: _controller,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (_, i) => _content[i],
      ),
      bottomNavigationBar: ZNavbar(
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
