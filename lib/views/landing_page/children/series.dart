// ignore_for_file: deprecated_member_use, avoid_print

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:page_transition/page_transition.dart';
import 'package:seizhtv/data_containers/loaded_m3u_data.dart';
import 'package:seizhtv/extensions/classified_data.dart';
import 'package:seizhtv/extensions/color.dart';
import 'package:seizhtv/extensions/m3u_entry.dart';
import 'package:seizhtv/extensions/state.dart';
import 'package:seizhtv/globals/loader.dart';
import 'package:seizhtv/globals/palette.dart';
import 'package:seizhtv/globals/ui_additional.dart';
import 'package:seizhtv/globals/video_loader.dart';
import 'package:seizhtv/services/tv_series_api.dart';
import 'package:seizhtv/views/landing_page/children/series_children/details.dart';
import 'package:seizhtv/views/landing_page/children/series_children/fav_series.dart';
import 'package:seizhtv/views/landing_page/children/series_children/his_series.dart';
import 'package:z_m3u_handler/extension.dart';
import 'package:z_m3u_handler/z_m3u_handler.dart';
import '../../../data_containers/favorites.dart';
import '../../../globals/data.dart';
import '../../../globals/favorite_button.dart';
import '../../../globals/network_image_viewer.dart';
import '../../../viewmodel/tvshow_vm.dart';
import '../../../viewmodel/video_vm.dart';

class SeriesPage extends StatefulWidget {
  const SeriesPage({super.key});

  @override
  State<SeriesPage> createState() => _SeriesPageState();
}

