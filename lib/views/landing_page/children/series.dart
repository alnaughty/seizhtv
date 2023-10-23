// ignore_for_file: deprecated_member_use, avoid_print, unnecessary_null_comparison

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:seizhtv/data_containers/loaded_m3u_data.dart';
import 'package:seizhtv/extensions/state.dart';
import 'package:seizhtv/globals/loader.dart';
import 'package:seizhtv/globals/palette.dart';
import 'package:seizhtv/globals/ui_additional.dart';
import 'package:seizhtv/globals/video_loader.dart';
import 'package:seizhtv/services/tv_series_api.dart';
import 'package:seizhtv/views/landing_page/children/series_children/cat_series.dart';
import 'package:seizhtv/views/landing_page/children/series_children/fav_series.dart';
import 'package:seizhtv/views/landing_page/children/series_children/his_series.dart';
import 'package:seizhtv/views/landing_page/children/series_children/series_list.dart';
import 'package:z_m3u_handler/extension.dart';
import 'package:z_m3u_handler/z_m3u_handler.dart';
import '../../../data_containers/favorites.dart';
import '../../../data_containers/history.dart';
import '../../../globals/data.dart';

class SeriesPage extends StatefulWidget {
  const SeriesPage({super.key});

  @override
  State<SeriesPage> createState() => _SeriesPageState();
}

class _SeriesPageState extends State<SeriesPage>
    with ColorPalette, UIAdditional, VideoLoader, TVSeriesAPI {
  late final ScrollController _scrollController;
  static final ZM3UHandler _handler = ZM3UHandler.instance;
  static final Favorites _fav = Favorites.instance;
  static final History _hisvm = History.instance;
  late List<ClassifiedData> _favdata = [];
  late List<ClassifiedData> _hisdata = [];
  final LoadedM3uData _vm = LoadedM3uData.instance;
  List<ClassifiedData>? displayData;
  List<ClassifiedData> seriesData = [];
  late List<ClassifiedData> favData = [];
  late List<ClassifiedData> hisData = [];
  bool showSearchField = false;
  bool update = false;
  late List<String>? categoryName = [];
  String dropdownvalue = "";
  String label = "";
  int ind = 0;
  int? searchindex;

  fetchFav() async {
    await _handler
        .getDataFrom(type: CollectionType.favorites, refId: refId!)
        .then((value) {
      if (value != null) {
        _fav.populate(value);
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

  initStream() {
    _vm.stream.listen((event) {
      displayData = List.from(event.series);

      for (final ClassifiedData item in event.series) {
        late final List<ClassifiedData> data = item.data.classify();
        seriesData.addAll(List.from(data));
      }

      categoryName = ["ALL (${seriesData == null ? "" : seriesData.length})"];
      for (final ClassifiedData cdata in displayData!) {
        final List<ClassifiedData> sdatas = cdata.data.classify();
        categoryName!.add("${cdata.name} (${sdatas.length})");
      }
      categoryName!.sort((a, b) => a.compareTo(b));
      seriesData.sort((a, b) => a.name.compareTo(b.name));
      if (mounted) setState(() {});
    });
  }

  initFavStream() {
    _fav.stream.listen((event) {
      _favdata = List.from(event.series);
      favData = _favdata.expand((element) => element.data.classify()).toList();
    });
  }

  initHisStream() {
    _hisvm.stream.listen((event) {
      _hisdata = List.from(event.series);
      hisData = _hisdata.expand((element) => element.data.classify()).toList();
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

  final GlobalKey<SeriesListPageState> _kList =
      GlobalKey<SeriesListPageState>();
  final GlobalKey<FavSeriesPageState> _favList =
      GlobalKey<FavSeriesPageState>();
  final GlobalKey<HistorySeriesPageState> _hisList =
      GlobalKey<HistorySeriesPageState>();
  final GlobalKey<SeriesCategoryPageState> _catList =
      GlobalKey<SeriesCategoryPageState>();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: card,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: appbar(3, onSearchPressed: () async {
            showSearchField = !showSearchField;
            searchindex = showSearchField == true ? ind : null;
            print("showSearchField $showSearchField - $ind");
            print("showSearchField $searchindex - $ind");
            if (mounted) setState(() {});
          }, onUpdateChannel: () {
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
          }),
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
                        height: 50,
                        child: UIAdditional().filterChip(
                            chipsLabel: [
                              "All (${displayData == null ? "0" : seriesData.length})",
                              "${"favorites".tr()} (${favData.length})",
                              "Series History (${hisData.length})",
                            ],
                            onPressed: (index, name) {
                              setState(() {
                                print("$index - $name");
                                ind = index;
                              });
                            },
                            si: ind,
                            selected: true,
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
                                  print("All");
                                  ind = 0;
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
                            )),
                      ),
                      const SizedBox(height: 15),
                      Expanded(
                        child: Scrollbar(
                            controller: _scrollController,
                            child: ind == 0
                                ? dropdownvalue.contains("All") ||
                                        dropdownvalue == ""
                                    ? SeriesListPage(
                                        key: _kList,
                                        controller: _scrollController,
                                        data: seriesData,
                                        showSearchField:
                                            searchindex == 0 ? true : false)
                                    : SeriesCategoryPage(
                                        key: _catList,
                                        category: label,
                                      )
                                : ind == 1
                                    ? FavSeriesPage(
                                        key: _favList,
                                        data: favData,
                                        showSearchField:
                                            searchindex == 1 ? true : false)
                                    : HistorySeriesPage(
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
