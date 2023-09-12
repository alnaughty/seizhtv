import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:z_m3u_handler/extension.dart';
import 'package:z_m3u_handler/z_m3u_handler.dart';
import '../../../../data_containers/favorites.dart';
import '../../../../globals/data.dart';
import '../../../../globals/loader.dart';
import '../../../../globals/network_image_viewer.dart';
import '../../../../globals/palette.dart';
import '../../../../globals/ui_additional.dart';
import '../../../../globals/video_loader.dart';
import 'details.dart';

class FavSeriesPage extends StatefulWidget {
  const FavSeriesPage({super.key});

  @override
  State<FavSeriesPage> createState() => FavSeriesPageState();
}

class FavSeriesPageState extends State<FavSeriesPage>
    with ColorPalette, VideoLoader, UIAdditional {
  static final ZM3UHandler _handler = ZM3UHandler.instance;
  final Favorites _favvm = Favorites.instance;
  late List<ClassifiedData> seriesData = [];

  fetchFav() async {
    await _handler
        .getDataFrom(type: CollectionType.favorites, refId: refId!)
        .then((value) {
      if (value != null) {
        _favvm.populate(value);
      }
    });
  }

  @override
  void initState() {
    fetchFav();
    seriesData = [];
    super.initState();
  }

  @override
  void dispose() {
    seriesData = [];
    _favvm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<CategorizedM3UData>(
      stream: _favvm.stream,
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
        seriesData =
            series.expand((element) => element.data.classify()).toList();

        if (series.isEmpty) {
          return const Center(
            child: Text("No data added to favorites"),
          );
        }
        return GridView.builder(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: .8, // optional, adjust as needed
              mainAxisSpacing: 10,
              crossAxisSpacing: 10),
          itemCount: seriesData.length,
          itemBuilder: (context, index) {
            final ClassifiedData item = seriesData[index];

            return LayoutBuilder(
              builder: (context, c) {
                final double w = c.maxWidth;
                return Stack(
                  children: [
                    GestureDetector(
                      onTap: () {
                        String result1 = item.name.replaceAll(
                            RegExp(r"[(]+[a-zA-Z]+[)]|[|]\s+[0-9]+\s[|]"), '');
                        String result2 = result1.replaceAll(
                            RegExp(r"[|]+[a-zA-Z]+[|]|[a-zA-Z]+[|] "), '');

                        Navigator.push(
                          context,
                          PageTransition(
                            child: SeriesDetailsPage(
                              data: item,
                              title: result2,
                            ),
                            type: PageTransitionType.rightToLeft,
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(top: 10, right: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: NetworkImageViewer(
                                url: item.data[0].attributes['tvg-logo'],
                                width: w,
                                height: 80,
                                color: highlight,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              item.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(height: 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Positioned(
                    //     top: 0,
                    //     right: 0,
                    //     child: SizedBox(
                    //       height: 25,
                    //       width: 25,
                    //       child: FavoriteIconButton(
                    //         onPressedCallback: (bool f) async {
                    //           if (f) {
                    //             showDialog(
                    //               barrierDismissible: false,
                    //               context: context,
                    //               builder: (BuildContext context) {
                    //                 Future.delayed(
                    //                   const Duration(seconds: 3),
                    //                   () {
                    //                     Navigator.of(context).pop(true);
                    //                   },
                    //                 );
                    //                 return Dialog(
                    //                   alignment: Alignment.topCenter,
                    //                   shape: RoundedRectangleBorder(
                    //                     borderRadius: BorderRadius.circular(
                    //                       10.0,
                    //                     ),
                    //                   ),
                    //                   child: Container(
                    //                     padding: const EdgeInsets.symmetric(
                    //                       horizontal: 20,
                    //                     ),
                    //                     child: Row(
                    //                       mainAxisAlignment:
                    //                           MainAxisAlignment.spaceBetween,
                    //                       children: [
                    //                         Text(
                    //                           "Added_to_Favorites".tr(),
                    //                           style: const TextStyle(
                    //                             fontSize: 16,
                    //                           ),
                    //                         ),
                    //                         IconButton(
                    //                           padding: const EdgeInsets.all(0),
                    //                           onPressed: () {
                    //                             Navigator.of(context).pop();
                    //                           },
                    //                           icon: const Icon(
                    //                             Icons.close_rounded,
                    //                           ),
                    //                         ),
                    //                       ],
                    //                     ),
                    //                   ),
                    //                 );
                    //               },
                    //             );
                    //             await item.addToFavorites(refId!);
                    //           } else {
                    //             await item.removeFromFavorites(refId!);
                    //           }
                    //           await fetchFav();
                    //         },
                    //         initValue: item.existsInFavorites("live"),
                    //         iconSize: 20,
                    //       ),
                    //     ))
                  ],
                );
              },
            );
          },
        );
        // ListView.separated(
        //   shrinkWrap: true,
        //   physics: const NeverScrollableScrollPhysics(),
        //   padding: const EdgeInsets.all(0),
        //   itemCount: seriesData.length,
        //   separatorBuilder: (_, __) => const SizedBox(height: 5),
        //   itemBuilder: (c, i) {
        //     final ClassifiedData item = seriesData[i];

        //     // late final List<ClassifiedData> data = item.data.classify()
        //     //   ..sort((a, b) => a.name.compareTo(b.name));
        //     // late List<ClassifiedData> displayData = List.from(data);

        //     return ListView.separated(
        //       shrinkWrap: true,
        //       physics: const NeverScrollableScrollPhysics(),
        //       padding: const EdgeInsets.all(0),
        //       itemCount: displayData.length,
        //       itemBuilder: (c, x) {
        //         final ClassifiedData d = displayData[x];

        //         return ListTile(
        //           title: Text(d.name),
        //           onTap: () async {
        // String result1 = d.name.replaceAll(
        //     RegExp(r"[(]+[a-zA-Z]+[)]|[|]\s+[0-9]+\s[|]"), '');
        // String result2 = result1.replaceAll(
        //     RegExp(r"[|]+[a-zA-Z]+[|]|[a-zA-Z]+[|] "), '');

        // Navigator.push(
        //   context,
        //   PageTransition(
        //     child: SeriesDetailsPage(
        //       data: d,
        //       title: result2,
        //     ),
        //     type: PageTransitionType.rightToLeft,
        //   ),
        // );
        //           },
        //           subtitle: Row(
        //             children: [
        //               Text("${d.data.length} "),
        //               Text("Episodes".tr()),
        //             ],
        //           ),
        //           leading: ClipRRect(
        //             borderRadius: BorderRadius.circular(5),
        //             child: SizedBox(
        //               width: 85,
        //               child: NetworkImageViewer(
        //                 url: d.data[0].attributes['tvg-logo']!,
        //                 width: 85,
        //                 height: 60,
        //                 fit: BoxFit.cover,
        //                 color: highlight,
        //               ),
        //             ),
        //           ),
        //         );
        //       },
        //       separatorBuilder: (_, __) => const SizedBox(height: 5),
        //     );

        //     // return GridView.builder(
        //     //   shrinkWrap: true,
        //     //   physics: const ClampingScrollPhysics(),
        //     //   padding: const EdgeInsets.symmetric(horizontal: 20),
        //     //   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        //     //       crossAxisCount: calculateCrossAxisCount(context),
        //     //       childAspectRatio: .8, // optional, adjust as needed
        //     //       mainAxisSpacing: 15,
        //     //       crossAxisSpacing: 15),
        //     //   itemCount: displayData.length,
        //     // itemBuilder: (c, x) {
        //     //   final ClassifiedData d = displayData[x];

        //     //     return LayoutBuilder(
        //     //       builder: (context, c) {
        //     //         return ClipRRect(
        //     //           borderRadius: BorderRadius.circular(10),
        //     //           child: MaterialButton(
        //     //             onPressed: () {
        //     //               String str1 = d.name;
        //     //               String result1 = str1.replaceAll(
        //     //                   RegExp(r"[(]+[a-zA-Z]+[)]|[|]\s+[0-9]+\s[|]"),
        //     //                   '');
        //     //               String result2 = result1.replaceAll(
        //     //                   RegExp(r"[|]+[a-zA-Z]+[|]|[a-zA-Z]+[|] "), '');

        //     //               Navigator.push(
        //     //                 context,
        //     //                 PageTransition(
        //     //                   child: SeriesDetailsPage(
        //     //                     data: d,
        //     //                     title: result2,
        //     //                   ),
        //     //                   type: PageTransitionType.leftToRight,
        //     //                 ),
        //     //               );
        //     //             },
        //     //             padding: EdgeInsets.zero,
        //     //             color: card,
        //     //             child: Column(
        //     //               crossAxisAlignment: CrossAxisAlignment.start,
        //     //               mainAxisAlignment: MainAxisAlignment.start,
        //     //               children: [
        //     //                 ConstrainedBox(
        //     //                   constraints:
        //     //                       BoxConstraints(maxHeight: c.maxWidth * .8),
        //     //                   child: ClipRRect(
        //     //                     borderRadius: BorderRadius.circular(10),
        //     //                     child: NetworkImageViewer(
        //     //                       url: d.data[0].attributes['tvg-logo'],
        //     //                       width: c.maxWidth,
        //     //                       height: c.maxWidth * .8,
        //     //                       color: highlight,
        //     //                       fit: BoxFit.cover,
        //     //                     ),
        //     //                   ),
        //     //                 ),
        //     //                 const SizedBox(height: 5),
        //     //                 Text(
        //     //                   d.name,
        //     //                   maxLines: 2,
        //     //                   overflow: TextOverflow.ellipsis,
        //     //                   style: const TextStyle(height: 1),
        //     //                 ),
        //     //               ],
        //     //             ),
        //     //           ),
        //     //         );
        //     //       },
        //     //     );
        //     //   },
        //     // );
        //   },
        // );
      },
    );
  }

  // int calculateCrossAxisCount(BuildContext context) {
  //   double screenWidth = MediaQuery.of(context).size.width;
  //   int crossAxisCount =
  //       (screenWidth / 150).floor(); // Calculate based on item width
  //   return crossAxisCount < 3 ? 3 : crossAxisCount;
  // }
}
