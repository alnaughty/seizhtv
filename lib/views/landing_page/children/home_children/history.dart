// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:seizhtv/data_containers/history.dart';
import 'package:seizhtv/globals/data.dart';
import 'package:seizhtv/globals/loader.dart';
import 'package:seizhtv/globals/network_image_viewer.dart';
import 'package:seizhtv/globals/palette.dart';
import 'package:seizhtv/globals/video_loader.dart';
import 'package:seizhtv/views/landing_page/children/live_children/live_details.dart';
import 'package:seizhtv/views/landing_page/children/movie_children/movie_details.dart';
import 'package:seizhtv/views/landing_page/children/series_children/series_details_sheet.dart';
import 'package:z_m3u_handler/z_m3u_handler.dart';
// import 'package:z_m3u_handler/src/helpers/db_regx.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage>
    with ColorPalette, VideoLoader {
  final ZM3UHandler _handler = ZM3UHandler.instance;
  final History _vm = History.instance;
  Future<void> fetch() async {
    await _handler
        .getDataFrom(type: CollectionType.history, refId: refId!)
        .then((value) {
      if (value != null) {
        _vm.populate(value);
      }
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await fetch();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: card,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Row(
          children: [
            SvgPicture.asset(
              "assets/images/logo-full.svg",
              height: 25,
              color: orange,
            ),
            Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 10,
              ),
              height: 25,
              width: 1.5,
              color: Colors.white.withOpacity(.5),
            ),
            Text(
              "History".toUpperCase(),
              style: TextStyle(
                color: white,
                fontSize: 15,
                height: 1,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      body: StreamBuilder<CategorizedM3UData>(
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
            final CategorizedM3UData _result = snapshot.data!;
            final List<ClassifiedData> _series = _result.series;
            final List<ClassifiedData> _live = _result.live;
            if (_live.isEmpty && _series.isEmpty && _result.movies.isEmpty) {
              return const Center(
                child: Text("No data added to history"),
              );
            }
            return ListView(
              children: [
                if (_live.isNotEmpty) ...{
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Text(
                      "Live",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: double.maxFinite,
                    height: 100,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (_, i) {
                        final ClassifiedData _e = _live[i];
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: GestureDetector(
                            onTap: () async {
                              await showModalBottomSheet(
                                  context: context,
                                  isDismissible: true,
                                  backgroundColor: Colors.transparent,
                                  constraints: const BoxConstraints(
                                    maxHeight: 230,
                                  ),
                                  builder: (_) {
                                    return LiveDetails(
                                      onLoadVideo: () async {
                                        Navigator.of(context).pop(null);
                                        await loadVideo(context, _e.data.first);
                                      },
                                      entry: _e.data.first,
                                    );
                                  });
                            },
                            child: NetworkImageViewer(
                              url: _e.data.first.attributes['tvg-logo'],
                              width: 130,
                              height: 100,
                              color: card,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (_, i) => const SizedBox(
                        width: 10,
                      ),
                      itemCount: _live.length,
                    ),
                  )
                },
                if (_result.movies.isNotEmpty) ...{
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Text(
                      "Movies",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: double.maxFinite,
                    height: 180,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (_, i) {
                        final ClassifiedData _entry = _result.movies[i];
                        return SizedBox(
                          width: 120,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: GestureDetector(
                              onTap: () async {
                                await showModalBottomSheet(
                                    context: context,
                                    isDismissible: true,
                                    backgroundColor: Colors.transparent,
                                    constraints: const BoxConstraints(
                                      maxHeight: 230,
                                    ),
                                    builder: (_) {
                                      return MovieDetails(
                                        data: _entry,
                                        onLoadVideo: (M3uEntry entry) async {
                                          Navigator.of(context).pop(null);
                                          entry.addToHistory(refId!);
                                          await loadVideo(context, entry);
                                        },
                                      );
                                    });
                                // await _entry.removeFromFavorites(refId!);
                                // await fetchFav();
                              },
                              child: Column(
                                children: [
                                  Expanded(
                                    child: LayoutBuilder(builder: (_, c) {
                                      return NetworkImageViewer(
                                        url: _entry
                                            .data[0].attributes['tvg-logo']!,
                                        width: 120,
                                        height: c.maxHeight,
                                        color: card,
                                        fit: BoxFit.cover,
                                      );
                                    }),
                                  ),
                                  // Container(
                                  //   color: card.darken(),
                                  //   padding: const EdgeInsets.symmetric(
                                  //       horizontal: 3),
                                  //   height: 55,
                                  //   child: Center(
                                  //     child: Text(
                                  //       _entry.title,
                                  //       maxLines: 2,
                                  //       style: const TextStyle(
                                  //         height: 1,
                                  //       ),
                                  //     ),
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (_, i) => const SizedBox(
                        width: 10,
                      ),
                      itemCount: _result
                          .movies
                          // .expand((element) => element.data)
                          // .toList()
                          .length,
                    ),
                  ),
                },
                if (_series.isNotEmpty) ...{
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Text(
                      "Series",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: double.maxFinite,
                    height: 180,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (_, i) {
                        final ClassifiedData _data = _series[i];
                        return SizedBox(
                          width: 120,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: GestureDetector(
                              onTap: () async {
                                await showModalBottomSheet(
                                  context: context,
                                  isDismissible: true,
                                  backgroundColor: Colors.transparent,
                                  isScrollControlled: true,
                                  builder: (_) => SeriesDetailsSheet(
                                    data: _data,
                                    onLoadVideo: (M3uEntry entry) async {
                                      Navigator.of(context).pop(null);
                                      await loadVideo(context, entry);
                                      await entry.addToHistory(refId!);
                                    },
                                  ),
                                );
                                // await _entry.removeFromFavorites(refId!);
                                // await fetchFav();
                                // await showModalBottomSheet(
                                //   context: context,
                                //   backgroundColor: Colors.transparent,
                                //   constraints: BoxConstraints(
                                //     maxHeight: size.height,
                                //   ),
                                //   // constraints: BoxConstraints(
                                //   //   maxHeight: size.height,
                                //   // ),

                                //   isScrollControlled: true,
                                //   builder: (_) => DraggableScrollableSheet(
                                //     maxChildSize: 1,
                                //     initialChildSize: .4,
                                //     minChildSize: .38,
                                //     builder: (_, controller) => Container(
                                //       color: Colors.red,
                                //       child: ListView(
                                //         controller: controller,
                                //         children: [],
                                //       ),
                                //     ),
                                //   ),
                                // );
                              },
                              child: Column(
                                children: [
                                  Expanded(
                                    child: LayoutBuilder(builder: (_, c) {
                                      return NetworkImageViewer(
                                        url: _data
                                            .data.first.attributes['tvg-logo']!,
                                        width: 120,
                                        height: c.maxHeight,
                                        color: card,
                                        fit: BoxFit.cover,
                                      );
                                    }),
                                  ),
                                  // Container(
                                  //   color: card.darken(),
                                  //   padding: const EdgeInsets.symmetric(
                                  //       horizontal: 3),
                                  //   height: 55,
                                  //   child: Center(
                                  //     child: Text(
                                  //       _data.data.first.title
                                  //           .replaceAll(season, "")
                                  //           .replaceAll(episode, "")
                                  //           .replaceAll(epAndSe, "")
                                  //           .trim(),
                                  //       maxLines: 2,
                                  //       style: const TextStyle(
                                  //         height: 1,
                                  //       ),
                                  //     ),
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (_, i) => const SizedBox(
                        width: 10,
                      ),
                      itemCount: _series.length,
                    ),
                  ),
                },
              ],
            );
          }),
    );
  }
}
