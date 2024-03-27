// ignore_for_file: must_be_immutable, avoid_print

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:seizhtv/extensions/m3u_entry.dart';
import 'package:z_m3u_handler/z_m3u_handler.dart';
import '../../../../data_containers/favorites.dart';
import '../../../../globals/data.dart';
import '../../../../globals/favorite_button.dart';
import '../../../../globals/network_image_viewer.dart';
import '../../../../globals/palette.dart';
import '../../../../globals/ui_additional.dart';
import '../../../../globals/video_loader.dart';
import 'details.dart';

class FaveMoviePage extends StatefulWidget {
  FaveMoviePage({super.key, required this.data, this.showSearchField = false});
  final List<M3uEntry> data;
  bool showSearchField;

  @override
  State<FaveMoviePage> createState() => FaveMoviePageState();
}

class FaveMoviePageState extends State<FaveMoviePage>
    with ColorPalette, VideoLoader, UIAdditional {
  final Favorites _favvm = Favorites.instance;
  static final ZM3UHandler _handler = ZM3UHandler.instance;
  List<M3uEntry>? searchData;

  fetchFav() async {
    await _handler
        .getDataFrom(type: CollectionType.favorites, refId: refId!)
        .then((value) {
      if (value != null) {
        _favvm.populate(value);
      }
    });
  }

  String searchText = "";

  void search(String text) {
    try {
      print("TEXT SEARCH IN CATEGORY LIVE: $text");
      searchText = text;
      endIndex = widget.data.length < 30 ? widget.data.length : 30;
      if (text.isEmpty) {
        _displayData = List.from(widget.data);
      } else {
        text.isEmpty
            ? _displayData = List.from(widget.data)
            : _displayData = List.from(widget.data
                .where((element) =>
                    element.title.toLowerCase().contains(text.toLowerCase()))
                .toList());
      }
      _displayData.sort((a, b) => a.title.compareTo(b.title));

      print("DISPLAY DATA LENGHT: ${_displayData.length}");
      if (mounted) setState(() {});
    } on RangeError {
      _displayData = [];
      if (mounted) setState(() {});
    }
  }

  final int startIndex = 0;
  late int endIndex = widget.data.length;
  late List<M3uEntry> _displayData =
      List.from(widget.data.sublist(startIndex, endIndex));

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return const Center(
        child: Text("No data added to favorites"),
      );
    }
    return Column(
      children: [
        Expanded(
          child: _displayData.isEmpty
              ? Center(
                  child: Text(
                    "No Result Found for `$searchText`",
                    style: TextStyle(
                      color: Colors.white.withOpacity(.5),
                    ),
                  ),
                )
              : GridView.builder(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: calculateCrossAxisCount(context),
                      childAspectRatio: .8,
                      crossAxisSpacing: 10),
                  itemCount: _displayData.length,
                  itemBuilder: (context, index) {
                    final M3uEntry item = _displayData[index];

                    return Stack(
                      children: [
                        GestureDetector(
                          onTap: () {
                            String result1 = item.title.replaceAll(
                                RegExp(
                                    r"[0-9]|[(]+[0-9]+[)]|[|]\s+[0-9]+\s[|]"),
                                '');
                            String result2 = result1.replaceAll(
                                RegExp(r"[|]+[a-zA-Z]+[|]|[a-zA-Z]+[|] "), '');

                            Navigator.push(
                              context,
                              PageTransition(
                                child: MovieDetailsPage(
                                  data: item,
                                  title: result2,
                                ),
                                type: PageTransitionType.rightToLeft,
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(top: 10, right: 10),
                            child: LayoutBuilder(
                              builder: (context, c) {
                                final double w = c.maxWidth;
                                final double h = c.maxHeight;
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: NetworkImageViewer(
                                    url: item.attributes['tvg-logo'],
                                    width: w,
                                    height: h,
                                    fit: BoxFit.cover,
                                    color: highlight,
                                    title: item.title,
                                  ),
                                );
                              },
                            ),
                            // Column(
                            //   crossAxisAlignment: CrossAxisAlignment.start,
                            //   mainAxisAlignment: MainAxisAlignment.start,
                            //   children: [
                            //     ClipRRect(
                            //       borderRadius: BorderRadius.circular(10),
                            //       child: NetworkImageViewer(
                            //         url: item.attributes['tvg-logo'],
                            //         width: w,
                            //         height: 75,
                            //         color: highlight,
                            //         fit: BoxFit.cover,
                            //       ),
                            //     ),
                            //     const SizedBox(height: 7),
                            //     Text(
                            //       item.title,
                            //       maxLines: 2,
                            //       overflow: TextOverflow.ellipsis,
                            //       style: const TextStyle(height: 1),
                            //     ),
                            //   ],
                            // ),
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
                                            Navigator.of(context).pop(true);
                                          },
                                        );
                                        return Dialog(
                                          alignment: Alignment.topCenter,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10.0,
                                            ),
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 20,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  "Added_to_Favorites".tr(),
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                IconButton(
                                                  padding:
                                                      const EdgeInsets.all(0),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
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
                                    await item.addToFavorites(refId!);
                                  } else {
                                    await item.removeFromFavorites(refId!);
                                  }
                                  await fetchFav();
                                },
                                initValue: item.existsInFavorites("movie"),
                                iconSize: 20,
                              ),
                            ))
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }

  int calculateCrossAxisCount(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount =
        (screenWidth / 150).floor(); // Calculate based on item width
    return crossAxisCount < 3 ? 3 : crossAxisCount;
  }
}

  // return ListView.separated(
            //   shrinkWrap: true,
            //   physics: const NeverScrollableScrollPhysics(),
            //   padding: const EdgeInsets.all(0),
            //   itemCount: item.length,
            //   itemBuilder: (c, x) {
            //     final M3uEntry d = item[x];

            //     return ListTile(
            //       title: Text(d.title),
            //       onTap: () async {
            // String result1 = d.title.replaceAll(
            //     RegExp(r"[(]+[0-9]+[)]|[|]\s+[0-9]+\s[|]"), '');
            // String result2 = result1.replaceAll(
            //     RegExp(r"[|]+[a-zA-Z]+[|]|[a-zA-Z]+[|] "), '');

            // Navigator.push(
            //   context,
            //   PageTransition(
            //     child: MovieDetailsPage(
            //       data: d,
            //       title: result2,
            //     ),
            //     type: PageTransitionType.rightToLeft,
            //   ),
            // );
            //       },
            //       leading: ClipRRect(
            //         borderRadius: BorderRadius.circular(5),
            //         child: SizedBox(
            //           width: 85,
            //           child: NetworkImageViewer(
            //             url: d.attributes['tvg-logo']!,
            //             width: 85,
            //             height: 60,
            //             fit: BoxFit.cover,
            //             color: highlight,
            //           ),
            //         ),
            //       ),
            //     );
            //   },
            //   separatorBuilder: (_, __) => const SizedBox(height: 10),
            // );



        // return GridView.builder(
        //   physics: const ClampingScrollPhysics(),
        //   padding: const EdgeInsets.symmetric(horizontal: 20),
        //   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        //       crossAxisCount: calculateCrossAxisCount(context),
        //       childAspectRatio: .8, // optional, adjust as needed
        //       mainAxisSpacing: 15,
        //       crossAxisSpacing: 15),
        //   itemCount: displayData.length,
        //   itemBuilder: (context, i) {
        //     final M3uEntry item = displayData[i];

        //     return GestureDetector(
        //       onTap: () {
        //         print("MOVIE TITLE: ${movie[i].data[0].title}");
        //         print("MOVIE DATA: ${movie[i].data}");
        //       },
        //       child: Container(
        //         color: Colors.red,
        //         height: 50,
        //       ),
        //     );
        //     // return LayoutBuilder(
        //     //   builder: (context, c) {
        //     //     return ClipRRect(
        //     //       borderRadius: BorderRadius.circular(5),
        //     //       child: MaterialButton(
        //     //         onPressed: () {
        //     //           // widget.onPressed(item);
        //     //           print("MOVIE TITLE: ${displayData.length}");
        //     //           print("MOVIE DATA: ${movie[index]}");
        //     //           String str1 = item.title;
        //     //           String result1 = str1.replaceAll(
        //     //               RegExp(r"[(]+[0-9]+[)]|[|]\s+[0-9]+\s[|]"), '');
        //     //           String result2 = result1.replaceAll(
        //     //               RegExp(r"[|]+[a-zA-Z]+[|]|[a-zA-Z]+[|] "), '');

        //     //           Navigator.push(
        //     //             context,
        //     //             PageTransition(
        //     //               child: MovieDetailsPage(
        //     //                 data: movie[index],
        //     //                 title: result2,
        //     //               ),
        //     //               type: PageTransitionType.leftToRight,
        //     //             ),
        //     //           );
        //     //         },
        //     //         padding: EdgeInsets.zero,
        //     //         color: card,
        //     //         child: Column(
        //     //           crossAxisAlignment: CrossAxisAlignment.start,
        //     //           mainAxisAlignment: MainAxisAlignment.start,
        //     //           children: [
        //     //             ConstrainedBox(
        //     //               constraints:
        //     //                   BoxConstraints(maxHeight: c.maxWidth * .8),
        //     //               child: ClipRRect(
        //     //                 borderRadius: BorderRadius.circular(10),
        //     //                 child: NetworkImageViewer(
        //     //                   url: item.attributes['tvg-logo'],
        //     //                   width: c.maxWidth,
        //     //                   height: c.maxWidth * .8,
        //     //                   color: highlight,
        //     //                   fit: BoxFit.cover,
        //     //                 ),
        //     //               ),
        //     //             ),
        //     //             const SizedBox(
        //     //               height: 10,
        //     //             ),
        //     //             Text(
        //     //               item.title,
        //     //               maxLines: 2,
        //     //               overflow: TextOverflow.ellipsis,
        //     //               style: const TextStyle(
        //     //                 height: 1,
        //     //               ),
        //     //             ),
        //     //           ],
        //     //         ),
        //     //       ),
        //     //     );
        //     //   },
        //     // );
        //   },
        // );
      
