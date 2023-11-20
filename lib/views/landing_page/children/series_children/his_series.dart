// ignore_for_file: must_be_immutable, avoid_print

import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:z_m3u_handler/z_m3u_handler.dart';
import '../../../../globals/network_image_viewer.dart';
import '../../../../globals/palette.dart';
import '../../../../globals/ui_additional.dart';
import '../../../../globals/video_loader.dart';
import 'details.dart';

class HistorySeriesPage extends StatefulWidget {
  HistorySeriesPage(
      {super.key, required this.data, this.showSearchField = false});
  final List<ClassifiedData> data;
  bool showSearchField;

  @override
  State<HistorySeriesPage> createState() => HistorySeriesPageState();
}

class HistorySeriesPageState extends State<HistorySeriesPage>
    with ColorPalette, VideoLoader, UIAdditional {
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
                    element.name.toLowerCase().contains(text.toLowerCase()))
                .toList());
      }
      _displayData.sort((a, b) => a.name.compareTo(b.name));

      print("DISPLAY DATA LENGHT: ${_displayData.length}");
      if (mounted) setState(() {});
    } on RangeError {
      _displayData = [];
      if (mounted) setState(() {});
    }
  }

  final int startIndex = 0;
  late int endIndex = widget.data.length;
  late List<ClassifiedData> _displayData =
      List.from(widget.data.sublist(startIndex, endIndex));

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return const Center(
        child: Text("No Series history"),
      );
    }
    return Expanded(
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
                final ClassifiedData item = _displayData[index];

                return LayoutBuilder(
                  builder: (context, c) {
                    final double w = c.maxWidth;
                    return Stack(
                      children: [
                        GestureDetector(
                          onTap: () {
                            String result1 = item.name.replaceAll(
                                RegExp(r"[(]+[a-zA-Z]+[)]|[|]\s+[0-9]+\s[|]"),
                                '');
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
                                    height: 75,
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
              }),
    );
  }

  int calculateCrossAxisCount(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount =
        (screenWidth / 150).floor(); // Calculate based on item width
    return crossAxisCount < 3 ? 3 : crossAxisCount;
  }
}
