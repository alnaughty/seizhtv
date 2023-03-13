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
import 'package:seizhtv/views/landing_page/children/live_children/classified_live_data.dart';
import 'package:z_m3u_handler/extension.dart';
import 'package:z_m3u_handler/z_m3u_handler.dart';

class LivePage extends StatefulWidget {
  const LivePage({super.key});

  @override
  State<LivePage> createState() => _LivePageState();
}

class _LivePageState extends State<LivePage> with ColorPalette, UIAdditional {
  final LoadedM3uData _vm = LoadedM3uData.instance;
  late final TextEditingController _search;
  late final ScrollController _scrollController;
  late final List<ClassifiedData> _data;
  List<ClassifiedData>? displayData;
  initStream() {
    _vm.stream.listen((event) {
      _data = List.from(event.live);
      _data.sort((a, b) => a.name.compareTo(b.name));
      displayData = List.from(_data);
      if (mounted) setState(() {});
    });
  }

  @override
  void initState() {
    _scrollController = ScrollController();
    _search = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initStream();
    });
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _search.dispose();
    // TODO: implement dispose
    super.dispose();
  }

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
          child: appbar(1, onSearchPressed: () {
            showSearchField = !showSearchField;
            if (mounted) setState(() {});
          }),
        ),
        body: Column(
          children: [
            AnimatedPadding(
              duration: const Duration(milliseconds: 400),
              padding:
                  EdgeInsets.symmetric(horizontal: showSearchField ? 20 : 0),
              child: AnimatedContainer(
                duration: const Duration(
                  milliseconds: 500,
                ),
                padding:
                    EdgeInsets.symmetric(horizontal: showSearchField ? 10 : 0),
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
                                  if (text.isEmpty) {
                                    displayData = List.from(_data);
                                  } else {
                                    displayData = List.from(
                                      _data.where(
                                        (element) =>
                                            element.name.toLowerCase().contains(
                                                  text.toLowerCase(),
                                                ),
                                      ),
                                    );
                                  }
                                  displayData!
                                      .sort((a, b) => a.name.compareTo(b.name));
                                  if (mounted) setState(() {});
                                  // if (text.isEmpty) {
                                  //   _displyData = List.from(data);
                                  // } else {
                                  // _displyData = List.from(
                                  //   data.where(
                                  //     (element) =>
                                  //         element.title.toLowerCase().contains(
                                  //               text.toLowerCase(),
                                  //             ),
                                  //   ),
                                  // );
                                  // }
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
                  : displayData!.isEmpty
                      ? Center(
                          child: Text(
                            "No Result Found for `${_search.text}`",
                            style: TextStyle(
                              color: Colors.white.withOpacity(.5),
                            ),
                          ),
                        )
                      : Scrollbar(
                          controller: _scrollController,
                          child: ListView.separated(
                              controller: _scrollController,
                              itemBuilder: (_, i) {
                                final ClassifiedData data = displayData![i];
                                return ListTile(
                                  onTap: () async {
                                    await Navigator.push(
                                      context,
                                      PageTransition(
                                          child: ClassifiedLiveData(data: data),
                                          type: PageTransitionType.leftToRight),
                                    );
                                  },
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  leading: SvgPicture.asset(
                                    "assets/icons/logo-ico.svg",
                                    width: 50,
                                    color: orange,
                                    fit: BoxFit.contain,
                                  ),
                                  trailing: const Icon(Icons.chevron_right),
                                  title: Hero(
                                    tag: data.name.toUpperCase(),
                                    child: Material(
                                      color: Colors.transparent,
                                      elevation: 0,
                                      child: Text(data.name),
                                    ),
                                  ),
                                  subtitle: Text(
                                      "${data.data.classify().length} Entries"),
                                );
                              },
                              separatorBuilder: (_, i) => Divider(
                                    color: Colors.white.withOpacity(.3),
                                  ),
                              itemCount: displayData!.length),
                          // child: Padding(
                          //   padding:
                          //       const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          //   child: CustomScrollView(
                          //     controller: _scrollController,
                          //     slivers: [
                          //       // SliverAppBar(
                          //       //   elevation: 0,
                          //       //   floating: true,
                          //       //   pinned: false,
                          //       //   centerTitle: false,
                          //       //   backgroundColor: card,
                          //       //   flexibleSpace: FlexibleSpaceBar(
                          //       //     background: filterChip([
                          //       //       "All",
                          //       //       "Favourites",
                          //       //       "Channels History",
                          //       //       "France FHD | UHD",
                          //       //       "France FHD HEVC"
                          //       //     ]),
                          //       //   ),
                          //       // ),
                          //       SliverGrid(
                          //         gridDelegate:
                          //             const SliverGridDelegateWithMaxCrossAxisExtent(
                          //           maxCrossAxisExtent: 150.0,
                          //           mainAxisSpacing: 10.0,
                          //           crossAxisSpacing: 10.0,
                          //           childAspectRatio: .8,
                          //         ),
                          //         delegate: SliverChildBuilderDelegate(
                          //           (BuildContext context, int index) {
                          //             final ClassifiedData _dat = _cat[index];
                          //             return ClipRRect(
                          //               borderRadius: BorderRadius.circular(12),
                          //               child: GestureDetector(
                          //                 onTap: () async {
                          //                   // await loadVideo(context, _dat);

                          //                 },
                          //                 child: Column(
                          //                   children: [
                          //                     // Expanded(
                          //                     //   child: LayoutBuilder(
                          //                     //     builder: (_, c) {
                          //                     //       final double w = c.maxWidth;
                          //                     //       final double h = c.maxHeight;
                          //                     //       return NetworkImageViewer(
                          //                     //         url: _dat.attributes['tvg-logo']!,
                          //                     //         height: h,
                          //                     //         width: w,
                          //                     //         fit: BoxFit.cover,
                          //                     //         color: card,
                          //                     //       );
                          //                     //     },
                          //                     //   ),
                          //                     // ),
                          //                     Align(
                          //                       alignment: Alignment.bottomCenter,
                          //                       child: Container(
                          //                         decoration: BoxDecoration(
                          //                           color: ColorPalette().highlight,
                          //                           borderRadius: const BorderRadius.only(
                          //                             bottomLeft: Radius.circular(12),
                          //                             bottomRight: Radius.circular(12),
                          //                           ),
                          //                         ),
                          //                         padding: const EdgeInsets.symmetric(
                          //                             horizontal: 10),
                          //                         width: double.infinity,
                          //                         height: 45,
                          //                         child: Align(
                          //                           alignment:
                          //                               AlignmentDirectional.centerStart,
                          //                           child: Text(
                          //                             _dat.name.isEmpty
                          //                                 ? "Unnamed"
                          //                                 : _dat.name,
                          //                             maxLines: 2,
                          //                             style: const TextStyle(
                          //                               height: 1,
                          //                             ),
                          //                           ),
                          //                         ),
                          //                       ),
                          //                     ),
                          //                   ],
                          //                 ),
                          //               ),
                          //             );
                          //           },
                          //           childCount: _cat.length,
                          //         ),
                          //       )
                          //     ],
                          //   ),
                          // ),
                        ),
            ),
          ],
        ),
        // body: StreamBuilder<CategorizedM3UData>(
        //     stream: _vm.stream,
        //     builder: (context, snapshot) {
        //       if (snapshot.hasError || !snapshot.hasData) {
        //         if (snapshot.hasError) {
        //           return Container();
        //         }
        // return const SeizhTvLoader(
        //   label: "Retrieving Data",
        // );
        //       }
        //       // final List<M3uEntry> _entries = ;
        //       if (snapshot.data!.live.isEmpty) {
        // return Center(
        //   child: Text(
        //     "No Live M3U Found!",
        //     style: TextStyle(
        //       color: Colors.white.withOpacity(.5),
        //     ),
        //   ),
        // );
        //       }
        //       final List<ClassifiedData> _cat = snapshot.data!.live;
        //       _cat.sort((a, b) => a.name.compareTo(b.name));
        //       List<ClassifiedData> _displayData = List.from(_cat);
        //       // final Map<String, List<M3uEntry>> _cat =
        //       //     snapshot.data!.live.categorize(needle: "title-clean");
        // return Column(
        //   children: [

        //     // Padding(
        //     //   padding: const EdgeInsets.symmetric(horizontal: 20),
        //     //   child: Container(
        //     //     height: 50,
        //     //     padding: const EdgeInsets.symmetric(horizontal: 10),
        //     //     decoration: BoxDecoration(
        //     //         color: highlight,
        //     //         borderRadius: BorderRadius.circular(10),
        //     //         boxShadow: [
        //     //           BoxShadow(
        //     //             color: highlight.darken().withOpacity(1),
        //     //             offset: const Offset(2, 2),
        //     //             blurRadius: 2,
        //     //           )
        //     //         ]),
        //     //     child: Row(
        //     //       children: [
        //     // SvgPicture.asset(
        //     //   "assets/icons/search.svg",
        //     //   height: 20,
        //     //   width: 20,
        //     //   color: white,
        //     // ),
        //     // const SizedBox(
        //     //   width: 10,
        //     // ),
        //     // Expanded(
        //     //   child: TextField(
        //     //     onChanged: (text) {
        //     //       // if (text.isEmpty) {
        //     //       //   _displyData = List.from(data);
        //     //       // } else {
        //     //       //   _displyData = List.from(
        //     //       //     data.where(
        //     //       //       (element) =>
        //     //       //           element.title.toLowerCase().contains(
        //     //       //                 text.toLowerCase(),
        //     //       //               ),
        //     //       //     ),
        //     //       //   );
        //     //       // }
        //     //       // _displyData
        //     //       //     .sort((a, b) => a.title.compareTo(b.title));
        //     //       // if (mounted) setState(() {});
        //     //     },
        //     //     cursorColor: orange,
        //     //     controller: _search,
        //     //     decoration: const InputDecoration(
        //     //       hintText: "Search",
        //     //     ),
        //     //   ),
        //     // ),
        //     //       ],
        //     //     ),
        //     //   ),
        //     // ),
        // const SizedBox(
        //   height: 10,
        // ),
        // Expanded(
        //   child: Scrollbar(
        //     controller: _scrollController,
        //     child: ListView.separated(
        //         controller: _scrollController,
        //         itemBuilder: (_, i) {
        //           final ClassifiedData data = _cat[i];
        //           return ListTile(
        //             onTap: () async {
        //               await Navigator.push(
        //                 context,
        //                 PageTransition(
        //                     child: ClassifiedLiveData(data: data),
        //                     type: PageTransitionType.leftToRight),
        //               );
        //             },
        //             contentPadding:
        //                 EdgeInsets.symmetric(horizontal: 15),
        //             leading: SvgPicture.asset(
        //               "assets/icons/logo-ico.svg",
        //               width: 50,
        //               color: orange,
        //               fit: BoxFit.contain,
        //             ),
        //             trailing: const Icon(Icons.chevron_right),
        //             title: Hero(
        //               tag: data.name.toUpperCase(),
        //               child: Material(
        //                 color: Colors.transparent,
        //                 elevation: 0,
        //                 child: Text(data.name),
        //               ),
        //             ),
        //             subtitle: Text(
        //                 "${data.data.classify().length} Entries"),
        //           );
        //         },
        //         separatorBuilder: (_, i) => Divider(
        //               color: Colors.white.withOpacity(.3),
        //             ),
        //         itemCount: _displayData.length),
        //     // child: Padding(
        //     //   padding:
        //     //       const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        //     //   child: CustomScrollView(
        //     //     controller: _scrollController,
        //     //     slivers: [
        //     //       // SliverAppBar(
        //     //       //   elevation: 0,
        //     //       //   floating: true,
        //     //       //   pinned: false,
        //     //       //   centerTitle: false,
        //     //       //   backgroundColor: card,
        //     //       //   flexibleSpace: FlexibleSpaceBar(
        //     //       //     background: filterChip([
        //     //       //       "All",
        //     //       //       "Favourites",
        //     //       //       "Channels History",
        //     //       //       "France FHD | UHD",
        //     //       //       "France FHD HEVC"
        //     //       //     ]),
        //     //       //   ),
        //     //       // ),
        //     //       SliverGrid(
        //     //         gridDelegate:
        //     //             const SliverGridDelegateWithMaxCrossAxisExtent(
        //     //           maxCrossAxisExtent: 150.0,
        //     //           mainAxisSpacing: 10.0,
        //     //           crossAxisSpacing: 10.0,
        //     //           childAspectRatio: .8,
        //     //         ),
        //     //         delegate: SliverChildBuilderDelegate(
        //     //           (BuildContext context, int index) {
        //     //             final ClassifiedData _dat = _cat[index];
        //     //             return ClipRRect(
        //     //               borderRadius: BorderRadius.circular(12),
        //     //               child: GestureDetector(
        //     //                 onTap: () async {
        //     //                   // await loadVideo(context, _dat);

        //     //                 },
        //     //                 child: Column(
        //     //                   children: [
        //     //                     // Expanded(
        //     //                     //   child: LayoutBuilder(
        //     //                     //     builder: (_, c) {
        //     //                     //       final double w = c.maxWidth;
        //     //                     //       final double h = c.maxHeight;
        //     //                     //       return NetworkImageViewer(
        //     //                     //         url: _dat.attributes['tvg-logo']!,
        //     //                     //         height: h,
        //     //                     //         width: w,
        //     //                     //         fit: BoxFit.cover,
        //     //                     //         color: card,
        //     //                     //       );
        //     //                     //     },
        //     //                     //   ),
        //     //                     // ),
        //     //                     Align(
        //     //                       alignment: Alignment.bottomCenter,
        //     //                       child: Container(
        //     //                         decoration: BoxDecoration(
        //     //                           color: ColorPalette().highlight,
        //     //                           borderRadius: const BorderRadius.only(
        //     //                             bottomLeft: Radius.circular(12),
        //     //                             bottomRight: Radius.circular(12),
        //     //                           ),
        //     //                         ),
        //     //                         padding: const EdgeInsets.symmetric(
        //     //                             horizontal: 10),
        //     //                         width: double.infinity,
        //     //                         height: 45,
        //     //                         child: Align(
        //     //                           alignment:
        //     //                               AlignmentDirectional.centerStart,
        //     //                           child: Text(
        //     //                             _dat.name.isEmpty
        //     //                                 ? "Unnamed"
        //     //                                 : _dat.name,
        //     //                             maxLines: 2,
        //     //                             style: const TextStyle(
        //     //                               height: 1,
        //     //                             ),
        //     //                           ),
        //     //                         ),
        //     //                       ),
        //     //                     ),
        //     //                   ],
        //     //                 ),
        //     //               ),
        //     //             );
        //     //           },
        //     //           childCount: _cat.length,
        //     //         ),
        //     //       )
        //     //     ],
        //     //   ),
        //     // ),
        //   ),
        // ),
        //   ],
        // );
        //     }),
      ),
    );
  }
}
