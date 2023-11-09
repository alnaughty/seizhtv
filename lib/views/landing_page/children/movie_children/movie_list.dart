// ignore_for_file: must_be_immutable

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:page_transition/page_transition.dart';
import 'package:seizhtv/extensions/color.dart';
import 'package:seizhtv/extensions/m3u_entry.dart';
import 'package:z_m3u_handler/z_m3u_handler.dart';
import '../../../../data_containers/favorites.dart';
import '../../../../data_containers/loaded_m3u_data.dart';
import '../../../../globals/data.dart';
import '../../../../globals/favorite_button.dart';
import '../../../../globals/loader.dart';
import '../../../../globals/network_image_viewer.dart';
import '../../../../globals/palette.dart';
import '../../../../globals/video_player.dart';
import '../../../../models/get_video.dart';
import '../../../../models/topmovie.dart';
import '../../../../services/movie_api.dart';
import '../../../../viewmodel/movie_vm.dart';
import '../../../../viewmodel/video_vm.dart';
import 'details.dart';

class MovieListPage extends StatefulWidget {
  MovieListPage(
      {required this.controller,
      required this.data,
      this.showSearchField = false,
      super.key});
  final ScrollController controller;
  final List<M3uEntry> data;
  bool showSearchField;

  @override
  State<MovieListPage> createState() => MovieListPageState();
}

