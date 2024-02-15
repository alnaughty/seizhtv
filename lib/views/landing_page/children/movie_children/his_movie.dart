// ignore_for_file: avoid_print, deprecated_member_use, must_be_immutable

import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:z_m3u_handler/z_m3u_handler.dart';
import '../../../../globals/network_image_viewer.dart';
import '../../../../globals/palette.dart';
import '../../../../globals/ui_additional.dart';
import '../../../../globals/video_loader.dart';
import 'details.dart';

class HistoryMoviePage extends StatefulWidget {
  const HistoryMoviePage({super.key, required this.data});
  final List<M3uEntry> data;

  @override
  State<HistoryMoviePage> createState() => HistoryMoviePageState();
}

class HistoryMoviePageState extends State<HistoryMoviePage>
    with ColorPalette, VideoLoader, UIAdditional {
  late final TextEditingController _search = TextEditingController();
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
        child: Text("No Movie history"),
      );
    }
    return Column(
      children: [
        Expanded(
          child: _displayData.isEmpty
              ? Center(
                  child: Text(
                    "No Result Found for `${_search.text}`",
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
                      crossAxisSpacing: 8),
                  itemCount: _displayData.length,
                  itemBuilder: (context, index) {
                    final M3uEntry item = _displayData[index];

                
                        return GestureDetector(
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
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              child: NetworkImageViewer(
                                                url: item.attributes['tvg-logo'],
                                                width: w,
                                                height:h, 
                                                fit: BoxFit.cover,
                                                color: highlight,
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
                        );
                      },
                    ),
        ),
      ],
    );
  }

  int calculateCrossAxisCount(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = (screenWidth / 150).floor();
    return crossAxisCount < 3 ? 3 : crossAxisCount;
  }
}
