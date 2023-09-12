// ignore_for_file: avoid_print, deprecated_member_use, unnecessary_null_comparison

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:page_transition/page_transition.dart';
import 'package:seizhtv/extensions/color.dart';
import 'package:seizhtv/extensions/m3u_entry.dart';
import 'package:seizhtv/extensions/state.dart';
import 'package:z_m3u_handler/z_m3u_handler.dart';
import '../../data_containers/favorites.dart';
import '../../data_containers/loaded_m3u_data.dart';
import '../../globals/data.dart';
import '../../globals/favorite_button.dart';
import '../../globals/loader.dart';
import '../../globals/network_image_viewer.dart';
import '../../globals/palette.dart';
import '../../globals/ui_additional.dart';
import '../../globals/video_loader.dart';
import '../../globals/video_player.dart';
import '../../models/get_video.dart';
import '../../models/topmovie.dart';
import '../../services/movie_api.dart';
import '../../viewmodel/movie_vm.dart';
import '../../viewmodel/video_vm.dart';
import 'children/movie_children/details.dart';
import 'children/movie_children/fav_movie.dart';
import 'children/movie_children/his_movie.dart';

class MoviePage extends StatefulWidget {
  const MoviePage({super.key});

  @override
  State<MoviePage> createState() => _MoviePageState();
}