class _SeriesPageState extends State<SeriesPage>
    with ColorPalette, UIAdditional, VideoLoader, TVSeriesAPI {
  late final ScrollController _scrollController;
  static final TVVideoViewModel _videoViewModel = TVVideoViewModel.instance;
  static final TopRatedTVShowViewModel _viewModel =
      TopRatedTVShowViewModel.instance;
  static final ZM3UHandler _handler = ZM3UHandler.instance;
  static final Favorites _fav = Favorites.instance;
  late final TextEditingController _search;
  late List<ClassifiedData> _data;
  late List<ClassifiedData> _favdata;
  List<ClassifiedData>? displayData;
  List<ClassifiedData> searchData = [];
  List<ClassifiedData> seriesData = [];
  List<ClassifiedData> favData = [];
  bool showSearchField = false;
  bool selectedIndex = false;
  bool update = false;
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

  List<String> category = [
    "All ",
    "favorites".tr(),
    "Series History",
  ];

  initStream() {
    _vm.stream.listen((event) {
      _data = List.from(event.series);
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

      for (final ClassifiedData item in _favdata) {
        late final List<ClassifiedData> data = item.data.classify()
          ..sort((a, b) => a.name.compareTo(b.name));

        favData.addAll(List.from(data));
      }
      print("SERIES FAV: ${favData.length}");
    });
  }

  @override
  void initState() {
    _scrollController = ScrollController();
    _search = TextEditingController();
    initStream();
    fetchFav();
    initFavStream();
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _search.dispose();
    super.dispose();
  }

  final double boxWidth = 90;
  final LoadedM3uData _vm = LoadedM3uData.instance;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
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
                      "All (${displayData == null ? "" : seriesData.length})",
                      "favorites".tr(),
                      "Series History",
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
                                            // searchData.sort((a, b) =>
                                            //     a.name.compareTo(b.name));
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
                // showSearchField || ind != 0
                //     ? Container()
                //     : StreamBuilder<List<TopSeriesModel>>(
                //         stream: _viewModel.stream,
                //         builder: (context, snapshot) {
                //           if (snapshot.hasData && !snapshot.hasError) {
                //             if (snapshot.data!.isNotEmpty) {
                //               final List<TopSeriesModel> result =
                //                   snapshot.data!;
                //               getTVVideos(id: result[0].id);

                //               for (final TopSeriesModel tm in result) {
                //                 final Iterable<ClassifiedData> cd =
                //                     seriesData.where((element) => element.name
                //                         .toLowerCase()
                //                         .contains(tm.title.toLowerCase()));

                //                 return Column(
                //                   children: [
                //                     StreamBuilder<List<Video>>(
                //                       stream: _videoViewModel.stream,
                //                       builder: (context, snapshot) {
                //                         if (snapshot.hasData &&
                //                             !snapshot.hasError) {
                //                           if (snapshot.data!.isNotEmpty) {
                //                             final List<Video> result =
                //                                 snapshot.data!;
                //                             return Videoplayer(
                //                               url: result[0].key,
                //                             );
                //                           }
                //                         }
                //                         return const Center(
                //                           child: CircularProgressIndicator(
                //                             color: Colors.grey,
                //                           ),
                //                         );
                //                       },
                //                     ),
                //                     MaterialButton(
                //                       elevation: 0,
                //                       color: Colors.transparent,
                //                       padding: const EdgeInsets.all(0),
                //                       onPressed: () {
                //                         Navigator.push(
                //                           context,
                //                           PageTransition(
                //                             child: SeriesDetailsPage(
                //                               data: cd.first,
                //                               title: cd.first.name,
                //                             ),
                //                             type:
                //                                 PageTransitionType.rightToLeft,
                //                           ),
                //                         );
                //                       },
                //                       child: Container(
                //                         width: size.width,
                //                         padding: const EdgeInsets.symmetric(
                //                             horizontal: 20, vertical: 15),
                //                         child: Column(
                //                           crossAxisAlignment:
                //                               CrossAxisAlignment.start,
                //                           children: [
                //                             Text(
                //                               cd.first.name,
                //                               maxLines: 2,
                //                               overflow: TextOverflow.ellipsis,
                //                               style: const TextStyle(
                //                                 fontWeight: FontWeight.w500,
                //                                 fontSize: 22,
                //                                 height: 1.1,
                //                               ),
                //                             ),
                //                             Row(
                //                               children: [
                //                                 Text(DateFormat('MMM dd, yyyy')
                //                                     .format(tm.date!)),
                //                                 const SizedBox(width: 10),
                //                                 Container(
                //                                   padding: const EdgeInsets
                //                                       .symmetric(horizontal: 5),
                //                                   decoration: BoxDecoration(
                //                                     border: Border.all(
                //                                         color: Colors.white),
                //                                     borderRadius:
                //                                         const BorderRadius.all(
                //                                       Radius.circular(5),
                //                                     ),
                //                                   ),
                //                                   child:
                //                                       Text("${tm.voteAverage}"),
                //                                 ),
                //                                 const SizedBox(width: 15),
                //                                 SizedBox(
                //                                   height: 25,
                //                                   width: 30,
                //                                   child: MaterialButton(
                //                                     color: Colors.grey,
                //                                     padding:
                //                                         const EdgeInsets.all(0),
                //                                     onPressed: () {},
                //                                     child: const Text(
                //                                       "HD",
                //                                       style: TextStyle(
                //                                           fontWeight:
                //                                               FontWeight.w600),
                //                                     ),
                //                                   ),
                //                                 ),
                //                               ],
                //                             ),
                //                           ],
                //                         ),
                //                       ),
                //                     ),
                //                   ],
                //                 );
                //               }
                //             }
                //           }
                //           return const Center(
                //             child: CircularProgressIndicator(
                //               color: Colors.grey,
                //             ),
                //           );
                //         },
                //       ),
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
                              // ? showSearchField
                              ? searchData.isEmpty
                                  ? Center(
                                      child: Text(
                                        "No Result Found for `${_search.text}`",
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(.5),
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
                                              mainAxisSpacing: 5,
                                              crossAxisSpacing: 10),
                                      itemCount: searchData.length,
                                      itemBuilder: (context, i) {
                                        bool isFavorite = false;
                                        for (final ClassifiedData fav
                                            in favData) {
                                          if (searchData[i].name == fav.name) {
                                            if (fav.data.length ==
                                                searchData[i].data.length) {
                                              isFavorite = true;
                                            }
                                          }
                                        }

                                        return GestureDetector(
                                          onTap: () async {
                                            String result1 = searchData[i]
                                                .name
                                                .replaceAll(
                                                    RegExp(
                                                        r"[(]+[a-zA-Z]+[)]|[|]\s+[0-9]+\s[|]"),
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
                                                margin: const EdgeInsets.only(
                                                    top: 10, right: 10),
                                                child: LayoutBuilder(
                                                  builder: (context, c) {
                                                    final double w = c.maxWidth;
                                                    return Tooltip(
                                                      message:
                                                          searchData[i].name,
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
                                                              url: searchData[i]
                                                                      .data[0]
                                                                      .attributes[
                                                                  'tvg-logo'],
                                                              width: w,
                                                              height: 53,
                                                              fit: BoxFit.cover,
                                                              color: highlight,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 2),
                                                          Tooltip(
                                                            message:
                                                                searchData[i]
                                                                    .name,
                                                            child: Text(
                                                              searchData[i]
                                                                  .name,
                                                              style:
                                                                  const TextStyle(
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
                                                                      color: Colors
                                                                          .grey)),
                                                              Text(
                                                                  "Episodes"
                                                                      .tr(),
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      color: Colors
                                                                          .grey)),
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
                                                          builder: (BuildContext
                                                              context) {
                                                            Future.delayed(
                                                              const Duration(
                                                                  seconds: 3),
                                                              () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop(true);
                                                              },
                                                            );
                                                            return Dialog(
                                                              alignment:
                                                                  Alignment
                                                                      .topCenter,
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                  10.0,
                                                                ),
                                                              ),
                                                              child: Container(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .symmetric(
                                                                  horizontal:
                                                                      20,
                                                                ),
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
                                                                          const EdgeInsets.all(
                                                                              0),
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.of(context)
                                                                            .pop();
                                                                      },
                                                                      icon:
                                                                          const Icon(
                                                                        Icons
                                                                            .close_rounded,
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
                                              // Positioned(
                                              //   top: 0,
                                              //   right: 0,
                                              //   child: SizedBox(
                                              //       height: 25,
                                              //       width: 25,
                                              //       child: MaterialButton(
                                              //         padding: EdgeInsets.zero,
                                              //         onPressed: () async {
                                              //           if (!isFavorite) {
                                              //             // await widget.data.data[0].addToFavorites(refId!);
                                              //             showDialog(
                                              //               context: context,
                                              //               builder:
                                              //                   (BuildContext
                                              //                       context) {
                                              //                 Future.delayed(
                                              //                   const Duration(
                                              //                       seconds: 5),
                                              //                   () {
                                              //                     Navigator.of(
                                              //                             context)
                                              //                         .pop(
                                              //                             true);
                                              //                   },
                                              //                 );
                                              //                 return Dialog(
                                              //                   alignment:
                                              //                       Alignment
                                              //                           .topCenter,
                                              //                   shape:
                                              //                       RoundedRectangleBorder(
                                              //                     borderRadius:
                                              //                         BorderRadius
                                              //                             .circular(
                                              //                       10.0,
                                              //                     ),
                                              //                   ),
                                              //                   child:
                                              //                       Container(
                                              //                     height: 50,
                                              //                     padding:
                                              //                         const EdgeInsets
                                              //                             .symmetric(
                                              //                       vertical:
                                              //                           15,
                                              //                       horizontal:
                                              //                           20,
                                              //                     ),
                                              //                     child: Row(
                                              //                       mainAxisAlignment:
                                              //                           MainAxisAlignment
                                              //                               .spaceBetween,
                                              //                       children: [
                                              //                         Text(
                                              //                           "Added_to_Favorites"
                                              //                               .tr(),
                                              //                           style:
                                              //                               const TextStyle(
                                              //                             fontSize:
                                              //                                 16,
                                              //                           ),
                                              //                         ),
                                              //                         IconButton(
                                              //                           padding:
                                              //                               const EdgeInsets.all(0),
                                              //                           onPressed:
                                              //                               () {
                                              //                             Navigator.of(context)
                                              //                                 .pop();
                                              //                           },
                                              //                           icon:
                                              //                               const Icon(
                                              //                             Icons
                                              //                                 .close_rounded,
                                              //                           ),
                                              //                         ),
                                              //                       ],
                                              //                     ),
                                              //                   ),
                                              //                 );
                                              //               },
                                              //             );
                                              // for (M3uEntry m3u
                                              //     in searchData[i]
                                              //         .data) {
                                              //   await m3u
                                              //       .addToFavorites(
                                              //           refId!);
                                              // }
                                              //           } else {
                                              // for (M3uEntry m3u
                                              //     in searchData[i]
                                              //         .data) {
                                              //   await m3u
                                              //       .removeFromFavorites(
                                              //           refId!);
                                              // }
                                              //           }
                                              //           await fetchFav();
                                              //         },
                                              //         color: Colors.transparent,
                                              //         elevation: 0,
                                              //         height: 40,
                                              //         child: Icon(
                                              //           isFavorite
                                              //               ? Icons.favorite
                                              //               : Icons
                                              //                   .favorite_border,
                                              //           color: isFavorite
                                              //               ? Colors.red
                                              //               : Colors.white,
                                              //           size: 20,
                                              //         ),
                                              //       )),
                                              // ),
                                            ],
                                          ),
                                        );
                                      })
                              //  ListView.separated(
                              //     shrinkWrap: true,
                              //     // controller: _scrollController,
                              //     itemCount: searchData.length,
                              //     itemBuilder: (c, x) {
                              //       return ListTile(
                              // onTap: () async {
                              //   String result1 = searchData[x]
                              //       .name
                              //       .replaceAll(
                              //           RegExp(
                              //               r"[(]+[a-zA-Z]+[)]|[|]\s+[0-9]+\s[|]"),
                              //           '');
                              //   String result2 = result1.replaceAll(
                              //       RegExp(
                              //           r"[|]+[a-zA-Z]+[|]|[a-zA-Z]+[|] "),
                              //       '');

                              //   Navigator.push(
                              //     context,
                              //     PageTransition(
                              //       child: SeriesDetailsPage(
                              //         data: searchData[x],
                              //         title: result2,
                              //       ),
                              //       type: PageTransitionType
                              //           .rightToLeft,
                              //     ),
                              //   );
                              //         },
                              //         contentPadding:
                              //             const EdgeInsets.symmetric(
                              //                 horizontal: 15),
                              //         leading: ClipRRect(
                              //           borderRadius:
                              //               BorderRadius.circular(5),
                              //           child: SizedBox(
                              //             width: 85,
                              //             child: NetworkImageViewer(
                              //               url: searchData[x]
                              //                   .data[0]
                              //                   .attributes['tvg-logo']!,
                              //               width: 85,
                              //               height: 70,
                              //               fit: BoxFit.cover,
                              //               color: highlight,
                              //             ),
                              //           ),
                              //         ),
                              //         title: Hero(
                              //           tag: searchData[x]
                              //               .name
                              //               .toUpperCase(),
                              //           child: Material(
                              //             color: Colors.transparent,
                              //             elevation: 0,
                              //             child: Text(searchData[x].name),
                              //           ),
                              //         ),
                              // subtitle: Row(
                              //   children: [
                              //     Text(
                              //         "${searchData[x].data.length} "),
                              //     Text("Episodes".tr()),
                              //   ],
                              // ),
                              //       );
                              //     },
                              //     separatorBuilder: (_, __) =>
                              //         const SizedBox(width: 10),
                              //   )
                              // : ListView.separated(
                              //     shrinkWrap: true,
                              //     controller: _scrollController,
                              //     itemCount: seriesData.length,
                              //     itemBuilder: (c, x) {
                              //       final ClassifiedData d = seriesData[x];

                              //       return ListTile(
                              //         onTap: () async {
                              //           String result1 = d.name.replaceAll(
                              //               RegExp(
                              //                   r"[(]+[a-zA-Z]+[)]|[|]\s+[0-9]+\s[|]"),
                              //               '');
                              //           String result2 = result1.replaceAll(
                              //               RegExp(
                              //                   r"[|]+[a-zA-Z]+[|]|[a-zA-Z]+[|] "),
                              //               '');

                              //           Navigator.push(
                              //             context,
                              //             PageTransition(
                              //               child: SeriesDetailsPage(
                              //                 data: d,
                              //                 title: result2,
                              //               ),
                              //               type: PageTransitionType
                              //                   .rightToLeft,
                              //             ),
                              //           );
                              //         },
                              //         contentPadding:
                              //             const EdgeInsets.symmetric(
                              //                 horizontal: 15),
                              //         leading: ClipRRect(
                              //           borderRadius:
                              //               BorderRadius.circular(5),
                              //           child: SizedBox(
                              //             width: 85,
                              //             child: NetworkImageViewer(
                              //               url: d.data[0]
                              //                   .attributes['tvg-logo']!,
                              //               width: 85,
                              //               height: 70,
                              //               fit: BoxFit.cover,
                              //               color: highlight,
                              //             ),
                              //           ),
                              //         ),
                              //         title: Hero(
                              //           tag: d.name.toUpperCase(),
                              //           child: Material(
                              //             color: Colors.transparent,
                              //             elevation: 0,
                              //             child: Text(d.name),
                              //           ),
                              //         ),
                              //         subtitle: Row(
                              //           children: [
                              //             Text("${d.data.length} "),
                              //             Text("Episodes".tr()),
                              //           ],
                              //         ),
                              //       );
                              //     },
                              //     separatorBuilder: (_, __) =>
                              //         const SizedBox(width: 10),
                              //   )
                              : ind == 1
                                  ? const FavSeriesPage()
                                  : const HistorySeriesPage(),
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
