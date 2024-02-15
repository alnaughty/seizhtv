// ignore_for_file: deprecated_member_use

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:page_transition/page_transition.dart';
import 'package:seizhtv/data_containers/history.dart';
import 'package:seizhtv/globals/data.dart';
import 'package:seizhtv/globals/loader.dart';
import 'package:seizhtv/globals/network_image_viewer.dart';
import 'package:seizhtv/globals/palette.dart';
import 'package:seizhtv/globals/video_loader.dart';
import 'package:z_m3u_handler/extension.dart';
import 'package:z_m3u_handler/z_m3u_handler.dart';
import '../movie_children/details.dart';
import '../series_children/details.dart';

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
              "assets/images/logo.svg",
              height: 25,
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
              "History".tr().toUpperCase(),
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
            // final CategorizedM3UData result = snapshot.data!;
            // final List<ClassifiedData> series = result.series;
            // final List<ClassifiedData> live = result.live;

            final CategorizedM3UData result = snapshot.data!;
            final List<ClassifiedData> series = result.series;
            final List<ClassifiedData> live = result.live;
            final List<ClassifiedData> movies = result.movies;
            final List<M3uEntry> liveData =
                live.expand((element) => element.data).toList();

            if (live.isEmpty && series.isEmpty && result.movies.isEmpty) {
              return const Center(
                child: Text("No data added to history"),
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
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: double.maxFinite,
                    height: 150,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (_, i) {
                        final M3uEntry e = liveData[i];
                        return SizedBox(
                          width: 120,
                          child: Column(
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
                                    //     backgroundColor: Colors.transparent,
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
                                    //           Navigator.of(context).pop(null);
                                    //           await loadVideo(context, e);
                                    //         },
                                    //         entry: e,
                                    //       );
                                    //     });
                                  },
                                  child: NetworkImageViewer(
                                    url: e.attributes['tvg-logo'],
                                    width: 150,
                                    height: 100,
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
                        );
                      },
                      separatorBuilder: (_, i) => const SizedBox(
                        width: 10,
                      ),
                      itemCount: liveData.length,
                    ),
                  )
                },
                const SizedBox(height: 10),
                if (result.movies.isNotEmpty) ...{
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Text(
                      "Movies".tr(),
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: double.maxFinite,
                    height: 200,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      scrollDirection: Axis.horizontal,
                      itemCount: movies.length,
                      itemBuilder: (_, i) {
                        final List<M3uEntry> item = movies[i].data;

                        return ListView.separated(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: item.length,
                          itemBuilder: (c, x) {
                            final M3uEntry d = item[x];

                            return SizedBox(
                              width: 120,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(5),
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

                                        Navigator.push(
                                          context,
                                          PageTransition(
                                            child: MovieDetailsPage(
                                              data: d,
                                              title: result2,
                                            ),
                                            type:
                                                PageTransitionType.rightToLeft,
                                          ),
                                        );
                                      },
                                      child: NetworkImageViewer(
                                        url: d.attributes['tvg-logo']!,
                                        width: 150,
                                        height: 150,
                                        color: card,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    d.title,
                                    maxLines: 2,
                                    style: const TextStyle(color: Colors.white),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            );
                          },
                          separatorBuilder: (_, __) => const SizedBox(
                            width: 10,
                          ),
                        );
                      },
                      separatorBuilder: (_, i) => const SizedBox(width: 10),
                    ),
                  )
                },
                const SizedBox(height: 10),
                if (series.isNotEmpty) ...{
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Text(
                      "Series".tr(),
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
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
                        late List<ClassifiedData> displayData = List.from(data);

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
                                        String str1 = d.name;
                                        String result1 = str1.replaceAll(
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
                                            type:
                                                PageTransitionType.rightToLeft,
                                          ),
                                        );
                                      },
                                      child: NetworkImageViewer(
                                        url: d.data[0].attributes['tvg-logo']!,
                                        width: 150,
                                        height: 150,
                                        color: card,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    d.name,
                                    maxLines: 2,
                                    style: const TextStyle(color: Colors.white),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            );
                          },
                          separatorBuilder: (_, __) => const SizedBox(
                            width: 10,
                          ),
                        );
                      },
                      separatorBuilder: (_, i) => const SizedBox(
                        width: 10,
                      ),
                    ),
                  ),
                },
              ],
            );
          }),
    );
  }
}
