// ignore_for_file: implementation_imports, avoid_print

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:seizhtv/data_containers/favorites.dart';
import 'package:seizhtv/extensions/m3u_entry.dart';
import 'package:seizhtv/extensions/state.dart';
import 'package:seizhtv/globals/data.dart';
import 'package:seizhtv/globals/loader.dart';
import 'package:seizhtv/globals/network_image_viewer.dart';
import 'package:seizhtv/globals/palette.dart';
import 'package:seizhtv/globals/ui_additional.dart';
import 'package:seizhtv/globals/video_loader.dart';
import 'package:seizhtv/views/landing_page/children/series_children/details.dart';
import 'package:z_m3u_handler/extension.dart';
import 'package:z_m3u_handler/z_m3u_handler.dart';
import 'package:z_m3u_handler/src/helpers/db_regx.dart';

import '../../../globals/favorite_button.dart';
import 'movie_children/details.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage>
    with ColorPalette, DBRegX, VideoLoader, UIAdditional {
  final Favorites _vm = Favorites.instance;
  static final ZM3UHandler _handler = ZM3UHandler.instance;
  bool update = false;

  fetchFav() async {
    await _handler
        .getDataFrom(type: CollectionType.favorites, refId: refId!)
        .then((value) {
      if (value != null) {
        _vm.populate(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: card,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: appbar(
          4,
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
          StreamBuilder<CategorizedM3UData>(
            stream: _vm.stream,
            builder: (_, snapshot) {
              if (snapshot.hasError || !snapshot.hasData) {
                if (!snapshot.hasData) {
                  return const SeizhTvLoader(
                    hasBackgroundColor: false,
                  );
                }
                return Container();
              }
              final CategorizedM3UData result = snapshot.data!;
              final List<ClassifiedData> series = result.series;
              final List<ClassifiedData> live = result.live;
              final List<ClassifiedData> movies = result.movies;
              final List<M3uEntry> liveData =
                  live.expand((element) => element.data).toList();

              if (live.isEmpty && series.isEmpty && result.movies.isEmpty) {
                return const Center(
                  child: Text("No data added to favorites"),
                );
              }

              return ListView(
                children: [
                  if (live.isNotEmpty) ...{
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Text(
                        "Live_Tv".tr(),
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 5),
                    SizedBox(
                      width: double.maxFinite,
                      height: 150,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        scrollDirection: Axis.horizontal,
                        itemCount: liveData.length,
                        itemBuilder: (_, i) {
                          final M3uEntry e = liveData[i];
                          return Stack(
                            children: [
                              Container(
                                width: 120,
                                margin:
                                    const EdgeInsets.only(top: 10, right: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: GestureDetector(
                                        onTap: () async {
                                          print("DATA CLICK: $e");
                                          e.addToHistory(refId!);
                                          await loadVideo(context, e);
                                          // await showModalBottomSheet(
                                          //     context: context,
                                          //     isDismissible: true,
                                          //     backgroundColor:
                                          //         Colors.transparent,
                                          //     isScrollControlled: true,
                                          //     // context: context,
                                          //     // isDismissible: true,
                                          //     // backgroundColor: Colors.transparent,
                                          //     // constraints: const BoxConstraints(
                                          //     //   maxHeight: 250,
                                          //     // ),
                                          //     builder: (_) {
                                          //       return LiveDetails(
                                          //         onLoadVideo: () async {
                                          //           Navigator.of(context)
                                          //               .pop(null);
                                          //           await loadVideo(context, e);
                                          //         },
                                          //         entry: e,
                                          //       );
                                          //     });
                                        },
                                        child: NetworkImageViewer(
                                          url: e.attributes['tvg-logo'],
                                          width: 150,
                                          height: 85,
                                          color: card,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      e.title,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
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
                                                },
                                              );
                                              return Dialog(
                                                alignment: Alignment.topCenter,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    10.0,
                                                  ),
                                                ),
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 20,
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        "Added_to_Favorites"
                                                            .tr(),
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                      IconButton(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(0),
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        icon: const Icon(
                                                          Icons.close_rounded,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                          await e.addToFavorites(refId!);
                                        } else {
                                          await e.removeFromFavorites(refId!);
                                        }
                                        await fetchFav();
                                      },
                                      initValue: e.existsInFavorites("live"),
                                      iconSize: 20,
                                    ),
                                  ))
                            ],
                          );
                        },
                        separatorBuilder: (_, i) => const SizedBox(width: 10),
                      ),
                    ),
                    // SizedBox(
                    //   width: double.maxFinite,
                    //   height: 100,
                    //   child: ListView.separated(
                    //     padding: const EdgeInsets.symmetric(horizontal: 20),
                    //     scrollDirection: Axis.horizontal,
                    //     itemBuilder: (_, i) {
                    //       final ClassifiedData _e = _live[i];
                    //       return ClipRRect(
                    //         borderRadius: BorderRadius.circular(10),
                    //         child: GestureDetector(
                    //           onTap: () async {
                    //             // await showModalBottomSheet(
                    //             //     context: context,
                    //             //     isDismissible: true,
                    //             //     backgroundColor: Colors.transparent,
                    //             //     constraints: const BoxConstraints(
                    //             //       maxHeight: 230,
                    //             //     ),
                    //             //     builder: (_) {
                    //             //       return LiveDetails(
                    //             //         onLoadVideo: () async {
                    //             //           Navigator.of(context).pop(null);
                    //             //           await loadVideo(context, _e);
                    //             //           await _e.addToHistory(refId!);
                    //             //         },
                    //             //         entry: _e,
                    //             //       );
                    //             //     });
                    //           },
                    //           // child: NetworkImageViewer(
                    //           //   url: _e.attributes['tvg-logo']!,
                    //           //   width: 130,
                    //           //   height: 100,
                    //           //   color: card,
                    //           //   fit: BoxFit.cover,
                    //           // ),
                    //         ),
                    //       );
                    //     },
                    //     separatorBuilder: (_, i) => const SizedBox(
                    //       width: 10,
                    //     ),
                    //     itemCount: _live.length,
                    //   ),
                    // )
                  },
                  const SizedBox(height: 15),
                  if (result.movies.isNotEmpty) ...{
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Text(
                        "Movies".tr(),
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 5),
                    SizedBox(
                      width: double.maxFinite,
                      height: 180,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        scrollDirection: Axis.horizontal,
                        itemCount: movies.length,
                        itemBuilder: (_, i) {
                          // final ClassifiedData entry = movies[i];
                          final List<M3uEntry> item = movies[i].data;

                          // late final List<ClassifiedData> data = entry.data
                          //     .classify()
                          //   ..sort((a, b) => a.name.compareTo(b.name));
                          // late List<ClassifiedData> displayData =
                          //     List.from(data);

                          return ListView.separated(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: item.length,
                            itemBuilder: (c, x) {
                              final M3uEntry d = item[x];

                              return Stack(
                                children: [
                                  Container(
                                    width: 120,
                                    margin: const EdgeInsets.only(
                                        top: 10, right: 10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          child: GestureDetector(
                                            onTap: () async {
                                              String result1 = d.title.replaceAll(
                                                  RegExp(
                                                      r"[(]+[0-9]+[)]|[|]\s+[0-9]+\s[|]"),
                                                  '');
                                              String result2 = result1.replaceAll(
                                                  RegExp(
                                                      r"[|]+[a-zA-Z]+[|]|[a-zA-Z]+[|] "),
                                                  '');
                                              print("TITLE NAME: $result2");

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
                                            child: NetworkImageViewer(
                                              url: d.attributes['tvg-logo']!,
                                              width: 150,
                                              height: 120,
                                              color: card,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          d.title,
                                          maxLines: 2,
                                          style: const TextStyle(
                                              color: Colors.white),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
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
                                                        10.0,
                                                      ),
                                                    ),
                                                    child: Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 20,
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
                                              await d.addToFavorites(refId!);
                                            } else {
                                              await d
                                                  .removeFromFavorites(refId!);
                                            }
                                            await fetchFav();
                                          },
                                          initValue:
                                              d.existsInFavorites("movie"),
                                          iconSize: 20,
                                        ),
                                      ))
                                ],
                              );
                            },
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 10),
                          );
                        },
                        separatorBuilder: (_, i) => const SizedBox(width: 10),
                      ),
                    ),
                  },
                  const SizedBox(height: 15),
                  if (series.isNotEmpty) ...{
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Text(
                        "Series".tr(),
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 5),
                    SizedBox(
                      width: double.maxFinite,
                      height: 200,
                      child: ListView.separated(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        scrollDirection: Axis.horizontal,
                        itemCount: series.length,
                        itemBuilder: (_, i) {
                          final ClassifiedData item = series[i];

                          late final List<ClassifiedData> data = item.data
                              .classify()
                            ..sort((a, b) => a.name.compareTo(b.name));
                          late List<ClassifiedData> displayData =
                              List.from(data);

                          return ListView.separated(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: displayData.length,
                            itemBuilder: (c, x) {
                              final ClassifiedData d = displayData[x];

                              return SizedBox(
                                width: 120,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(5),
                                      child: GestureDetector(
                                        onTap: () async {
                                          String result1 = d.name.replaceAll(
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
                                                data: d,
                                                title: result2,
                                              ),
                                              type: PageTransitionType
                                                  .rightToLeft,
                                            ),
                                          );
                                        },
                                        child: NetworkImageViewer(
                                          url:
                                              d.data[0].attributes['tvg-logo']!,
                                          width: 150,
                                          height: 145,
                                          color: card,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      d.name,
                                      maxLines: 2,
                                      style:
                                          const TextStyle(color: Colors.white),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              );
                            },
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 10),
                          );
                        },
                        separatorBuilder: (_, i) => const SizedBox(width: 10),
                      ),
                    ),
                  },
                  const SizedBox(height: 5),
                ],
              );
            },
          ),
          update == true ? loader() : Container()
        ],
      ),
    );
  }
}
