import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
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
  const SeriesListPage(
      {required this.controller, required this.data, super.key});
  final ScrollController controller;
  final List<ClassifiedData> data;

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

          return ListView(
            controller: widget.controller..addListener(_scrollListener),
            children: [
              StreamBuilder<List<TopSeriesModel>>(
                stream: _viewModel.stream,
                builder: (context, snapshot) {
                  if (snapshot.hasData && !snapshot.hasError) {
                    if (snapshot.data!.isNotEmpty) {
                      final List<TopSeriesModel> result = snapshot.data!;
                      getTVVideos(id: result[0].id);

                      for (final TopSeriesModel tm in result) {
                        final Iterable<ClassifiedData> cd = seriesData.where(
                            (element) => element.name
                                .toLowerCase()
                                .contains(tm.title.toLowerCase()));

                        return Column(
                          children: [
                            StreamBuilder<List<Video>>(
                              stream: _videoViewModel.stream,
                              builder: (context, snapshot) {
                                if (snapshot.hasData && !snapshot.hasError) {
                                  if (snapshot.data!.isNotEmpty) {
                                    final List<Video> result = snapshot.data!;
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
                                    type: PageTransitionType.rightToLeft,
                                  ),
                                );
                              },
                              child: Container(
                                width: size.width,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                        Text(DateFormat('MMM dd, yyyy')
                                            .format(tm.date!)),
                                        const SizedBox(width: 10),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 5),
                                          decoration: BoxDecoration(
                                            border:
                                                Border.all(color: Colors.white),
                                            borderRadius:
                                                const BorderRadius.all(
                                              Radius.circular(5),
                                            ),
                                          ),
                                          child: Text("${tm.voteAverage}"),
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
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600),
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
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: calculateCrossAxisCount(context),
                      childAspectRatio: .8,
                      crossAxisSpacing: 10),
                  itemCount: _displayData.length,
                  itemBuilder: (context, i) {
                    bool isFavorite = false;
                    for (final ClassifiedData fav in favData) {
                      if (_displayData[i].name == fav.name) {
                        if (fav.data.length == widget.data[i].data.length) {
                          isFavorite = true;
                        }
                      }
                    }

                    return GestureDetector(
                      onTap: () async {
                        String result1 = _displayData[i].name.replaceAll(
                            RegExp(r"[(]+[a-zA-Z]+[)]|[|]\s+[0-9]+\s[|]"), '');
                        String result2 = result1.replaceAll(
                            RegExp(r"[|]+[a-zA-Z]+[|]|[a-zA-Z]+[|] "), '');

                        debugPrint("DATA: ${_displayData[i]}");
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
                      child: Stack(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 10, right: 10),
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
                                        borderRadius: BorderRadius.circular(5),
                                        child: NetworkImageViewer(
                                          url: _displayData[i]
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
                                        message: _displayData[i].name,
                                        child: Text(
                                          _displayData[i].name,
                                          style: const TextStyle(fontSize: 12),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                              "${_displayData[i].data.length} ",
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey)),
                                          Text("Episodes".tr(),
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey)),
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
                                onPressedCallback: (bool isFavorite) async {
                                  if (isFavorite) {
                                    showDialog(
                                      barrierDismissible: false,
                                      context: context,
                                      builder: (BuildContext context) {
                                        Future.delayed(
                                          const Duration(seconds: 3),
                                          () {
                                            Navigator.of(context).pop(true);
                                          },
                                        );
                                        return Dialog(
                                          alignment: Alignment.topCenter,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  "Added_to_Favorites".tr(),
                                                  style: const TextStyle(
                                                      fontSize: 16),
                                                ),
                                                IconButton(
                                                  padding:
                                                      const EdgeInsets.all(0),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
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
                                    for (M3uEntry m3u in _displayData[i].data) {
                                      await m3u.addToFavorites(refId!);
                                    }
                                  } else {
                                    for (M3uEntry m3u in _displayData[i].data) {
                                      await m3u.removeFromFavorites(refId!);
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
            ],
          );
        });
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
      print("DUGANG!");
      setState(() {
        if (endIndex < widget.data.length) {
          endIndex += 6;
          if (endIndex > widget.data.length) {
            endIndex = widget.data.length;
          }
        }
        _displayData = List.from(widget.data.sublist(startIndex,
            endIndex > widget.data.length ? widget.data.length : endIndex));
        print(_displayData.length);
      });
    }
  }
}
