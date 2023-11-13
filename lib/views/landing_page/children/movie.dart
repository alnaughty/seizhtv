//ignore_for_file: avoid_print, deprecated_member_use, unnecessary_null_comparison, unrelated_type_equality_checks
import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:seizhtv/extensions/state.dart';
import 'package:z_m3u_handler/z_m3u_handler.dart';
import '../../../data_containers/favorites.dart';
import '../../../data_containers/history.dart';
import '../../../data_containers/loaded_m3u_data.dart';
import '../../../globals/data.dart';
import '../../../globals/loader.dart';
import '../../../globals/palette.dart';
import '../../../globals/ui_additional.dart';
import '../../../globals/video_loader.dart';
import '../../../services/movie_api.dart';
import 'movie_children/cat_movie.dart';
import 'movie_children/fav_movie.dart';
import 'movie_children/his_movie.dart';
import 'movie_children/movie_list.dart';

class MoviePage extends StatefulWidget {
  const MoviePage({super.key});

  @override
  State<MoviePage> createState() => _MoviePageState();
}

class _MoviePageState extends State<MoviePage>
    with ColorPalette, UIAdditional, VideoLoader, MovieAPI {
  static final ZM3UHandler _handler = ZM3UHandler.instance;
  final LoadedM3uData _vm = LoadedM3uData.instance;
  late final ScrollController _scrollController;
  final Favorites _vm1 = Favorites.instance;
  final History _hisvm = History.instance;
  late List<ClassifiedData> _favdata;
  late List<ClassifiedData> _hisdata;
  late List<M3uEntry> favData = [];
  late List<M3uEntry> hisData = [];
  bool showSearchField = false;
  bool update = false;
  int? searchindex;
  List<M3uEntry> movieData = [];
  late List<String>? categoryName = [];
  List<ClassifiedData>? displayData;
  String dropdownvalue = "";
  String label = "";
  int? ind;
  int? previousIndex;
  bool selected = true;
  bool selectedAgain = false;

  initStream() {
    _vm.stream.listen((event) {
      displayData = List.from(event.movies);
      for (final ClassifiedData item in event.movies) {
        late final List<M3uEntry> data = item.data;
        movieData.addAll(List.from(data));
      }

      categoryName = ["All (${movieData == null ? "" : movieData.length})"];
      for (final ClassifiedData cdata in displayData!) {
        categoryName!.add("${cdata.name} (${cdata.data.length})");
      }
      categoryName!.sort((a, b) => a.compareTo(b));
      movieData.sort((a, b) => a.title.compareTo(b.title));
      if (mounted) setState(() {});
    });
  }

  fetchFav() async {
    await _handler
        .getDataFrom(type: CollectionType.favorites, refId: refId!)
        .then((value) {
      if (value != null) {
        _vm1.populate(value);
      }
    });
  }

  fetchHis() async {
    await _handler
        .getDataFrom(type: CollectionType.history, refId: refId!)
        .then((value) {
      if (value != null) {
        _hisvm.populate(value);
      }
    });
  }

  initFavStream() {
    _vm1.stream.listen((event) {
      _favdata = List.from(event.movies);
      favData = _favdata.expand((element) => element.data).toList();
    });
  }

  initHisStream() {
    _hisvm.stream.listen((event) {
      _hisdata = List.from(event.movies);
      hisData = _hisdata.expand((element) => element.data).toList();
    });
  }

  @override
  void initState() {
    _scrollController = ScrollController();
    fetchFav();
    fetchHis();
    initFavStream();
    initHisStream();
    initStream();
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    favData = [];
    hisData = [];
    super.dispose();
  }

  final GlobalKey<MovieListPageState> _kList = GlobalKey<MovieListPageState>();
  final GlobalKey<FaveMoviePageState> _favList =
      GlobalKey<FaveMoviePageState>();
  final GlobalKey<HistoryMoviePageState> _hisList =
      GlobalKey<HistoryMoviePageState>();
  final GlobalKey<MovieCategoryPageState> _catList =
      GlobalKey<MovieCategoryPageState>();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: card,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: appbar(
            2,
            onSearchPressed: () async {
              showSearchField = !showSearchField;
              searchindex = showSearchField == true ? ind : null;
              print("showSearchField $showSearchField - $ind");
              print("SEARCH INDEX $searchindex - $ind");
              if (mounted) setState(() {});
            },
            onUpdateChannel: () {
              setState(() {
                update = true;
                Future.delayed(
                  const Duration(seconds: 6),
                  () {
                    setState(() {
                      update = false;
                    });
                  },
                );
              });
            },
          ),
        ),
        body: Stack(
          children: [
            displayData == null
                ? SeizhTvLoader(
                    label: Text(
                      "Retrieving_data".tr(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  )
                : Column(
                    children: [
                      Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: UIAdditional().filterChip(
                              chipsLabel: [
                                // "All (${displayData == null ? "0" : seriesData.length})",
                                "${"favorites".tr()} (${favData.length})",
                                "Series History (${hisData.length})",
                              ],
                              onPressed: (index, name) {
                                setState(() {
                                  ind = index + 1;
                                  selected = false;
                                  selectedAgain = false;
                                  print("INDEXXXXX $ind");
                                  print("DROPDOWNNNN $dropdownvalue");
                                });
                              },
                              si: ind,
                              selected: selected,
                              filterButton: Container(
                                width: 150,
                                height: 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: DropdownButton(
                                  elevation: 0,
                                  isExpanded: true,
                                  padding: const EdgeInsets.all(0),
                                  underline: Container(),
                                  onTap: () {
                                    setState(() {
                                      selected = true;
                                      ind = 0;
                                    });
                                  },
                                  items: categoryName!.map((value) {
                                    return DropdownMenuItem(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  value: dropdownvalue == ""
                                      ? categoryName == []
                                          ? ""
                                          : categoryName![0]
                                      : dropdownvalue,
                                  style: const TextStyle(
                                      fontSize: 14, fontFamily: "Poppins"),
                                  onChanged: (value) {
                                    setState(() {
                                      dropdownvalue = value!;
                                      String result1 = dropdownvalue.replaceAll(
                                          RegExp(r"[(]+[0-9]+[)]"), '');
                                      label = result1;
                                    });
                                  },
                                ),
                              ))),
                      const SizedBox(height: 10),
                      Expanded(
                        child: Scrollbar(
                            controller: _scrollController,
                            child: ind == 0
                                ? dropdownvalue.contains("All") ||
                                        dropdownvalue == ""
                                    ? MovieListPage(
                                        key: _kList,
                                        controller: _scrollController,
                                        data: movieData,
                                        showSearchField:
                                            searchindex == 0 ? true : false)
                                    : MovieCategoryPage(
                                        key: _catList,
                                        category: label,
                                        showSearchField:
                                            searchindex == 0 ? true : false)
                                : ind == 1
                                    ? FaveMoviePage(
                                        key: _favList,
                                        data: favData,
                                        showSearchField:
                                            searchindex == 1 ? true : false)
                                    : HistoryMoviePage(
                                        key: _hisList,
                                        data: hisData,
                                        showSearchField:
                                            searchindex == 2 ? true : false)),
                      ),
                    ],
                  ),
            update == true ? loader() : Container()
          ],
        ),
      ),
    );
  }
}