class MovieListPageState extends State<MovieListPage>
    with MovieAPI, ColorPalette {
  static final TopRatedMovieViewModel _viewModel =
      TopRatedMovieViewModel.instance;
  static final MovieVideoViewModel _videoViewModel =
      MovieVideoViewModel.instance;
  static final Favorites _vm = Favorites.instance;
  static final ZM3UHandler _handler = ZM3UHandler.instance;
  late final TextEditingController _search = TextEditingController();
  List<M3uEntry>? searchData;

  fetchFav() async {
    await _handler
        .getDataFrom(type: CollectionType.favorites, refId: refId!)
        .then((value) {
      if (value != null) {
        _vm.populate(value);
      }
    });
  }

  // fetchFav() async {
  //   await _handler
  //       .getDataFrom(type: CollectionType.favorites, refId: refId!)
  //       .then((value) {
  //     if (value != null) {
  //       _vm.populate(value);
  //       print("FAVV VALUEEEE: $value");
  //     }
  //   });
  // }

  @override
  void initState() {
    searchData = widget.data;
    super.initState();
  }

  final int startIndex = 0;
  late int endIndex = widget.data.length < 60 ? widget.data.length : 60;
  late List<M3uEntry> _displayData =
      List.from(widget.data.sublist(startIndex, endIndex));

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    if (widget.data.isEmpty) {
      return SeizhTvLoader(
        label: Text(
          "Retrieving_data".tr(),
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      );
    }

    return Column(
      children: [
        AnimatedPadding(
          duration: const Duration(milliseconds: 10),
          padding:
              EdgeInsets.symmetric(horizontal: widget.showSearchField ? 20 : 0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 10),
            height: widget.showSearchField ? size.height * .08 : 0,
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
                          child: widget.showSearchField
                              ? TextField(
                                  onChanged: (text) {
                                    if (text.isEmpty) {
                                      searchData = widget.data;
                                    } else {
                                      searchData = List.from(widget.data.where(
                                          (element) => element.title
                                              .toLowerCase()
                                              .contains(text.toLowerCase())));
                                    }
                                    searchData!.sort(
                                        (a, b) => a.title.compareTo(b.title));
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
                )),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _search.clear();
                      searchData = widget.data;
                      widget.showSearchField = !widget.showSearchField;
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
        if (widget.showSearchField) ...{
          const SizedBox(height: 15),
        },
        Expanded(
            child: widget.showSearchField
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
                        // controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3, mainAxisExtent: 155),
                        itemCount: searchData!.length,
                        itemBuilder: (context, i) {
                          final M3uEntry d = searchData![i];

                          return GestureDetector(
                            onTap: () async {
                              String result1 = d.title.replaceAll(
                                  RegExp(r"[(]+[a-zA-Z]+[)]|[|]\s+[0-9]+\s[|]"),
                                  '');
                              String result2 = result1.replaceAll(
                                  RegExp(r"[|]+[a-zA-Z]+[|]|[a-zA-Z]+[|] "),
                                  '');

                              Navigator.push(
                                context,
                                PageTransition(
                                  child:
                                      MovieDetailsPage(data: d, title: result2),
                                  type: PageTransitionType.rightToLeft,
                                ),
                              );
                            },
                            child: Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 1.5),
                              child: Stack(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(
                                        top: 10, right: 10),
                                    child: LayoutBuilder(
                                      builder: (context, c) {
                                        final double w = c.maxWidth;
                                        return Tooltip(
                                          message: d.title,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              NetworkImageViewer(
                                                url: d.attributes['tvg-logo'],
                                                width: w,
                                                height: 90,
                                                fit: BoxFit.cover,
                                                color: highlight,
                                              ),
                                              const SizedBox(height: 3),
                                              Tooltip(
                                                message: d.title,
                                                child: Text(
                                                  d.title,
                                                  style: const TextStyle(
                                                      fontSize: 12),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
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
                                        onPressedCallback: (bool f) async {
                                          if (f) {
                                            showDialog(
                                              barrierDismissible: false,
                                              context: context,
                                              builder: (BuildContext context) {
                                                Future.delayed(
                                                    const Duration(seconds: 3),
                                                    () {
                                                  Navigator.of(context)
                                                      .pop(true);
                                                });
                                                return Dialog(
                                                  alignment:
                                                      Alignment.topCenter,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 20),
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
                                                                  fontSize: 16),
                                                        ),
                                                        IconButton(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(0),
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          icon: const Icon(Icons
                                                              .close_rounded),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                            await d.addToFavorites(refId!);
                                          } else {
                                            await d.removeFromFavorites(refId!);
                                          }
                                          await fetchFav();
                                        },
                                        initValue: d.existsInFavorites("movie"),
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
                : ListView(
                    controller: widget.controller..addListener(_scrollListener),
                    children: [
                      StreamBuilder<List<TopMovieModel>>(
                        stream: _viewModel.stream,
                        builder: (context, snapshot) {
                          if (snapshot.hasData && !snapshot.hasError) {
                            if (snapshot.data!.isNotEmpty) {
                              final List<TopMovieModel> result = snapshot.data!;
                              for (final M3uEntry movdata in widget.data) {
                                for (final TopMovieModel toprated in result) {
                                  if (movdata.title == toprated.title) {
                                    getMovieVideos(id: toprated.id);

                                    return SizedBox(
                                      width: size.width,
                                      child: Column(
                                        children: [
                                          StreamBuilder<List<Video>>(
                                            stream: _videoViewModel.stream,
                                            builder: (context, snapshot) {
                                              if (snapshot.hasData &&
                                                  !snapshot.hasError) {
                                                if (snapshot.data!.isNotEmpty) {
                                                  final List<Video> result =
                                                      snapshot.data!;
                                                  final Iterable<Video>
                                                      trailer =
                                                      result.where((element) =>
                                                          element.type.contains(
                                                              "Trailer"));
                                                  return Videoplayer(
                                                      url: trailer.first.key);
                                                }
                                              }
                                              return const Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                          color: Colors.grey));
                                            },
                                          ),
                                          MaterialButton(
                                            elevation: 0,
                                            color: Colors.transparent,
                                            padding: const EdgeInsets.all(0),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                PageTransition(
                                                    child: MovieDetailsPage(
                                                      data: movdata,
                                                      title: toprated.title,
                                                    ),
                                                    type: PageTransitionType
                                                        .leftToRight),
                                              );
                                            },
                                            child: Container(
                                              width: size.width,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 15),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    toprated.title,
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 22,
                                                      height: 1.1,
                                                    ),
                                                  ),
                                                  Row(
                                                    children: [
                                                      Text(DateFormat(
                                                              'MMM dd, yyyy')
                                                          .format(
                                                              toprated.date!)),
                                                      const SizedBox(width: 10),
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal: 5),
                                                        decoration:
                                                            BoxDecoration(
                                                          border: Border.all(
                                                              color:
                                                                  Colors.white),
                                                          borderRadius:
                                                              const BorderRadius
                                                                  .all(
                                                            Radius.circular(5),
                                                          ),
                                                        ),
                                                        child: Text(
                                                            "${toprated.voteAverage}"),
                                                      ),
                                                      const SizedBox(width: 15),
                                                      SizedBox(
                                                        height: 25,
                                                        width: 30,
                                                        child: MaterialButton(
                                                          color: Colors.grey,
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(0),
                                                          onPressed: () {},
                                                          child: const Text(
                                                            "HD",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
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
                                        "No_data_available".tr(),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    );
                                  }
                                }
                              }
                            }
                            return const Center(
                              child:
                                  CircularProgressIndicator(color: Colors.grey),
                            );
                          }
                          return Center(
                            child: Text(
                              "No_data_available".tr(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        },
                      ),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: calculateCrossAxisCount(context),
                            childAspectRatio: .8,
                            crossAxisSpacing: 10),
                        itemCount: _displayData.length,
                        itemBuilder: (context, index) {
                          final M3uEntry item = _displayData[index];

                          return GestureDetector(
                            onTap: () async {
                              String result1 = item.title.replaceAll(
                                  RegExp(
                                      r"[0-9]|[(]+[0-9]+[)]|[|]\s+[0-9]+\s[|]"),
                                  '');
                              String result2 = result1.replaceAll(
                                  RegExp(r"[|]+[a-zA-Z]+[|]|[a-zA-Z]+[|] "),
                                  '');

                              Navigator.push(
                                context,
                                PageTransition(
                                  child: MovieDetailsPage(
                                      data: item, title: result2),
                                  type: PageTransitionType.rightToLeft,
                                ),
                              );
                            },
                            child: Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 1.5),
                              child: Stack(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(
                                        top: 10, right: 10),
                                    child: LayoutBuilder(
                                      builder: (context, c) {
                                        final double w = c.maxWidth;
                                        return Tooltip(
                                          message: item.title,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: NetworkImageViewer(
                                                  url: item
                                                      .attributes['tvg-logo'],
                                                  width: w,
                                                  height: 75,
                                                  fit: BoxFit.cover,
                                                  color: highlight,
                                                ),
                                              ),
                                              const SizedBox(height: 3),
                                              Tooltip(
                                                message: item.title,
                                                child: Text(
                                                  item.title,
                                                  style: const TextStyle(
                                                      fontSize: 12),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
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
                                          onPressedCallback: (bool f) async {
                                            if (f) {
                                              showDialog(
                                                barrierDismissible: false,
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  Future.delayed(
                                                    const Duration(seconds: 3),
                                                    () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  );
                                                  return Dialog(
                                                    alignment:
                                                        Alignment.topCenter,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    child: Container(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 20),
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
                                                                        16),
                                                          ),
                                                          IconButton(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(0),
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                            icon: const Icon(Icons
                                                                .close_rounded),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );
                                              await item.addToFavorites(refId!);
                                            } else {
                                              await item
                                                  .removeFromFavorites(refId!);
                                            }
                                            await fetchFav();
                                          },
                                          initValue:
                                              item.existsInFavorites("movie"),
                                          iconSize: 20),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    ],
                  ))
      ],
    );
  }

  int calculateCrossAxisCount(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount =
        (screenWidth / 150).floor(); // Calculate based on item width
    return crossAxisCount < 3 ? 3 : crossAxisCount;
  }

  void _scrollListener() {
    if (widget.controller.offset >=
        widget.controller.position.maxScrollExtent) {
      setState(() {
        if (endIndex < widget.data.length) {
          endIndex += 6;
          if (endIndex > widget.data.length) {
            endIndex = widget.data.length;
          }
        }
        _displayData = List.from(widget.data.sublist(startIndex,
            endIndex > widget.data.length ? widget.data.length : endIndex));
        print("DUGANG! ${_displayData.length}");
      });
    }
  }
}
