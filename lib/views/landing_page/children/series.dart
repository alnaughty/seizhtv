// ignore_for_file: deprecated_member_use, avoid_print

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:page_transition/page_transition.dart';
import 'package:seizhtv/data_containers/loaded_m3u_data.dart';
import 'package:seizhtv/extensions/color.dart';
import 'package:seizhtv/extensions/state.dart';
import 'package:seizhtv/globals/loader.dart';
import 'package:seizhtv/globals/palette.dart';
import 'package:seizhtv/globals/ui_additional.dart';
import 'package:seizhtv/globals/video_loader.dart';
import 'package:seizhtv/services/tv_series_api.dart';
import 'package:seizhtv/views/landing_page/children/series_children/details.dart';
import 'package:seizhtv/views/landing_page/children/series_children/fav_series.dart';
import 'package:seizhtv/views/landing_page/children/series_children/his_series.dart';
import 'package:seizhtv/views/landing_page/children/series_children/series_list.dart';
import 'package:z_m3u_handler/extension.dart';
import 'package:z_m3u_handler/z_m3u_handler.dart';
import '../../../data_containers/favorites.dart';
import '../../../data_containers/history.dart';
import '../../../globals/data.dart';
import '../../../globals/favorite_button.dart';
import '../../../globals/network_image_viewer.dart';

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
  late final TextEditingController _search;
  late List<ClassifiedData> _data;
  List<ClassifiedData>? displayData;
  List<ClassifiedData> searchData = [];
  List<ClassifiedData> seriesData = [];
  late List<ClassifiedData> favData = [];
  late List<ClassifiedData> hisData = [];
  bool showSearchField = false;
  bool update = false;
  late List<String>? categoryName = [];
  String dropdownvalue = "";
  String label = "";
  int ind = 0;

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
      _data = List.from(event.series);
      categoryName = List.from(_data.map((e) => e.name))
        ..sort((a, b) => a.compareTo(b));
      _data.sort((a, b) => a.name.compareTo(b.name));
      displayData = List.from(_data);

      for (final ClassifiedData item in _data) {
        late final List<ClassifiedData> data = item.data.classify()
          ..sort((a, b) => a.name.compareTo(b.name));
        seriesData.addAll(List.from(data));
      }
      searchData = seriesData;
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
    _search.dispose();
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
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  height: 50,
                  child: UIAdditional().filterChip(
                    chipsLabel: [
                      "All (${displayData == null ? "0" : seriesData.length})",
                      "${"favorites".tr()} (${favData.length})",
                      // "Categories",
                      // for (int i = 0; i < categoryName!.length; i++) ...{
                      //   (categoryName![i])
                      // },
                      "Series History (${hisData.length})",
                    ],
                    onPressed: (index, name) {
                      setState(() {
                        print("$index");
                        ind = index;
                        label = name!;
                      });
                    },
                    categoryName: [],
                    si: ind,
                    filterButton: (name) {
                      print("FILTER BUTTON $ind");
                      setState(() {
                        if (name!.contains("All")) {
                          DropdownButton(
                            elevation: 0,
                            isExpanded: true,
                            items: categoryName!.map((value) {
                              return DropdownMenuItem(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            value: dropdownvalue == ""
                                ? categoryName![0]
                                : dropdownvalue,
                            style: const TextStyle(
                                fontSize: 14, fontFamily: "Poppins"),
                            icon: const Icon(Icons.keyboard_arrow_down),
                            onChanged: (value) {
                              setState(() {
                                dropdownvalue = value!;
                              });
                            },
                          );
                        }
                      });
                    },
                  ),
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
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                              color: highlight,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: highlight.darken().withOpacity(1),
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
                                  duration: const Duration(milliseconds: 300),
                                  child: showSearchField
                                      ? TextField(
                                          onChanged: (text) {
                                            if (text.isEmpty) {
                                              searchData = seriesData;
                                            } else {
                                              searchData = List.from(seriesData
                                                  .where((element) => element
                                                      .name
                                                      .toLowerCase()
                                                      .contains(
                                                          text.toLowerCase())));
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
                              _search.clear();
                              searchData = seriesData;
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
                  const SizedBox(height: 15),
                },
                Expanded(
                  child: displayData == null
                      ? SeizhTvLoader(
                          label: Text(
                            "Retrieving_data".tr(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        )
                      : Scrollbar(
                          controller: _scrollController,
                          child: ind == 0
                              ? showSearchField
                                  ? searchData.isEmpty
                                      ? Center(
                                          child: Text(
                                            "No Result Found for `${_search.text}`",
                                            style: TextStyle(
                                              color:
                                                  Colors.white.withOpacity(.5),
                                            ),
                                          ),
                                        )
                                      : GridView.builder(
                                          shrinkWrap: true,
                                          controller: _scrollController,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20),
                                          gridDelegate:
                                              const SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 3,
                                                  childAspectRatio: .8,
                                                  crossAxisSpacing: 10),
                                          itemCount: searchData.length,
                                          itemBuilder: (context, i) {
                                            bool isFavorite = false;
                                            for (final ClassifiedData fav
                                                in favData) {
                                              if (searchData[i].name ==
                                                  fav.name) {
                                                if (fav.data.length ==
                                                    searchData[i].data.length) {
                                                  isFavorite = true;
                                                }
                                              }
                                            }

                                            return GestureDetector(
                                              onTap: () async {
                                                print(
                                                    "TITLE: ${searchData[i]}");
                                                String result1 = searchData[i]
                                                    .name
                                                    .replaceAll(
                                                        RegExp(
                                                            r"[(]+[a-zA-Z]+[)]|[0-9]|[|]\s+[0-9]+\s[|]"),
                                                        '');
                                                String result2 = result1.replaceAll(
                                                    RegExp(
                                                        r"[|]+[a-zA-Z]+[|]|[a-zA-Z]+[|] "),
                                                    '');

                                                Navigator.push(
                                                  context,
                                                  PageTransition(
                                                    child: SeriesDetailsPage(
                                                      data: searchData[i],
                                                      title: result2,
                                                    ),
                                                    type: PageTransitionType
                                                        .rightToLeft,
                                                  ),
                                                );
                                              },
                                              child: Stack(
                                                children: [
                                                  Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                            top: 10, right: 10),
                                                    child: LayoutBuilder(
                                                      builder: (context, c) {
                                                        final double w =
                                                            c.maxWidth;
                                                        return Tooltip(
                                                          message: searchData[i]
                                                              .name,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5),
                                                                child:
                                                                    NetworkImageViewer(
                                                                  url: searchData[
                                                                              i]
                                                                          .data[0]
                                                                          .attributes[
                                                                      'tvg-logo'],
                                                                  width: w,
                                                                  height: 53,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  color:
                                                                      highlight,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  height: 2),
                                                              Tooltip(
                                                                message:
                                                                    searchData[
                                                                            i]
                                                                        .name,
                                                                child: Text(
                                                                  searchData[i]
                                                                      .name,
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          12),
                                                                  maxLines: 2,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                              ),
                                                              Row(
                                                                children: [
                                                                  Text(
                                                                      "${searchData[i].data.length} ",
                                                                      style: const TextStyle(
                                                                          fontSize:
                                                                              12,
                                                                          color:
                                                                              Colors.grey)),
                                                                  Text(
                                                                      "Episodes"
                                                                          .tr(),
                                                                      style: const TextStyle(
                                                                          fontSize:
                                                                              12,
                                                                          color:
                                                                              Colors.grey)),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                  Positioned(
                                                    top: 0,
                                                    right: 0,
                                                    child: SizedBox(
                                                      height: 25,
                                                      width: 25,
                                                      child: FavoriteIconButton(
                                                        onPressedCallback: (bool
                                                            isFavorite) async {
                                                          if (isFavorite) {
                                                            showDialog(
                                                              barrierDismissible:
                                                                  false,
                                                              context: context,
                                                              builder:
                                                                  (BuildContext
                                                                      context) {
                                                                Future.delayed(
                                                                  const Duration(
                                                                      seconds:
                                                                          3),
                                                                  () {
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop(
                                                                            true);
                                                                  },
                                                                );
                                                                return Dialog(
                                                                  alignment:
                                                                      Alignment
                                                                          .topCenter,
                                                                  shape:
                                                                      RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10.0),
                                                                  ),
                                                                  child:
                                                                      Container(
                                                                    padding: const EdgeInsets
                                                                            .symmetric(
                                                                        horizontal:
                                                                            20),
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        Text(
                                                                          "Added_to_Favorites"
                                                                              .tr(),
                                                                          style:
                                                                              const TextStyle(
                                                                            fontSize:
                                                                                16,
                                                                          ),
                                                                        ),
                                                                        IconButton(
                                                                          padding:
                                                                              const EdgeInsets.all(0),
                                                                          onPressed:
                                                                              () {
                                                                            Navigator.of(context).pop();
                                                                          },
                                                                          icon:
                                                                              const Icon(
                                                                            Icons.close_rounded,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                            );
                                                            for (M3uEntry m3u
                                                                in searchData[i]
                                                                    .data) {
                                                              await m3u
                                                                  .addToFavorites(
                                                                      refId!);
                                                            }
                                                          } else {
                                                            for (M3uEntry m3u
                                                                in searchData[i]
                                                                    .data) {
                                                              await m3u
                                                                  .removeFromFavorites(
                                                                      refId!);
                                                            }
                                                          }
                                                          await fetchFav();
                                                        },
                                                        initValue: isFavorite,
                                                        iconSize: 20,
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            );
                                          })
                                  : SeriesListPage(
                                      key: _kList,
                                      controller: _scrollController,
                                      data: seriesData)
                              : ind == 1
                                  ? FavSeriesPage(
                                      key: _favList,
                                      data: favData,
                                    )
                                  : HistorySeriesPage(
                                      key: _hisList,
                                      data: hisData,
                                    )
                          // : SeriesCategoryPage(category: label),
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

// body: StreamBuilder<CategorizedM3UData>(
//   stream: _vm.stream,
//   builder: (_, snapshot) {
//     if (snapshot.hasError || !snapshot.hasData) {
//       if (snapshot.hasError) {
//         return Container();
//       }
//       return const SeizhTvLoader(
//         label: "Retrieving Data",
//       );
//     }

//     final List<ClassifiedData> _cats = snapshot.data!.series;
//     _cats.sort((a, b) {
//       return a.name.toLowerCase().compareTo(b.name.toLowerCase());
//     });

//     if (_cats.isEmpty) {
//       return Center(
//         child: Text(
//           "No Live M3U Found!",
//           style: TextStyle(
//             color: Colors.white.withOpacity(.5),
//           ),
//         ),
//       );
//     }
// return Scrollbar(
//   controller: _scrollController,
//   child: ListView.separated(
//       controller: _scrollController,
//       itemBuilder: (_, i) {
//         final ClassifiedData data = _cats[i];
//         return ListTile(
//           onTap: () async {
//             await Navigator.push(
//               context,
//               PageTransition(
//                   child: ClassifiedSeriesData(data: data),
//                   type: PageTransitionType.leftToRight),
//             );
//           },
//           contentPadding: EdgeInsets.symmetric(horizontal: 15),
//           leading: SvgPicture.asset(
//             "assets/icons/logo-ico.svg",
//             width: 50,
//             color: orange,
//             fit: BoxFit.contain,
//           ),
//           trailing: const Icon(Icons.chevron_right),
//           title: Hero(
//             tag: data.name.toUpperCase(),
//             child: Material(
//               color: Colors.transparent,
//               elevation: 0,
//               child: Text(data.name),
//             ),
//           ),
//           subtitle: Text("${data.data.classify().length} Entries"),
//         );
//       },
//       separatorBuilder: (_, i) => Divider(
//             color: Colors.white.withOpacity(.3),
//           ),
//       itemCount: _cats.length),
// );
//   },
// ),
