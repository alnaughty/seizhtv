// ignore_for_file: must_be_immutable
import 'dart:isolate';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:page_transition/page_transition.dart';
import 'package:seizhtv/extensions/classified_data.dart';
import 'package:seizhtv/extensions/color.dart';
import 'package:z_m3u_handler/extension.dart';
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
import '../../../../models/topseries.dart';
import '../../../../services/tv_series_api.dart';
import '../../../../viewmodel/tvshow_vm.dart';
import '../../../../viewmodel/video_vm.dart';
import 'details.dart';

class SeriesListPage extends StatefulWidget {
  SeriesListPage(
      {required this.controller,
      required this.data,
      this.showSearchField = false,
      super.key});
  final ScrollController controller;
  final List<ClassifiedData> data;
  bool showSearchField;

  @override
  State<SeriesListPage> createState() => SeriesListPageState();
}

class SeriesListPageState extends State<SeriesListPage>
    with ColorPalette, TVSeriesAPI {
  static final TVVideoViewModel _videoViewModel = TVVideoViewModel.instance;
  static final TopRatedTVShowViewModel _viewModel =
      TopRatedTVShowViewModel.instance;
  static final ZM3UHandler _handler = ZM3UHandler.instance;
  static final Favorites _fav = Favorites.instance;
  final LoadedM3uData _vm = LoadedM3uData.instance;
  late List<ClassifiedData> _favdata;
  List<ClassifiedData> favData = [];
  late final TextEditingController _search = TextEditingController();
  List<ClassifiedData>? searchData;
  final ReceivePort receivePort = ReceivePort();

  fetchFav() async {
    await _handler
        .getDataFrom(type: CollectionType.favorites, refId: refId!)
        .then((value) {
      if (value != null) {
        _fav.populate(value);
      }
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
    });
  }

  @override
  void initState() {
    fetchFav();
    initFavStream();
    searchData = widget.data;
    super.initState();
  }

  final int startIndex = 0;
  late int endIndex = widget.data.length < 30 ? widget.data.length : 30;
  late List<ClassifiedData> _displayData =
      List.from(widget.data.sublist(startIndex, endIndex));

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return StreamBuilder(
        stream: _vm.stream,
        builder: (context, snapshot) {
          if (snapshot.hasError || !snapshot.hasData) {
            if (!snapshot.hasData) {
              return SeizhTvLoader(
                label: Text(
                  "Retrieving_data".tr(),
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              );
            }

            return Container();
          }

          final CategorizedM3UData result = snapshot.data!;
          final List<ClassifiedData> series = result.series;
          List<ClassifiedData> seriesData = [];

          for (final ClassifiedData item in series) {
            late final List<ClassifiedData> data = item.data.classify()
              ..sort((a, b) => a.name.compareTo(b.name));

            seriesData.addAll(List.from(data));
          }

          return Column(
            children: [
              AnimatedPadding(
                duration: const Duration(milliseconds: 400),
                padding: EdgeInsets.symmetric(
                    horizontal: widget.showSearchField ? 20 : 0),
                child: AnimatedContainer(
                  duration: const Duration(
                    milliseconds: 500,
                  ),
                  height: widget.showSearchField ? 50 : 0,
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
                                child: widget.showSearchField
                                    ? TextField(
                                        onChanged: (text) {
                                          if (text.isEmpty) {
                                            searchData = widget.data;
                                          } else {
                                            searchData = List.from(widget.data
                                                .where((element) => element.name
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
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    childAspectRatio: .8,
                                    crossAxisSpacing: 10),
                            itemCount: searchData!.length,
                            itemBuilder: (context, i) {
                              bool isFavorite = false;
                              for (final ClassifiedData fav in favData) {
                                if (searchData![i].name == fav.name) {
                                  if (fav.data.length ==
                                      searchData![i].data.length) {
                                    isFavorite = true;
                                  }
                                }
                              }

                              return GestureDetector(
                                onTap: () async {
                                  print("TITLE: ${searchData![i]}");
                                  String result1 = searchData![i].name.replaceAll(
                                      RegExp(
                                          r"[(]+[a-zA-Z]+[)]|[0-9]|[|]\s+[0-9]+\s[|]"),
                                      '');
                                  String result2 = result1.replaceAll(
                                      RegExp(r"[|]+[a-zA-Z]+[|]|[a-zA-Z]+[|] "),
                                      '');

                                  Navigator.push(
                                    context,
                                    PageTransition(
                                      child: SeriesDetailsPage(
                                        data: searchData![i],
                                        title: result2,
                                      ),
                                      type: PageTransitionType.rightToLeft,
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
                                            message: searchData![i].name,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  child: NetworkImageViewer(
                                                    url: searchData![i]
                                                        .data[0]
                                                        .attributes['tvg-logo'],
                                                    width: w,
                                                    height: 53,
                                                    fit: BoxFit.cover,
                                                    color: highlight,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Tooltip(
                                                  message: searchData![i].name,
                                                  child: Text(
                                                    searchData![i].name,
                                                    style: const TextStyle(
                                                        fontSize: 12),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                        "${searchData![i].data.length} ",
                                                        style: const TextStyle(
                                                            fontSize: 12,
                                                            color:
                                                                Colors.grey)),
                                                    Text("Episodes".tr(),
                                                        style: const TextStyle(
                                                            fontSize: 12,
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
                                          onPressedCallback:
                                              (bool isFavorite) async {
                                            if (isFavorite) {
                                              showDialog(
                                                barrierDismissible: false,
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  Future.delayed(
                                                    const Duration(seconds: 3),
                                                    () {
                                                      Navigator.of(context)
                                                          .pop(true);
                                                    },
                                                  );
                                                  return Dialog(
                                                    alignment:
                                                        Alignment.topCenter,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
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
                                                              fontSize: 16,
                                                            ),
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
                                                            icon: const Icon(
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
                                                  in searchData![i].data) {
                                                await m3u
                                                    .addToFavorites(refId!);
                                              }
                                              if (mounted) setState(() {});
                                            } else {
                                              for (M3uEntry m3u
                                                  in searchData![i].data) {
                                                await m3u.removeFromFavorites(
                                                    refId!);
                                              }
                                              if (mounted) setState(() {});
                                            }
                                            await fetchFav();
                                            if (mounted) setState(() {});
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
                    : ListView(
                        controller: widget.controller
                          ..addListener(_scrollListener),
                        children: [
                          StreamBuilder<List<TopSeriesModel>>(
                            stream: _viewModel.stream,
                            builder: (context, snapshot) {
                              if (snapshot.hasData && !snapshot.hasError) {
                                if (snapshot.data!.isNotEmpty) {
                                  final List<TopSeriesModel> result =
                                      snapshot.data!;
                                  late Iterable<ClassifiedData> cd;
                                  late TopSeriesModel tm;

                                  for (final TopSeriesModel tsm in result) {
                                    print("TM TITLE: ${tsm.title}");
                                    print(
                                        "${widget.data.where((element) => element.name.toLowerCase().contains(tsm.title.toLowerCase()))}");
                                    cd = widget.data.where((element) => element
                                        .name
                                        .toLowerCase()
                                        .contains(tsm.title.toLowerCase()));
                                    tm = tsm;
                                  }
                                  getTVVideos(id: tm.id);

                                  return Column(
                                    children: [
                                      StreamBuilder<List<Video>>(
                                        stream: _videoViewModel.stream,
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData &&
                                              !snapshot.hasError) {
                                            if (snapshot.data!.isNotEmpty) {
                                              final List<Video> result =
                                                  snapshot.data!;
                                              return Videoplayer(
                                                url: result[0].key,
                                              );
                                            }
                                          }
                                          return const Center(
                                            child: CircularProgressIndicator(
                                                color: Colors.grey),
                                          );
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
                                              child: SeriesDetailsPage(
                                                data: cd.first,
                                                title: tm.title,
                                              ),
                                              type: PageTransitionType
                                                  .rightToLeft,
                                            ),
                                          );
                                        },
                                        child: Container(
                                          width: size.width,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 15),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                cd.first.name,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 22,
                                                  height: 1.1,
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                      DateFormat('MMM dd, yyyy')
                                                          .format(tm.date!)),
                                                  const SizedBox(width: 10),
                                                  Container(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 5),
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: Colors.white),
                                                      borderRadius:
                                                          const BorderRadius
                                                              .all(
                                                        Radius.circular(5),
                                                      ),
                                                    ),
                                                    child: Text(
                                                        "${tm.voteAverage}"),
                                                  ),
                                                  const SizedBox(width: 15),
                                                  SizedBox(
                                                    height: 25,
                                                    width: 30,
                                                    child: MaterialButton(
                                                      color: Colors.grey,
                                                      padding:
                                                          const EdgeInsets.all(
                                                              0),
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
                                  );
                                }
                              }
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.grey,
                                ),
                              );
                            },
                          ),
                          GridView.builder(
                              shrinkWrap: true,
                              physics: const ClampingScrollPhysics(),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount:
                                          calculateCrossAxisCount(context),
                                      childAspectRatio: .8,
                                      crossAxisSpacing: 10,
                                      mainAxisExtent: 150),
                              itemCount: _displayData.length,
                              itemBuilder: (context, i) {
                                late bool isFavorite =
                                    _displayData[i].isInFavorite("series");
                                bool isInFavorite = false;
                                for (final ClassifiedData fav in favData) {
                                  if (_displayData[i].name == fav.name) {
                                    if (fav.data.length ==
                                        widget.data[i].data.length) {
                                      print(
                                          "FAVORITE LENGHT: ${widget.data[i].name} = ${widget.data[i].data.length} - ${fav.data.length}");
                                      isInFavorite = true;
                                    }
                                  }
                                }

                                return GestureDetector(
                                  onTap: () async {
                                    String result1 = _displayData[i]
                                        .name
                                        .replaceAll(
                                            RegExp(
                                                r"[(]+[a-zA-Z]+[)]|[|]\s+[0-9]+\s[|]"),
                                            '');
                                    String result2 = result1.replaceAll(
                                        RegExp(
                                            r"[|]+[a-zA-Z]+[|]|[a-zA-Z]+[|] "),
                                        '');
                                    // await showModalBottomSheet(
                                    //   context: context,
                                    //   isDismissible: true,
                                    //   backgroundColor: Colors.transparent,
                                    //   isScrollControlled: true,
                                    //   builder: (_) => SeriesDetailsSheet(
                                    //     data: _displayData[i],
                                    //     onLoadVideo: (M3uEntry entry) async {
                                    //       Navigator.of(context).pop(null);
                                    //       // await loadVideo(context, entry);
                                    //       await entry.addToHistory(refId!);
                                    //     },
                                    //   ),
                                    // );
                                    Navigator.push(
                                      context,
                                      PageTransition(
                                        child: SeriesDetailsPage(
                                          data: _displayData[i],
                                          title: result2,
                                        ),
                                        type: PageTransitionType.rightToLeft,
                                      ),
                                    );
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 1.5),
                                    child: Stack(
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(
                                              top: 10, right: 10),
                                          child: LayoutBuilder(
                                            builder: (context, c) {
                                              final double w = c.maxWidth;
                                              return Tooltip(
                                                message: _displayData[i].name,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                      child: NetworkImageViewer(
                                                        url: _displayData[i]
                                                                .data[0]
                                                                .attributes[
                                                            'tvg-logo'],
                                                        width: w,
                                                        height: 75,
                                                        fit: BoxFit.cover,
                                                        color: highlight,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 3),
                                                    Tooltip(
                                                      message:
                                                          _displayData[i].name,
                                                      child: Text(
                                                        _displayData[i].name,
                                                        style: const TextStyle(
                                                            fontSize: 12),
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                    Row(
                                                      children: [
                                                        Text(
                                                            "${_displayData[i].data.length} ",
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color: Colors
                                                                        .grey)),
                                                        Text("Episodes".tr(),
                                                            style:
                                                                const TextStyle(
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
                                              onPressedCallback:
                                                  (bool isFavorite) async {
                                                if (isFavorite) {
                                                  showDialog(
                                                    barrierDismissible: false,
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      Future.delayed(
                                                        const Duration(
                                                            seconds: 3),
                                                        () {
                                                          Navigator.of(context)
                                                              .pop(true);
                                                        },
                                                      );
                                                      return Dialog(
                                                        alignment:
                                                            Alignment.topCenter,
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10.0),
                                                        ),
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
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
                                                                icon: const Icon(
                                                                    Icons
                                                                        .close_rounded),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  );
                                                  for (M3uEntry m3u
                                                      in _displayData[i].data) {
                                                    await m3u
                                                        .addToFavorites(refId!);
                                                  }
                                                } else {
                                                  for (M3uEntry m3u
                                                      in _displayData[i].data) {
                                                    await m3u
                                                        .removeFromFavorites(
                                                            refId!);
                                                  }
                                                }
                                                await fetchFav();
                                              },
                                              initValue: isInFavorite,
                                              iconSize: 20,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              })
                        ],
                      ),
              ),
            ],
          );
        });
  }

  int calculateCrossAxisCount(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = (screenWidth / 150).floor();
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

  //  useIsolate() async {
  //   final ReceivePort receivePort = ReceivePort();
  //   try {
  //     await Isolate.spawn(
  //         runHeavyTaskIWithIsolate, [receivePort.sendPort, 4000000000]);
  //   } on Object {
  //     debugPrint('Isolate Failed');
  //     receivePort.close();
  //   }
  //   final response = await receivePort.first;

  //   print('Result: $response');
  // }
}
