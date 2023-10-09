// ignore_for_file: deprecated_member_use, unnecessary_null_comparison, avoid_print

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:page_transition/page_transition.dart';
import 'package:seizhtv/extensions/color.dart';
import 'package:seizhtv/extensions/state.dart';
import 'package:seizhtv/views/landing_page/children/movie_children/fav_movie.dart';
import 'package:seizhtv/views/landing_page/children/movie_children/his_movie.dart';
import 'package:z_m3u_handler/z_m3u_handler.dart';
import '../../../data_containers/loaded_m3u_data.dart';
import '../../../globals/loader.dart';
import '../../../globals/network_image_viewer.dart';
import '../../../globals/palette.dart';
import '../../../globals/ui_additional.dart';
import '../../../globals/video_loader.dart';
import '../../../globals/video_player.dart';
import '../../../models/get_video.dart';
import '../../../models/topmovie.dart';
import '../../../services/movie_api.dart';
import '../../../viewmodel/movie_vm.dart';
import '../../../viewmodel/video_vm.dart';
import 'movie_children/details.dart';

class Movie1Page extends StatefulWidget {
  const Movie1Page({super.key});

  @override
  State<Movie1Page> createState() => _Movie1PageState();
}

class _Movie1PageState extends State<Movie1Page>
    with ColorPalette, UIAdditional, VideoLoader, MovieAPI {
  static final TopRatedMovieViewModel _viewModel =
      TopRatedMovieViewModel.instance;
  static final MovieVideoViewModel _videoViewModel =
      MovieVideoViewModel.instance;
  final LoadedM3uData _vm = LoadedM3uData.instance;
  late final ScrollController _scrollController;
  late final TextEditingController _search;
  late List<ClassifiedData>? _data;
  late List<M3uEntry> m3uData;
  late List<M3uEntry> datas;
  List<M3uEntry>? searchData;
  List<M3uEntry>? movieData;
  bool showSearchField = false;
  bool update = false;
  int ind = 0;

  List<String> category = [
    "All ",
    "favorites".tr(),
    "Movies History",
  ];

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
  void initState() {
    initStream();
    _scrollController = ScrollController();
    _search = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _search.dispose();
    super.dispose();
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
                  height: size.height * .08,
                  // 50,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) => GestureDetector(
                      onTap: () {
                        setState(() {
                          ind = index;
                        });
                      },
                      child: Chip(
                        backgroundColor: ColorPalette().highlight,
                        padding: const EdgeInsets.all(10),
                        label: Text("${category[index]}"
                            "${index == 0 ? movieData == null ? "" : "(${movieData!.length})" : ""}"),
                      ),
                    ),
                    itemCount: category.length,
                    separatorBuilder: (BuildContext context, int index) {
                      return const SizedBox(width: 10);
                    },
                  ),
                ),
                const SizedBox(height: 15),
                AnimatedPadding(
                  duration: const Duration(milliseconds: 100),
                  padding: EdgeInsets.symmetric(
                      horizontal: showSearchField ? 20 : 0),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 10),
                    height: showSearchField ? size.height * .08 : 0,
                    // 50
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
                                    blurRadius: 2)
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
                  const SizedBox(
                    height: 10,
                  ),
                },
                Column(
                  children: [
                    Container(
                      color: Colors.red,
                      height: 200,
                    ),
                    searchData == null
                        ? SeizhTvLoader(
                            label: Text(
                              "Retrieving_data".tr(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          )
                        : ind == 0
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
                                : ListView(
                                    children: [
                                      Container(
                                        child:
                                            StreamBuilder<List<TopMovieModel>>(
                                                stream: _viewModel.stream,
                                                builder: (context, snapshot) {
                                                  if (snapshot.hasData &&
                                                      !snapshot.hasError) {
                                                    if (snapshot
                                                        .data!.isNotEmpty) {
                                                      final List<TopMovieModel>
                                                          result =
                                                          snapshot.data!;

                                                      for (final M3uEntry movdata
                                                          in searchData!) {
                                                        for (final TopMovieModel toprated
                                                            in result) {
                                                          if (movdata.title ==
                                                              toprated.title) {
                                                            print("mayda");
                                                            print(
                                                                "MOVIE DATA: $movdata");
                                                            print(
                                                                "TOP RATED MOVIE: ${toprated.id}");

                                                            getMovieVideos(
                                                                id: toprated
                                                                    .id);

                                                            return SizedBox(
                                                              width: size.width,
                                                              child: Column(
                                                                children: [
                                                                  StreamBuilder<
                                                                      List<
                                                                          Video>>(
                                                                    stream: _videoViewModel
                                                                        .stream,
                                                                    builder:
                                                                        (context,
                                                                            snapshot) {
                                                                      if (snapshot
                                                                              .hasData &&
                                                                          !snapshot
                                                                              .hasError) {
                                                                        if (snapshot
                                                                            .data!
                                                                            .isNotEmpty) {
                                                                          final List<Video>
                                                                              result =
                                                                              snapshot.data!;
                                                                          return Videoplayer(
                                                                            url:
                                                                                result[0].key,
                                                                          );
                                                                        }
                                                                      }
                                                                      return const Center(
                                                                        child:
                                                                            CircularProgressIndicator(
                                                                          color:
                                                                              Colors.grey,
                                                                        ),
                                                                      );
                                                                    },
                                                                  ),
                                                                  MaterialButton(
                                                                    elevation:
                                                                        0,
                                                                    color: Colors
                                                                        .transparent,
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(0),
                                                                    onPressed:
                                                                        () {
                                                                      Navigator
                                                                          .push(
                                                                        context,
                                                                        PageTransition(
                                                                          child:
                                                                              MovieDetailsPage(
                                                                            data:
                                                                                movdata,
                                                                            title:
                                                                                toprated.title,
                                                                          ),
                                                                          type:
                                                                              PageTransitionType.leftToRight,
                                                                        ),
                                                                      );
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      width: size
                                                                          .width,
                                                                      padding: const EdgeInsets
                                                                              .symmetric(
                                                                          horizontal:
                                                                              20,
                                                                          vertical:
                                                                              15),
                                                                      child:
                                                                          Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          Text(
                                                                            toprated.title,
                                                                            maxLines:
                                                                                2,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                            style:
                                                                                const TextStyle(
                                                                              fontWeight: FontWeight.w500,
                                                                              fontSize: 22,
                                                                              height: 1.1,
                                                                            ),
                                                                          ),
                                                                          Row(
                                                                            children: [
                                                                              Text(DateFormat('MMM dd, yyyy').format(toprated.date!)),
                                                                              const SizedBox(width: 10),
                                                                              Container(
                                                                                padding: const EdgeInsets.symmetric(horizontal: 5),
                                                                                decoration: BoxDecoration(
                                                                                  border: Border.all(color: Colors.white),
                                                                                  borderRadius: const BorderRadius.all(
                                                                                    Radius.circular(5),
                                                                                  ),
                                                                                ),
                                                                                child: Text("${toprated.voteAverage}"),
                                                                              ),
                                                                              const SizedBox(width: 15),
                                                                              SizedBox(
                                                                                height: 25,
                                                                                width: 30,
                                                                                child: MaterialButton(
                                                                                  color: Colors.grey,
                                                                                  padding: const EdgeInsets.all(0),
                                                                                  onPressed: () {},
                                                                                  child: const Text(
                                                                                    "HD",
                                                                                    style: TextStyle(fontWeight: FontWeight.w600),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            );
                                                          } else {
                                                            Center(
                                                              child: Text(
                                                                "No_data_available"
                                                                    .tr(),
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                              ),
                                                            );
                                                          }
                                                        }
                                                      }
                                                    }
                                                    return const Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                        color: Colors.grey,
                                                      ),
                                                    );
                                                  }
                                                  return Center(
                                                    child: Text(
                                                      "No_data_available".tr(),
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  );
                                                }),
                                      ),
                                      GridView.count(
                                        shrinkWrap: true,
                                        controller: _scrollController,
                                        mainAxisSpacing: 10,
                                        crossAxisSpacing: 10,
                                        crossAxisCount: 3,
                                        childAspectRatio: .6,
                                        padding: const EdgeInsets.all(20),
                                        children: List.generate(
                                          searchData!.length,
                                          (i) {
                                            final M3uEntry d = searchData![i];

                                            return GestureDetector(
                                              onTap: () async {
                                                Navigator.push(
                                                  context,
                                                  PageTransition(
                                                    child: MovieDetailsPage(
                                                      data: d,
                                                      title: d.title,
                                                    ),
                                                    type: PageTransitionType
                                                        .rightToLeft,
                                                  ),
                                                );
                                              },
                                              child: LayoutBuilder(
                                                builder: (context, c) {
                                                  final double w = c.maxWidth;
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
                                                          height: 110,
                                                          fit: BoxFit.fitWidth,
                                                          color: highlight,
                                                        ),
                                                        const SizedBox(
                                                            height: 5),
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
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  )
                            : Container()
                    // : ind == 1
                    //     ? const FaveMoviePage()
                    //     : const HistoryMoviePage(),
                  ],
                )
              ],
            ),
            update == true ? loader() : Container()
          ],
        ),
      ),
    );
  }
}

//   child: ind == 0
//       ? Column(
//         children: [
//           StreamBuilder<List<TopMovieModel>>(
// stream: _viewModel.stream,
// builder: (context, snapshot) {
//   if (snapshot.hasData && !snapshot.hasError) {
//     if (snapshot.data!.isNotEmpty) {
//           final List<TopMovieModel> result = snapshot.data!;

//           for (final M3uEntry movdata in searchData!) {
//             for (final TopMovieModel toprated in result) {
//               if (movdata.title == toprated.title) {
//                 print("mayda");
//                 print("MOVIE DATA: $movdata");
//                 print("TOP RATED MOVIE: ${toprated.id}");

//                 getMovieVideos(id: toprated.id);

//                 return SizedBox(
//                   width: size.width,
//                   child: Column(
//                     children: [
//                       StreamBuilder<List<Video>>(
//                         stream: _videoViewModel.stream,
//                         builder: (context, snapshot) {
//                           if (snapshot.hasData &&
//                               !snapshot.hasError) {
//                             if (snapshot.data!.isNotEmpty) {
//                               final List<Video> result =
//                                   snapshot.data!;
//                               return Videoplayer(
//                                 url: result[0].key,
//                               );
//                             }
//                           }
//                           return const Center(
//                             child:
//                                 CircularProgressIndicator(
//                               color: Colors.grey,
//                             ),
//                           );
//                         },
//                       ),
//                       MaterialButton(
//                         elevation: 0,
//                         color: Colors.transparent,
//                         padding: const EdgeInsets.all(0),
//                         onPressed: () {
//                           Navigator.push(
//                             context,
//                             PageTransition(
//                               child: MovieDetailsPage(
//                                 data: movdata,
//                                 title: toprated.title,
//                               ),
//                               type: PageTransitionType
//                                   .leftToRight,
//                             ),
//                           );
//                         },
//                         child: Container(
//                           width: size.width,
//                           padding:
//                               const EdgeInsets.symmetric(
//                                   horizontal: 20,
//                                   vertical: 15),
//                           child: Column(
//                             crossAxisAlignment:
//                                 CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 toprated.title,
//                                 maxLines: 2,
//                                 overflow:
//                                     TextOverflow.ellipsis,
//                                 style: const TextStyle(
//                                   fontWeight:
//                                       FontWeight.w500,
//                                   fontSize: 22,
//                                   height: 1.1,
//                                 ),
//                               ),
//                               Row(
//                                 children: [
//                                   Text(DateFormat(
//                                           'MMM dd, yyyy')
//                                       .format(
//                                           toprated.date!)),
//                                   const SizedBox(width: 10),
//                                   Container(
//                                     padding:
//                                         const EdgeInsets
//                                                 .symmetric(
//                                             horizontal: 5),
//                                     decoration:
//                                         BoxDecoration(
//                                       border: Border.all(
//                                           color:
//                                               Colors.white),
//                                       borderRadius:
//                                           const BorderRadius
//                                               .all(
//                                         Radius.circular(5),
//                                       ),
//                                     ),
//                                     child: Text(
//                                         "${toprated.voteAverage}"),
//                                   ),
//                                   const SizedBox(width: 15),
//                                   SizedBox(
//                                     height: 25,
//                                     width: 30,
//                                     child: MaterialButton(
//                                       color: Colors.grey,
//                                       padding:
//                                           const EdgeInsets
//                                               .all(0),
//                                       onPressed: () {},
//                                       child: const Text(
//                                         "HD",
//                                         style: TextStyle(
//                                             fontWeight:
//                                                 FontWeight
//                                                     .w600),
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               } else {
//                 Center(
//                   child: Text(
//                     "No_data_available".tr(),
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 );
//               }
//             }
//           }
//     }
//     return const Center(
//           child: CircularProgressIndicator(
//             color: Colors.grey,
//           ),
//     );
//   }
//   return Center(
//     child: Text(
//           "No_data_available".tr(),
//           style: const TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w500,
//           ),
//     ),
//   );
// }),
// Container(color: Colors.red,height: 200,)
//         ],
// ): searchData!.isEmpty
//     ? Expanded(
//         child: Center(
//           child: Text(
//             "No Result Found for `${_search.text}`",
//             style: TextStyle(
//               color: Colors.white.withOpacity(.5),
//             ),
//           ),
//         ),
//       )
// : GridView.count(
//     shrinkWrap: true,
//     controller: _scrollController,
//     mainAxisSpacing: 10,
//     crossAxisSpacing: 10,
//     crossAxisCount: 3,
//     childAspectRatio: .6,
//     padding: const EdgeInsets.all(20),
//     children: List.generate(
//       searchData!.length,
//       (i) {
//         final M3uEntry d = searchData![i];

//         return GestureDetector(
//           onTap: () async {
//             Navigator.push(
//               context,
//               PageTransition(
//                 child: MovieDetailsPage(
//                   data: d,
//                   title: d.title,
//                 ),
//                 type: PageTransitionType
//                     .rightToLeft,
//               ),
//             );
//           },
//           child: LayoutBuilder(
//             builder: (context, c) {
//               final double w = c.maxWidth;
//               return Tooltip(
//                 message: d.title,
//                 child: Column(
//                   crossAxisAlignment:
//                       CrossAxisAlignment
//                           .start,
//                   children: [
//                     NetworkImageViewer(
//                       url: d.attributes[
//                           'tvg-logo'],
//                       width: w,
//                       height: 110,
//                       fit: BoxFit.fitWidth,
//                       color: highlight,
//                     ),
//                     const SizedBox(height: 5),
//                     Tooltip(
//                       message: d.title,
//                       child: Text(
//                         d.title,
//                         style:
//                             const TextStyle(
//                                 fontSize: 12),
//                         maxLines: 2,
//                         overflow: TextOverflow
//                             .ellipsis,
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         );
//       },
//     ),
//   )



          