class _MoviePageState extends State<MoviePage>
    with ColorPalette, UIAdditional, VideoLoader, MovieAPI {
  static final TopRatedMovieViewModel _viewModel =
      TopRatedMovieViewModel.instance;
  static final MovieVideoViewModel _videoViewModel =
      MovieVideoViewModel.instance;
  static final ZM3UHandler _handler = ZM3UHandler.instance;
  final LoadedM3uData _vm = LoadedM3uData.instance;
  late final ScrollController _scrollController;
  final Favorites _vm1 = Favorites.instance;
  late final TextEditingController _search;
  late List<ClassifiedData>? _data;
  bool showSearchField = false;
  late List<M3uEntry> m3uData;
  List<M3uEntry>? searchData;
  late List<M3uEntry> datas;
  List<M3uEntry>? movieData;
  bool selectedIndex = false;
  bool update = false;
  int ind = 0;

  fetchFav() async {
    await _handler
        .getDataFrom(type: CollectionType.favorites, refId: refId!)
        .then((value) {
      if (value != null) {
        _vm1.populate(value);
      }
    });
  }

  @override
  void initState() {
    _scrollController = ScrollController();
    _search = TextEditingController();
    super.initState();
    initStream();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _search.dispose();
    super.dispose();
  }

  initStream() {
    _vm.stream.listen((event) {
      _data = List.from(event.movies);

      m3uData = List.from(_data!.expand((element) => element.data));
      datas = List.from(m3uData);
      // datas.sort((a, b) => a.title.compareTo(b.title));
      searchData = List.from(datas);
      movieData = List.from(datas);
      if (mounted) setState(() {});
    });
  }

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
          child: appbar(
            2,
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
                      "All (${movieData == null ? "" : movieData!.length})",
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
                                              searchData = List.from(datas);
                                            } else {
                                              searchData = List.from(datas
                                                  .where((element) => element
                                                      .title
                                                      .toLowerCase()
                                                      .contains(
                                                          text.toLowerCase())));
                                            }
                                            // searchData!.sort((a, b) =>
                                            //     a.title.compareTo(b.title));
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
                              searchData = List.from(datas);
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
                  child: searchData == null
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
                              ? searchData!.isEmpty
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
                                        mainAxisExtent: 150,
                                      ),
                                      itemCount: searchData!.length,
                                      itemBuilder: (context, i) {
                                        final M3uEntry d = searchData![i];

                                        return GestureDetector(
                                          onTap: () async {
                                            String result1 = d.title.replaceAll(
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
                                                child: MovieDetailsPage(
                                                  data: d,
                                                  title: result2,
                                                ),
                                                type: PageTransitionType
                                                    .rightToLeft,
                                              ),
                                            );
                                          },
                                          child: Container(
                                            margin: const EdgeInsets.all(5),
                                            child: Stack(
                                              children: [
                                                Container(
                                                  margin: const EdgeInsets.only(
                                                      top: 10, right: 10),
                                                  child: LayoutBuilder(
                                                    builder: (context, c) {
                                                      final double w =
                                                          c.maxWidth;
                                                      return Tooltip(
                                                        message: d.title,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            NetworkImageViewer(
                                                              url: d.attributes[
                                                                  'tvg-logo'],
                                                              width: w,
                                                              height: 90,
                                                              fit: BoxFit.cover,
                                                              color: highlight,
                                                            ),
                                                            const SizedBox(
                                                                height: 3),
                                                            Tooltip(
                                                              message: d.title,
                                                              child: Text(
                                                                d.title,
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
                                                      onPressedCallback:
                                                          (bool f) async {
                                                        if (f) {
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
                                                                    .pop(true);
                                                              });
                                                              return Dialog(
                                                                alignment:
                                                                    Alignment
                                                                        .topCenter,
                                                                shape:
                                                                    RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10),
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
                                                                          Navigator.of(context)
                                                                              .pop();
                                                                        },
                                                                        icon: const Icon(
                                                                            Icons.close_rounded),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                          );
                                                          await d
                                                              .addToFavorites(
                                                                  refId!);
                                                        } else {
                                                          await d
                                                              .removeFromFavorites(
                                                                  refId!);
                                                        }
                                                        await fetchFav();
                                                      },
                                                      initValue:
                                                          d.existsInFavorites(
                                                              "movie"),
                                                      iconSize: 20,
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    )
                              : ind == 1
                                  ? const FaveMoviePage()
                                  : const HistoryMoviePage(),
                        ),
                ),
              ],
            ),
            update == true ? loader() : Container()
          ],
        ),
        // body: Column(
        //   children: [
        //     Container(
        //       padding: const EdgeInsets.symmetric(horizontal: 20),
        //       height: 50,
        //       child: UIAdditional().filterChip(
        //         chipsLabel: [
        //           "All (${movieData == null ? "" : movieData!.length})",
        //           "favorites".tr(),
        //           "Channels_History".tr(),
        //         ],
        //         onPressed: (index) {
        //           setState(() {
        //             ind = index;
        //           });
        //         },
        //         si: ind,
        //       ),
        //     ),
        //     const SizedBox(height: 10),
        //     SizedBox(
        //       child: AnimatedPadding(
        //         duration: const Duration(milliseconds: 10),
        //         padding:
        //             EdgeInsets.symmetric(horizontal: showSearchField ? 20 : 0),
        //         child: AnimatedContainer(
        //           duration: const Duration(milliseconds: 10),
        //           height: showSearchField ? size.height * .08 : 0,
        //           width: double.maxFinite,
        //           child: Row(
        //             children: [
        //               Expanded(
        //                   child: Container(
        //                 height: 50,
        //                 padding: const EdgeInsets.symmetric(horizontal: 10),
        //                 decoration: BoxDecoration(
        //                     color: highlight,
        //                     borderRadius: BorderRadius.circular(10),
        //                     boxShadow: [
        //                       BoxShadow(
        //                           color: highlight.darken().withOpacity(1),
        //                           offset: const Offset(2, 2),
        //                           blurRadius: 2)
        //                     ]),
        //                 child: Row(
        //                   children: [
        //                     SvgPicture.asset(
        //                       "assets/icons/search.svg",
        //                       height: 20,
        //                       width: 20,
        //                       color: white,
        //                     ),
        //                     const SizedBox(width: 10),
        //                     Expanded(
        //                       child: AnimatedSwitcher(
        //                         duration: const Duration(milliseconds: 300),
        //                         child: showSearchField
        //                             ? TextField(
        //                                 onChanged: (text) {
        //                                   if (text.isEmpty) {
        //                                     searchData = List.from(datas);
        //                                   } else {
        //                                     searchData = List.from(datas.where(
        //                                         (element) => element.title
        //                                             .toLowerCase()
        //                                             .contains(
        //                                                 text.toLowerCase())));
        //                                   }
        //                                   // searchData!.sort((a, b) =>
        //                                   //     a.title.compareTo(b.title));
        //                                   if (mounted) setState(() {});
        //                                 },
        //                                 cursorColor: orange,
        //                                 controller: _search,
        //                                 decoration: InputDecoration(
        //                                   hintText: "Search".tr(),
        //                                 ),
        //                               )
        //                             : Container(),
        //                       ),
        //                     ),
        //                   ],
        //                 ),
        //               )),
        //               const SizedBox(width: 10),
        //               GestureDetector(
        //                 onTap: () {
        //                   setState(() {
        //                     _search.clear();
        //                     searchData = List.from(datas);
        //                     showSearchField = !showSearchField;
        //                   });
        //                 },
        //                 child: Text(
        //                   "Cancel".tr(),
        //                   style: const TextStyle(color: Colors.white),
        //                 ),
        //               ),
        //             ],
        //           ),
        //         ),
        //       ),
        //     ),
        //     Expanded(
        //       child: searchData == null
        //           ? SeizhTvLoader(
        //               label: Text(
        //                 "Retrieving_data".tr(),
        //                 style: const TextStyle(
        //                   color: Colors.white,
        //                   fontSize: 16,
        //                 ),
        //               ),
        //             )
        //           : Stack(
        //               children: [
        //                 if (showSearchField) ...{
        //                   const SizedBox(height: 10),
        //                 },
        //                 showSearchField
        // ? GridView.builder(
        //     shrinkWrap: true,
        //     controller: _scrollController,
        //     padding:
        //         const EdgeInsets.symmetric(horizontal: 20),
        //     gridDelegate:
        //         const SliverGridDelegateWithFixedCrossAxisCount(
        //       crossAxisCount: 3,
        //       mainAxisExtent: 150,
        //     ),
        //     itemCount: searchData!.length,
        //     itemBuilder: (context, i) {
        //       final M3uEntry d = searchData![i];

        //       return GestureDetector(
        //         onTap: () async {
        //           String result1 = d.title.replaceAll(
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
        //               child: MovieDetailsPage(
        //                 data: d,
        //                 title: result2,
        //               ),
        //               type: PageTransitionType.rightToLeft,
        //             ),
        //           );
        //         },
        //         child: Container(
        //           margin: const EdgeInsets.all(5),
        //           child: Stack(
        //             children: [
        //               Container(
        //                 margin: const EdgeInsets.only(
        //                     top: 10, right: 10),
        //                 child: LayoutBuilder(
        //                   builder: (context, c) {
        //                     final double w = c.maxWidth;
        //                     return Tooltip(
        //                       message: d.title,
        //                       child: Column(
        //                         crossAxisAlignment:
        //                             CrossAxisAlignment
        //                                 .start,
        //                         children: [
        //                           NetworkImageViewer(
        //                             url: d.attributes[
        //                                 'tvg-logo'],
        //                             width: w,
        //                             height: 90,
        //                             fit: BoxFit.cover,
        //                             color: highlight,
        //                           ),
        //                           const SizedBox(height: 3),
        //                           Tooltip(
        //                             message: d.title,
        //                             child: Text(
        //                               d.title,
        //                               style:
        //                                   const TextStyle(
        //                                       fontSize: 12),
        //                               maxLines: 2,
        //                               overflow: TextOverflow
        //                                   .ellipsis,
        //                             ),
        //                           ),
        //                         ],
        //                       ),
        //                     );
        //                   },
        //                 ),
        //               ),
        //               Positioned(
        //                 top: 0,
        //                 right: 0,
        //                 child: SizedBox(
        //                   height: 25,
        //                   width: 25,
        //                   child: FavoriteIconButton(
        //                     onPressedCallback:
        //                         (bool f) async {
        //                       if (f) {
        //                         showDialog(
        //                           barrierDismissible: false,
        //                           context: context,
        //                           builder: (BuildContext
        //                               context) {
        //                             Future.delayed(
        //                                 const Duration(
        //                                     seconds: 3),
        //                                 () {
        //                               Navigator.of(context)
        //                                   .pop(true);
        //                             });
        //                             return Dialog(
        //                               alignment: Alignment
        //                                   .topCenter,
        //                               shape:
        //                                   RoundedRectangleBorder(
        //                                 borderRadius:
        //                                     BorderRadius
        //                                         .circular(
        //                                             10),
        //                               ),
        //                               child: Container(
        //                                 padding:
        //                                     const EdgeInsets
        //                                             .symmetric(
        //                                         horizontal:
        //                                             20),
        //                                 child: Row(
        //                                   mainAxisAlignment:
        //                                       MainAxisAlignment
        //                                           .spaceBetween,
        //                                   children: [
        //                                     Text(
        //                                       "Added_to_Favorites"
        //                                           .tr(),
        //                                       style:
        //                                           const TextStyle(
        //                                         fontSize:
        //                                             16,
        //                                       ),
        //                                     ),
        //                                     IconButton(
        //                                       padding:
        //                                           const EdgeInsets
        //                                               .all(0),
        //                                       onPressed:
        //                                           () {
        //                                         Navigator.of(
        //                                                 context)
        //                                             .pop();
        //                                       },
        //                                       icon: const Icon(
        //                                           Icons
        //                                               .close_rounded),
        //                                     ),
        //                                   ],
        //                                 ),
        //                               ),
        //                             );
        //                           },
        //                         );
        //                         await d
        //                             .addToFavorites(refId!);
        //                       } else {
        //                         await d.removeFromFavorites(
        //                             refId!);
        //                       }
        //                       await fetchFav();
        //                     },
        //                     initValue: d
        //                         .existsInFavorites("movie"),
        //                     iconSize: 20,
        //                   ),
        //                 ),
        //               )
        //             ],
        //           ),
        //         ),
        //       );
        //     },
        //   )
        //                     : Container(
        //                         color: Colors.red,
        //                         padding:
        //                             const EdgeInsets.symmetric(horizontal: 20),
        //                         child: SingleChildScrollView(
        //                           child: Column(
        //                             children: [
        //                               Container(
        //                                 color: Colors.green,
        //                                 height: 300,
        //                               ),
        //                               GridView.builder(
        //                                   shrinkWrap: true,
        //                                   physics: const ScrollPhysics(),
        //                                   gridDelegate:
        //                                       const SliverGridDelegateWithFixedCrossAxisCount(
        //                                     crossAxisCount: 3,
        //                                     mainAxisExtent: 150,
        //                                   ),
        //                                   itemCount: movieData!.length,
        //                                   itemBuilder: (context, i) {
        //                                     final M3uEntry d = movieData![i];

        //                                     return GestureDetector(
        //                                       onTap: () async {
        //                                         String result1 = d.title.replaceAll(
        //                                             RegExp(
        //                                                 r"[(]+[a-zA-Z]+[)]|[|]\s+[0-9]+\s[|]"),
        //                                             '');
        //                                         String result2 = result1.replaceAll(
        //                                             RegExp(
        //                                                 r"[|]+[a-zA-Z]+[|]|[a-zA-Z]+[|] "),
        //                                             '');

        //                                         Navigator.push(
        //                                           context,
        //                                           PageTransition(
        //                                             child: MovieDetailsPage(
        //                                               data: d,
        //                                               title: result2,
        //                                             ),
        //                                             type: PageTransitionType
        //                                                 .rightToLeft,
        //                                           ),
        //                                         );
        //                                       },
        //                                       child: Container(
        //                                         margin: const EdgeInsets.all(5),
        //                                         child: Stack(
        //                                           children: [
        //                                             Container(
        //                                               margin:
        //                                                   const EdgeInsets.only(
        //                                                       top: 10,
        //                                                       right: 10),
        //                                               child: LayoutBuilder(
        //                                                 builder: (context, c) {
        //                                                   final double w =
        //                                                       c.maxWidth;
        //                                                   return Tooltip(
        //                                                     message: d.title,
        //                                                     child: Column(
        //                                                       crossAxisAlignment:
        //                                                           CrossAxisAlignment
        //                                                               .start,
        //                                                       children: [
        //                                                         NetworkImageViewer(
        //                                                           url: d.attributes[
        //                                                               'tvg-logo'],
        //                                                           width: w,
        //                                                           height: 90,
        //                                                           fit: BoxFit
        //                                                               .cover,
        //                                                           color:
        //                                                               highlight,
        //                                                         ),
        //                                                         const SizedBox(
        //                                                             height: 3),
        //                                                         Tooltip(
        //                                                           message:
        //                                                               d.title,
        //                                                           child: Text(
        //                                                             d.title,
        //                                                             style: const TextStyle(
        //                                                                 fontSize:
        //                                                                     12),
        //                                                             maxLines: 2,
        //                                                             overflow:
        //                                                                 TextOverflow
        //                                                                     .ellipsis,
        //                                                           ),
        //                                                         ),
        //                                                       ],
        //                                                     ),
        //                                                   );
        //                                                 },
        //                                               ),
        //                                             ),
        //                                             Positioned(
        //                                               top: 0,
        //                                               right: 0,
        //                                               child: SizedBox(
        //                                                 height: 25,
        //                                                 width: 25,
        //                                                 child:
        //                                                     FavoriteIconButton(
        //                                                   onPressedCallback:
        //                                                       (bool f) async {
        //                                                     if (f) {
        //                                                       showDialog(
        //                                                         barrierDismissible:
        //                                                             false,
        //                                                         context:
        //                                                             context,
        //                                                         builder:
        //                                                             (BuildContext
        //                                                                 context) {
        //                                                           Future.delayed(
        //                                                               const Duration(
        //                                                                   seconds:
        //                                                                       3),
        //                                                               () {
        //                                                             Navigator.of(
        //                                                                     context)
        //                                                                 .pop(
        //                                                                     true);
        //                                                           });
        //                                                           return Dialog(
        //                                                             alignment:
        //                                                                 Alignment
        //                                                                     .topCenter,
        //                                                             shape:
        //                                                                 RoundedRectangleBorder(
        //                                                               borderRadius:
        //                                                                   BorderRadius.circular(
        //                                                                       10),
        //                                                             ),
        //                                                             child:
        //                                                                 Container(
        //                                                               padding: const EdgeInsets
        //                                                                       .symmetric(
        //                                                                   horizontal:
        //                                                                       20),
        //                                                               child:
        //                                                                   Row(
        //                                                                 mainAxisAlignment:
        //                                                                     MainAxisAlignment.spaceBetween,
        //                                                                 children: [
        //                                                                   Text(
        //                                                                     "Added_to_Favorites".tr(),
        //                                                                     style:
        //                                                                         const TextStyle(
        //                                                                       fontSize: 16,
        //                                                                     ),
        //                                                                   ),
        //                                                                   IconButton(
        //                                                                     padding:
        //                                                                         const EdgeInsets.all(0),
        //                                                                     onPressed:
        //                                                                         () {
        //                                                                       Navigator.of(context).pop();
        //                                                                     },
        //                                                                     icon:
        //                                                                         const Icon(Icons.close_rounded),
        //                                                                   ),
        //                                                                 ],
        //                                                               ),
        //                                                             ),
        //                                                           );
        //                                                         },
        //                                                       );
        //                                                       await d
        //                                                           .addToFavorites(
        //                                                               refId!);
        //                                                     } else {
        //                                                       await d
        //                                                           .removeFromFavorites(
        //                                                               refId!);
        //                                                     }
        //                                                     await fetchFav();
        //                                                   },
        //                                                   initValue: d
        //                                                       .existsInFavorites(
        //                                                           "movie"),
        //                                                   iconSize: 20,
        //                                                 ),
        //                                               ),
        //                                             )
        //                                           ],
        //                                         ),
        //                                       ),
        //                                     );
        //                                   }),
        //                             ],
        //                           ),
        //                         ),
        //                       ),
        //                 update == true ? loader() : Container()
        //               ],
        //             ),
        //     )
        //   ],
        // ),
      ),
    );
  }
}
