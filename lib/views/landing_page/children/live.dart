// ignore_for_file: deprecated_member_use

import 'dart:async';

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

class LivePage extends StatefulWidget {
  const LivePage({super.key});

  @override
  State<LivePage> createState() => _LivePageState();
}

class _LivePageState extends State<LivePage>
    with ColorPalette, UIAdditional, VideoLoader {
  final int _itemsPerPage = 20; // number of items to show per page
  int _currentPage = 0; // current page index
  final LoadedM3uData _vm = LoadedM3uData.instance;
  late final TextEditingController _search;
  late final ScrollController _scrollController;
  late final List<M3uEntry> _data;
  List<M3uEntry>? displayData;
  late final StreamSubscription<CategorizedM3UData> _streamer;
  int loadLength = 100;
  bool update = false;

  initStream() {
    _streamer = _vm.stream.listen((event) {
      _data = List.from(
          event.live.expand((element) => element.data).toList().unique());
      // _data.sort((a, b) => a.name.compareTo(b.name));
      displayData = List.from(_data.unique());
      displayData!.sort((a, b) => a.title.compareTo(b.title));
      if (mounted) setState(() {});
    });
    // _vm.stream.listen((event) {

    // });
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
                AnimatedPadding(
                  duration: const Duration(milliseconds: 400),
                  padding: EdgeInsets.symmetric(
                      horizontal: showSearchField ? 20 : 0),
                  child: AnimatedContainer(
                    duration: const Duration(
                      milliseconds: 500,
                    ),
                    padding: EdgeInsets.symmetric(
                        horizontal: showSearchField ? 10 : 0),
                    height: showSearchField ? 50 : 0,
                    width: double.maxFinite,
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
                        const SizedBox(
                          width: 10,
                        ),
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
                                    decoration: const InputDecoration(
                                      hintText: "Search",
                                    ),
                                  )
                                : Container(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (showSearchField) ...{
                  const SizedBox(
                    height: 10,
                  ),
                },
                Expanded(
                  child: displayData == null
                      ? const SeizhTvLoader(
                          label: "Retrieving Data",
                        )
                      : Scrollbar(
                          controller: _scrollController,
                          child: LiveList(
                            key: _kList,
                            data: displayData!,
                            controller: _scrollController,
                            onPressed: (M3uEntry entry) async {
                              print("LIVE DATA: ${entry}");
                              await loadVideo(context, entry);
                              await entry.addToHistory(refId!);
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
