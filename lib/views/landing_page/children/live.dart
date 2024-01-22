// ignore_for_file: deprecated_member_use, avoid_print

import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:page_transition/page_transition.dart';
import 'package:seizhtv/data_containers/loaded_m3u_data.dart';
import 'package:seizhtv/extensions/color.dart';
import 'package:seizhtv/extensions/list.dart';
import 'package:seizhtv/extensions/state.dart';
import 'package:seizhtv/globals/loader.dart';
import 'package:seizhtv/globals/palette.dart';
import 'package:seizhtv/globals/ui_additional.dart';
import 'package:seizhtv/views/landing_page/children/live_children/live_list.dart';
import 'package:z_m3u_handler/z_m3u_handler.dart';
import '../../../data_containers/favorites.dart';
import '../../../data_containers/history.dart';
import '../../../globals/data.dart';
import '../../../globals/video_loader.dart';
import 'live_children/cat_live.dart';
import 'live_children/fav_live_tv.dart';
import 'live_children/his_live_tv.dart';

class LivePage extends StatefulWidget {
  const LivePage({super.key});

  @override
  State<LivePage> createState() => _LivePageState();
}

class _LivePageState extends State<LivePage>
    with ColorPalette, UIAdditional, VideoLoader {
  late final StreamSubscription<CategorizedM3UData> _streamer;
  static final ZM3UHandler _handler = ZM3UHandler.instance;
  final LoadedM3uData _vm = LoadedM3uData.instance;
  late final ScrollController _scrollController;
  final Favorites _favvm = Favorites.instance;
  late final TextEditingController _search;
  final History _hisvm = History.instance;
  late List<ClassifiedData> sdata = [];
  late List<String>? categoryName = [];
  late List<ClassifiedData> _favdata;
  late List<ClassifiedData> _hisdata;
  late List<M3uEntry> favData = [];
  late List<M3uEntry> hisData = [];
  late final List<M3uEntry> _data;
  List<M3uEntry>? displayData;
  String dropdownvalue = "";
  String categorylabel = "";
  bool selected = true;
  bool update = false;
  int prevIndex = 1;
  int? ind = 0;

  initStream() {
    _streamer = _vm.stream.listen((event) {
      sdata = List.from(event.live);
      _data = List.from(
          event.live.expand((element) => element.data).toList().unique());
      displayData = List.from(_data.unique());
      displayData!.sort((a, b) => a.title.compareTo(b.title));
      categoryName = [
        "ALL (${displayData == null ? "" : displayData!.length})"
      ];
      for (final ClassifiedData cdata in sdata) {
        categoryName!.add("${cdata.name} (${cdata.data.length})");
      }
      categoryName!.sort((a, b) => a.compareTo(b));
      dropdownvalue = categoryName![3];
      if (mounted) setState(() {});
    });
  }

  fetchFav() async {
    await _handler
        .getDataFrom(type: CollectionType.favorites, refId: refId!)
        .then((value) {
      if (value != null) {
        _favvm.populate(value);
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
    _favvm.stream.listen((event) {
      _favdata = List.from(event.live);
      favData = _favdata.expand((element) => element.data).toList();
    });
  }

  initHisStream() {
    _hisvm.stream.listen((event) {
      _hisdata = List.from(event.live);
      hisData = _hisdata.expand((element) => element.data).toList();
    });
  }

  @override
  void initState() {
    _scrollController = ScrollController();
    _search = TextEditingController();
    showSearchField = false;
    initStream();
    fetchFav();
    fetchHis();
    initFavStream();
    initHisStream();
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _search.dispose();
    _streamer.cancel();
    showSearchField = false;
    super.dispose();
  }

  final GlobalKey<LiveListState> _kList = GlobalKey<LiveListState>();
  final GlobalKey<FavLiveTvPageState> _favPage =
      GlobalKey<FavLiveTvPageState>();
  final GlobalKey<HistoryLiveTvPageState> _hisPage =
      GlobalKey<HistoryLiveTvPageState>();
  final GlobalKey<LiveCategoryPageState> _catPage =
      GlobalKey<LiveCategoryPageState>();
  bool showSearchField = false;

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
            1,
            onSearchPressed: () async {
              showSearchField = !showSearchField;
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
                      style: const TextStyle(color: Colors.white, fontSize: 16),
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
                                  prevIndex = ind!;
                                  ind = 0;
                                  print("CURRENT INDEX $ind");
                                  print("PREV INDEX $prevIndex");
                                });
                              },
                              child: ind == 0 && prevIndex != 0
                                  ? ChoiceChip(
                                      showCheckmark: false,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      label: Container(
                                        width: 170,
                                        height: 45,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(30),
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
                                                child: Text(value));
                                          }).toList(),
                                          value: dropdownvalue == ""
                                              ? categoryName == []
                                                  ? ""
                                                  : categoryName![3]
                                              : dropdownvalue,
                                          style: const TextStyle(
                                              // fontSize: 14,
                                              fontFamily: "Poppins"),
                                          onChanged: (value) {
                                            setState(
                                              () {
                                                dropdownvalue = value!;
                                                String result1 =
                                                    dropdownvalue.replaceAll(
                                                        RegExp(
                                                            r"[(]+[0-9]+[)]"),
                                                        '');
                                                categorylabel = result1;
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                      selected: ind == 0 ? true : false,
                                      selectedColor: ColorPalette().topColor,
                                      disabledColor: ColorPalette().highlight,
                                    )
                                  : ChoiceChip(
                                      showCheckmark: false,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      label: SizedBox(
                                        height: 45,
                                        child: Center(
                                          child: Text(
                                            dropdownvalue,
                                            style: const TextStyle(
                                                fontFamily: "Poppins"),
                                          ),
                                        ),
                                      ),
                                      selected: ind == 0 ? true : false,
                                      selectedColor: ColorPalette().topColor,
                                      disabledColor: ColorPalette().highlight,
                                    ),
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  prevIndex = ind!;
                                  ind = 1;
                                  print("CURRENT INDEX $ind");
                                  print("PREV INDEX $prevIndex");
                                });
                              },
                              child: ChoiceChip(
                                showCheckmark: false,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                label: SizedBox(
                                  height: 45,
                                  child: Center(
                                    child: Text(
                                      "${"favorites".tr()} (${favData.length})",
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                                selected: ind == 1 ? true : false,
                                selectedColor: ColorPalette().topColor,
                                disabledColor: ColorPalette().highlight,
                              ),
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  prevIndex = ind!;
                                  ind = 2;
                                  print("CURRENT INDEX $ind");
                                  print("PREV INDEX $prevIndex");
                                });
                              },
                              child: ChoiceChip(
                                showCheckmark: false,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                label: SizedBox(
                                  height: 45,
                                  child: Center(
                                    child: Text(
                                      "${"Channels_History".tr()} (${hisData.length})",
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                                selected: ind == 2 ? true : false,
                                selectedColor: ColorPalette().topColor,
                                disabledColor: ColorPalette().highlight,
                              ),
                            ),
                            const SizedBox(width: 10),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      AnimatedPadding(
                        duration: const Duration(milliseconds: 400),
                        padding: EdgeInsets.symmetric(
                            horizontal: showSearchField ? 20 : 0),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
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
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            highlight.darken().withOpacity(1),
                                        offset: const Offset(2, 2),
                                        blurRadius: 2,
                                      )
                                    ],
                                  ),
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
                                                    if (mounted) {
                                                      setState(() {});
                                                    }
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
                                ),
                              ),
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
                                  ? LiveList(
                                      key: _kList,
                                      data: displayData!,
                                      onPressed: (M3uEntry entry) async {
                                        entry.addToHistory(refId!);
                                        await loadVideo(context, entry);
                                      },
                                    )
                                  : LiveCategoryPage(
                                      key: _catPage,
                                      category: categorylabel,
                                    )
                              : ind == 1
                                  ? FavLiveTvPage(
                                      key: _favPage,
                                      data: favData,
                                      onPressed: (M3uEntry entry) async {
                                        entry.addToHistory(refId!);
                                        await loadVideo(context, entry);
                                      },
                                    )
                                  : HistoryLiveTvPage(
                                      key: _hisPage,
                                      data: hisData,
                                      onPressed: (M3uEntry entry) async {
                                        entry.addToHistory(refId!);
                                        await loadVideo(context, entry);
                                      },
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

// return showModalBottomSheet(
//   context: context,
//   isDismissible: true,
//   backgroundColor: Colors.transparent,
//   isScrollControlled: true,
//   builder: (_) => LiveDetails(
//     onLoadVideo: () async {
//       Navigator.of(context).pop(null);
//       await loadVideo(context, entry);
//       await entry.addToHistory(refId!);
//     },
//     entry: entry,
//   ),
// );

// body: Column(
//   children: [

//     Expanded(
// child: displayData == null
//     ? const SeizhTvLoader(
//         label: "Retrieving Data",
//       )
// : displayData!.isEmpty
//     ? Center(
//         child: Text(
//           "No Result Found for `${_search.text}`",
//           style: TextStyle(
//             color: Colors.white.withOpacity(.5),
//           ),
//         ),
//       )
//     : Scrollbar(
//                   controller: _scrollController,
//   child: ListView.separated(
//       controller: _scrollController,
//       itemBuilder: (_, i) {
//         final ClassifiedData data = displayData![i];
//         return ListTile(
//           onTap: () async {
//             await Navigator.push(
//               context,
//               PageTransition(
//                   child: ClassifiedLiveData(data: data),
//                   type: PageTransitionType.leftToRight),
//             );
//           },
//           contentPadding: const EdgeInsets.symmetric(
//               horizontal: 15),
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
//           subtitle: Text(
//               "${data.data.classify().length} Entries"),
//         );
//       },
//       separatorBuilder: (_, i) => Divider(
//             color: Colors.white.withOpacity(.3),
//           ),
//       itemCount: displayData!.length),
// ),
//     ),
//   ],
// ),
