// ignore_for_file: deprecated_member_use, avoid_print, unnecessary_null_comparison

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:seizhtv/data_containers/loaded_m3u_data.dart';
import 'package:seizhtv/extensions/color.dart';
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
  late final TextEditingController _search;
  late List<ClassifiedData> _favdata = [];
  late List<ClassifiedData> _hisdata = [];
  final LoadedM3uData _vm = LoadedM3uData.instance;
  List<ClassifiedData>? displayData;
  List<ClassifiedData> seriesData = [];
  late List<ClassifiedData> favData = [];
  late List<ClassifiedData> hisData = [];
  late List<ClassifiedData> data = [];
  late List<ClassifiedData> categorydata = [];
  bool showSearchField = false;
  bool update = false;
  late List<String>? categoryName = [];
  bool categorysearch = false;
  String dropdownvalue = "";
  String label = "";
  int ind = 0;
  bool selected = true;
  int prevIndex = 1;

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
      for (final String label in categoryName!) {
        if (label
            .contains("ALL (${seriesData == null ? "" : seriesData.length})")) {
          dropdownvalue = label;
        }
      }
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

  final GlobalKey<SeriesListPageState> _kList =
      GlobalKey<SeriesListPageState>();
  final GlobalKey<FavSeriesPageState> _favPage =
      GlobalKey<FavSeriesPageState>();
  final GlobalKey<HistorySeriesPageState> _hisPage =
      GlobalKey<HistorySeriesPageState>();
  final GlobalKey<SeriesCategoryPageState> _catPage =
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
            if (showSearchField == true) {
              if (ind == 0) {
                if (dropdownvalue.contains("ALL") || dropdownvalue == "") {
                  categorysearch = false;
                } else {
                  categorysearch = true;
                }
              } else {
                categorysearch = false;
              }
            }
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
                        height: 50,
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: ListView(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  prevIndex = ind;
                                  ind = 0;
                                  showSearchField = false;
                                  print("CURRENT INDEX $ind");
                                  print("PREV INDEX $prevIndex");
                                });
                              },
                              child: Container(
                                width: 170,
                                height: 50,
                                // padding: const EdgeInsets.all(5),
                                alignment: Alignment.centerLeft,
                                decoration: BoxDecoration(
                                    color: ind == 0
                                        ? ColorPalette().topColor
                                        : ColorPalette().highlight,
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                        color: ind == 0
                                            ? ColorPalette().topColor
                                            : Colors.grey)),
                                child: ind == 0 && prevIndex != 0
                                    ? DropdownButton(
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
                                                : categoryName![3]
                                            : dropdownvalue,
                                        style: const TextStyle(
                                            fontFamily: "Poppins"),
                                        onChanged: (value) {
                                          setState(
                                            () {
                                              dropdownvalue = value!;
                                              String result1 =
                                                  dropdownvalue.replaceAll(
                                                      RegExp(r"[(]+[0-9]+[)]"),
                                                      '');

                                              data = displayData!
                                                  .where((element) =>
                                                      element.name.contains(
                                                          result1.trimRight()))
                                                  .expand((element) =>
                                                      element.data.classify())
                                                  .toList()
                                                ..sort((a, b) =>
                                                    a.name.compareTo(b.name));
                                              categorydata = data;
                                              showSearchField = false;
                                              categorysearch = false;
                                            },
                                          );
                                        },
                                      )
                                    : Text(
                                        dropdownvalue,
                                        style: const TextStyle(
                                            fontFamily: "Poppins"),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  prevIndex = ind;
                                  ind = 1;
                                  showSearchField = false;
                                });
                              },
                              child: Container(
                                height: 50,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 5),
                                alignment: Alignment.centerLeft,
                                decoration: BoxDecoration(
                                  color: ind == 1
                                      ? ColorPalette().topColor
                                      : ColorPalette().highlight,
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                    color: ind == 1
                                        ? ColorPalette().topColor
                                        : Colors.grey,
                                  ),
                                ),
                                child: Text(
                                  "${"favorites".tr().toUpperCase()} (${favData.length})",
                                  style: const TextStyle(fontFamily: "Poppins"),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  prevIndex = ind;
                                  ind = 2;
                                  showSearchField = false;
                                });
                              },
                              child: Container(
                                height: 50,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 5),
                                alignment: Alignment.centerLeft,
                                decoration: BoxDecoration(
                                    color: ind == 2
                                        ? ColorPalette().topColor
                                        : ColorPalette().highlight,
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                        color: ind == 2
                                            ? ColorPalette().topColor
                                            : Colors.grey)),
                                child: Text(
                                  "${"Series History".toUpperCase()} (${hisData.length})",
                                  style: const TextStyle(fontFamily: "Poppins"),
                                ),
                              ),
                            ),
                            // GestureDetector(
                            //   onTap: () {
                            //     setState(() {
                            //       prevIndex = ind;
                            //       ind = 0;
                            //       showSearchField = false;
                            //       print("CURRENT INDEX $ind");
                            //       print("PREV INDEX $prevIndex");
                            //     });
                            //   },
                            //   child: ind == 0 && prevIndex != 0
                            //       ? ChoiceChip(
                            //           showCheckmark: false,
                            //           padding: const EdgeInsets.symmetric(
                            //               horizontal: 10),
                            //           label: Container(
                            //             width: 170,
                            //             height: 45,
                            //             decoration: BoxDecoration(
                            //               borderRadius:
                            //                   BorderRadius.circular(30),
                            //             ),
                            //             child: DropdownButton(
                            //               elevation: 0,
                            //               isExpanded: true,
                            //               padding: const EdgeInsets.all(0),
                            //               underline: Container(),
                            //               onTap: () {
                            //                 setState(() {
                            //                   selected = true;
                            //                   ind = 0;
                            //                 });
                            //               },
                            //               items: categoryName!.map((value) {
                            //                 return DropdownMenuItem(
                            //                     value: value,
                            //                     child: Text(value));
                            //               }).toList(),
                            //               value: dropdownvalue == ""
                            //                   ? categoryName == []
                            //                       ? ""
                            //                       : categoryName![3]
                            //                   : dropdownvalue,
                            //               style: const TextStyle(
                            //                   fontFamily: "Poppins"),
                            //               onChanged: (value) {
                            //                 setState(
                            //                   () {
                            //                     dropdownvalue = value!;
                            //                     String result1 =
                            //                         dropdownvalue.replaceAll(
                            //                             RegExp(
                            //                                 r"[(]+[0-9]+[)]"),
                            //                             '');

                            // data = displayData!
                            //     .where((element) => element
                            //         .name
                            //         .contains(result1
                            //             .trimRight()))
                            //     .expand((element) =>
                            //         element.data.classify())
                            //     .toList()
                            //   ..sort((a, b) =>
                            //       a.name.compareTo(b.name));
                            // categorydata = data;
                            //                     showSearchField = false;
                            //                     categorysearch = false;
                            //                     print(
                            //                         "DATA IN CATEGORY: ${data.length}");
                            //                   },
                            //                 );
                            //               },
                            //             ),
                            //           ),
                            //           selected: ind == 0 ? true : false,
                            //           selectedColor: ColorPalette().topColor,
                            //           disabledColor: ColorPalette().highlight,
                            //         )
                            //       : ChoiceChip(
                            //           showCheckmark: false,
                            //           padding: const EdgeInsets.symmetric(
                            //               horizontal: 10),
                            //           label: SizedBox(
                            //             height: 45,
                            //             child: Center(
                            //               child: Text(
                            //                 dropdownvalue,
                            //                 style: const TextStyle(
                            //                     fontFamily: "Poppins"),
                            //               ),
                            //             ),
                            //           ),
                            //           selected: ind == 0 ? true : false,
                            //           selectedColor: ColorPalette().topColor,
                            //           disabledColor: ColorPalette().highlight,
                            //         ),
                            // ),
                            // const SizedBox(width: 10),
                            // GestureDetector(
                            //   onTap: () {
                            //     setState(() {
                            //       prevIndex = ind;
                            //       ind = 1;
                            //       showSearchField = false;
                            //       categorysearch = false;
                            //     });
                            //   },
                            //   child: ChoiceChip(
                            //     showCheckmark: false,
                            //     padding:
                            //         const EdgeInsets.symmetric(horizontal: 10),
                            //     label: SizedBox(
                            //       height: 45,
                            //       child: Center(
                            //         child: Text(
                            //           "${"favorites".tr()} (${favData.length})",
                            //           style:
                            //               const TextStyle(color: Colors.white),
                            //         ),
                            //       ),
                            //     ),
                            //     selected: ind == 1 ? true : false,
                            //     selectedColor: ColorPalette().topColor,
                            //     disabledColor: ColorPalette().highlight,
                            //   ),
                            // ),
                            // const SizedBox(width: 10),
                            // GestureDetector(
                            //   onTap: () {
                            //     setState(() {
                            //       prevIndex = ind;
                            //       ind = 2;
                            //       showSearchField = false;
                            //       categorysearch = false;
                            //     });
                            //   },
                            //   child: ChoiceChip(
                            //     showCheckmark: false,
                            //     padding:
                            //         const EdgeInsets.symmetric(horizontal: 10),
                            //     label: SizedBox(
                            //       height: 45,
                            //       child: Center(
                            //         child: Text(
                            //           "${"Series History"} (${hisData.length})",
                            //           style:
                            //               const TextStyle(color: Colors.white),
                            //         ),
                            //       ),
                            //     ),
                            //     selected: ind == 2 ? true : false,
                            //     selectedColor: ColorPalette().topColor,
                            //     disabledColor: ColorPalette().highlight,
                            //   ),
                            // ),
                            const SizedBox(width: 10),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      categorysearch == false
                          ? AnimatedPadding(
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
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      decoration: BoxDecoration(
                                          color: highlight,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          boxShadow: [
                                            BoxShadow(
                                              color: highlight
                                                  .darken()
                                                  .withOpacity(1),
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
                                              duration: const Duration(
                                                  milliseconds: 300),
                                              child: showSearchField
                                                  ? TextField(
                                                      onChanged: (text) {
                                                        if (_kList
                                                                .currentState !=
                                                            null) {
                                                          _kList.currentState!
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
                                                        if (mounted) {
                                                          setState(() {});
                                                        }
                                                      },
                                                      cursorColor: orange,
                                                      controller: _search,
                                                      decoration:
                                                          InputDecoration(
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
                                          _favPage.currentState?.search("");
                                          _hisPage.currentState?.search("");
                                          _search.text = "";
                                          showSearchField = !showSearchField;
                                        });
                                      },
                                      child: Text(
                                        "Cancel".tr(),
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : const SizedBox(),
                      if (showSearchField) ...{
                        const SizedBox(height: 20),
                      },
                      Expanded(
                        child: Scrollbar(
                            controller: _scrollController,
                            child: ind == 0
                                ? dropdownvalue.contains("ALL") ||
                                        dropdownvalue == ""
                                    ? SeriesListPage(
                                        key: _kList,
                                        controller: _scrollController,
                                        data: seriesData,
                                        showSearchField: showSearchField,
                                      )
                                    : SeriesCategoryPage(
                                        key: _catPage,
                                        categorydata: categorydata,
                                        showsearchfield: categorysearch,
                                      )
                                : ind == 1
                                    ? FavSeriesPage(
                                        key: _favPage,
                                        data: favData,
                                      )
                                    : HistorySeriesPage(
                                        key: _hisPage,
                                        data: hisData,
                                      )),
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
