// ignore_for_file: deprecated_member_use, avoid_print

import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:seizhtv/data_containers/loaded_m3u_data.dart';
import 'package:seizhtv/extensions/color.dart';
import 'package:seizhtv/extensions/list.dart';
import 'package:seizhtv/extensions/state.dart';
import 'package:seizhtv/globals/loader.dart';
import 'package:seizhtv/globals/palette.dart';
import 'package:seizhtv/globals/ui_additional.dart';
import 'package:seizhtv/views/landing_page/children/live_children/live_list.dart';
import 'package:z_m3u_handler/z_m3u_handler.dart';
import '../../../globals/data.dart';
import '../../../globals/video_loader.dart';
import 'live_children/fav_live_tv.dart';
import 'live_children/his_live_tv.dart';

class LivePage extends StatefulWidget {
  const LivePage({super.key});

  @override
  State<LivePage> createState() => _LivePageState();
}

class _LivePageState extends State<LivePage>
    with ColorPalette, UIAdditional, VideoLoader {
  // final int _itemsPerPage = 20; // number of items to show per page
  // int _currentPage = 0; // current page index
  final LoadedM3uData _vm = LoadedM3uData.instance;
  late final TextEditingController _search;
  late final ScrollController _scrollController;
  late final List<M3uEntry> _data;
  List<M3uEntry>? displayData;
  late final StreamSubscription<CategorizedM3UData> _streamer;
  int loadLength = 100;
  bool update = false;
  bool subpage = false;
  int ind = 0;
  bool searchClose = true;
  bool selectedIndex = false;

  initStream() {
    _streamer = _vm.stream.listen((event) {
      _data = List.from(
          event.live.expand((element) => element.data).toList().unique());
      // _data.sort((a, b) => a.name.compareTo(b.name));
      displayData = List.from(_data.unique());
      displayData!.sort((a, b) => a.title.compareTo(b.title));
      if (mounted) setState(() {});
    });
  }

  @override
  void initState() {
    _scrollController = ScrollController();
    _search = TextEditingController();
    showSearchField = false;
    initStream();
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
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  height: 50,
                  child: UIAdditional().filterChip(
                    chipsLabel: [
                      "All (${displayData == null ? "" : displayData!.length})",
                      "favorites".tr(),
                      "Channels_History".tr(),
                    ],
                    onPressed: (index) {
                      setState(() {
                        print("$index");
                        ind = index;
                      });
                    },
                    si: ind,
                  ),
                ),
                // ListView.separated(
                //   scrollDirection: Axis.horizontal,
                //   itemBuilder: (context, index) => GestureDetector(
                //     onTap: () {
                //       setState(() {
                //         ind = index;
                //         print("$ind");
                //       });
                //     },
                //     child: Chip(
                //       backgroundColor: ColorPalette().highlight,
                //       padding: const EdgeInsets.all(10),
                //       label: Text("${category[index]}"
                //           "${index == 0 ? displayData == null ? "" : displayData!.length : ""}"),
                //     ),
                //   ),
                //   itemCount: category.length,
                //   separatorBuilder: (BuildContext context, int index) {
                //     return const SizedBox(width: 10);
                //   },
                // ),
                const SizedBox(height: 15),
                AnimatedPadding(
                  duration: const Duration(milliseconds: 400),
                  padding: EdgeInsets.symmetric(
                      horizontal: showSearchField ? 20 : 0),
                  child: AnimatedContainer(
                    duration: const Duration(
                      milliseconds: 500,
                    ),
                    // margin: EdgeInsets.only(top: showSearchField ? 10 : 0),
                    // padding: EdgeInsets.symmetric(
                    //     horizontal: showSearchField ? 10 : 0),
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
                                            if (_kList.currentState != null) {
                                              _kList.currentState!.search(text);
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
                              print("SEARCH TEXT ${_search.text == ""}");
                              displayData = List.from(_data);
                              showSearchField = !showSearchField;
                              searchClose = !searchClose;
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
                              ? LiveList(
                                  key: _kList,
                                  data: displayData!,
                                  controller: _scrollController,
                                  searchClose: searchClose,
                                  onPressed: (M3uEntry entry) async {
                                    print("DATA CLICK: $entry");
                                    entry.addToHistory(refId!);
                                    await loadVideo(context, entry);
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
                                  },
                                )
                              : ind == 1
                                  ? FavLiveTvPage(
                                      key: _favPage,
                                      data: displayData!,
                                      controller: _scrollController,
                                      onPressed: (M3uEntry entry) async {
                                        print("DATA CLICK: $entry");
                                        entry.addToHistory(refId!);
                                        await loadVideo(context, entry);
                                      },
                                    )
                                  : HistoryLiveTvPage(
                                      key: _hisPage,
                                      data: displayData!,
                                      controller: _scrollController,
                                      onPressed: (M3uEntry entry) async {
                                        print("DATA CLICK: $entry");
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
      ),
    );
  }
}
