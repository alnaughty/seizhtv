//ignore_for_file: avoid_print, deprecated_member_use, unnecessary_null_comparison, unrelated_type_equality_checks
import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:seizhtv/extensions/color.dart';
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
  late final TextEditingController _search;
  List<M3uEntry> movieData = [];
  late List<String>? categoryName = [];
  List<ClassifiedData>? displayData;
  String dropdownvalue = "";
  String label = "";
  int? ind = 0;
  int? previousIndex;
  bool selected = true;
  bool selectedAgain = false;
  int currentIndex = 0;

  initStream() {
    _vm.stream.listen((event) {
      displayData = List.from(event.movies);
      for (final ClassifiedData item in event.movies) {
        late final List<M3uEntry> data = item.data;
        movieData.addAll(List.from(data));
      }
      categoryName = ["ALL (${movieData == null ? "" : movieData.length})"];
      for (final ClassifiedData cdata in displayData!) {
        categoryName!.add("${cdata.name} (${cdata.data.length})");
      }
      categoryName!.sort((a, b) => a.compareTo(b));
      movieData.sort((a, b) => a.title.compareTo(b.title));
      dropdownvalue = categoryName![0];
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
      favData = _favdata.expand((element) => element.data).toList()
        ..sort((a, b) => a.title.compareTo(b.title));
    });
  }

  initHisStream() {
    _hisvm.stream.listen((event) {
      _hisdata = List.from(event.movies);
      hisData = _hisdata.expand((element) => element.data).toList()
        ..sort((a, b) => a.title.compareTo(b.title));
    });
  }

  @override
  void initState() {
    _scrollController = ScrollController();
    _search = TextEditingController();
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
  final GlobalKey<FaveMoviePageState> _favPage =
      GlobalKey<FaveMoviePageState>();
  final GlobalKey<HistoryMoviePageState> _hisPage =
      GlobalKey<HistoryMoviePageState>();
  final GlobalKey<MovieCategoryPageState> _catPage =
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
              print("showSearchField $showSearchField - $ind");
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
                              // "All (${displayData == null ? "" : displayData!.length})",
                              "${"favorites".tr()} (${favData.length})",
                              "${"Channels_History".tr()} (${hisData.length})",
                            ],
                            onPressed: (index, name) {
                              setState(() {
                                ind = index + 1;
                                selected = false;
                                selectedAgain = false;
                                currentIndex = ind!;
                              });
                            },
                            si: ind,
                            selected: selected,
                            filterButton: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selected = true;
                                  ind = 0;
                                  currentIndex = ind!;
                                  print("presssss $currentIndex");
                                });
                              },
                              child: currentIndex != 0
                                  ? Container(
                                      width: 170,
                                      height: 45,
                                      alignment: Alignment.centerLeft,
                                      padding: const EdgeInsets.only(left: 10),
                                      child: Expanded(
                                        child: Text(
                                          dropdownvalue,
                                          style: const TextStyle(
                                              // fontSize: 14,
                                              fontFamily: "Poppins"),
                                        ),
                                      ),
                                    )
                                  : Container(
                                      width: 170,
                                      height: 45,
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
                                              value: value, child: Text(value));
                                        }).toList(),
                                        value: dropdownvalue == ""
                                            ? categoryName == []
                                                ? ""
                                                : categoryName![0]
                                            : dropdownvalue,
                                        style: const TextStyle(
                                            // fontSize: 14,
                                            fontFamily: "Poppins"),
                                        onChanged: (value) {
                                          setState(() {
                                            dropdownvalue = value!;
                                            String result1 =
                                                dropdownvalue.replaceAll(
                                                    RegExp(r"[(]+[0-9]+[)]"),
                                                    '');
                                            label = result1;
                                            print("DROPDOWNNNN $label");
                                          });
                                        },
                                      ),
                                    ),
                            )),
                      ),
                      const SizedBox(height: 15),
                      AnimatedPadding(
                        duration: const Duration(milliseconds: 400),
                        padding: EdgeInsets.symmetric(
                            horizontal: showSearchField ? 20 : 0),
                        child: AnimatedContainer(
                          duration: const Duration(
                            milliseconds: 500,
                          ),
                          height: showSearchField ? 50 : 0,
                          width: double.maxFinite,
                          child: Row(
                            children: [
                              Expanded(
                                  child: Container(
                                height: 50,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                    color: highlight,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            highlight.darken().withOpacity(1),
                                        offset: const Offset(2, 2),
                                        blurRadius: 2,
                                      )
                                    ]),
                                child: Row(
                                  children: [
                                    SvgPicture.asset(
                                      "assets/icons/search.svg",
                                      height: 20,
                                      width: 20,
                                      color: white,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: AnimatedSwitcher(
                                        duration:
                                            const Duration(milliseconds: 300),
                                        child: showSearchField
                                            ? TextField(
                                                onChanged: (text) {
                                                  if (_kList.currentState !=
                                                      null) {
                                                    _kList.currentState!
                                                        .search(text);
                                                  } else if (_catPage
                                                          .currentState !=
                                                      null) {
                                                    _catPage.currentState!
                                                        .search(text);
                                                  } else if (_favPage
                                                          .currentState !=
                                                      null) {
                                                    _favPage.currentState!
                                                        .search(text);
                                                  } else if (_hisPage
                                                          .currentState !=
                                                      null) {
                                                    _hisPage.currentState!
                                                        .search(text);
                                                  }
                                                  if (mounted) setState(() {});
                                                },
                                                cursorColor: orange,
                                                controller: _search,
                                                decoration: InputDecoration(
                                                  hintText: "Search".tr(),
                                                ),
                                              )
                                            : Container(),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _kList.currentState?.search("");
                                    _catPage.currentState?.search("");
                                    _favPage.currentState?.search("");
                                    _hisPage.currentState?.search("");
                                    _search.text = "";
                                    showSearchField = !showSearchField;
                                  });
                                },
                                child: Text(
                                  "Cancel".tr(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (showSearchField) ...{
                        const SizedBox(height: 20),
                      },
                      Expanded(
                        child: Scrollbar(
                          controller: _scrollController,
                          child: ind == 0
                              ? dropdownvalue.contains("ALL") ||
                                      dropdownvalue == ""
                                  ? MovieListPage(
                                      key: _kList,
                                      controller: _scrollController,
                                      data: movieData,
                                      showSearchField: showSearchField,
                                    )
                                  : MovieCategoryPage(
                                      key: _catPage,
                                      category: label,
                                    )
                              : ind == 1
                                  ? FaveMoviePage(
                                      key: _favPage,
                                      data: favData,
                                    )
                                  : HistoryMoviePage(
                                      key: _hisPage,
                                      data: hisData,
                                    ),
                        ),
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
