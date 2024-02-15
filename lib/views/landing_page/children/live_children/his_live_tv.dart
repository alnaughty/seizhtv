// ignore_for_file: avoid_print, must_be_immutable

import 'package:flutter/material.dart';
import 'package:seizhtv/extensions/list.dart';
import 'package:seizhtv/extensions/m3u_entry.dart';
import 'package:z_m3u_handler/z_m3u_handler.dart';
import '../../../../globals/network_image_viewer.dart';
import '../../../../globals/palette.dart';
import '../../../../globals/ui_additional.dart';
import '../../../../globals/video_loader.dart';

class HistoryLiveTvPage extends StatefulWidget {
  HistoryLiveTvPage(
      {super.key,
      required this.data,
      required this.onPressed,
      this.showSearchField = false});

  final List<M3uEntry> data;
  final ValueChanged<M3uEntry> onPressed;
  bool showSearchField;

  @override
  State<HistoryLiveTvPage> createState() => HistoryLiveTvPageState();
}

class HistoryLiveTvPageState extends State<HistoryLiveTvPage>
    with ColorPalette, VideoLoader, UIAdditional {
  String searchText = "";

  void search(String text) {
    try {
      print("TEXT SEARCH IN CATEGORY LIVE: $text");
      searchText = text;
      endIndex = widget.data.length < 30 ? widget.data.length : 30;
      if (text.isEmpty) {
        _displayData = List.from(widget.data.unique());
      } else {
        text.isEmpty
            ? _displayData = List.from(widget.data.unique())
            : _displayData = List.from(widget.data
                .unique()
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
                final M3uEntry item = _displayData[index];

                return LayoutBuilder(builder: (context, c) {
                  final double w = c.maxWidth;
                  return GestureDetector(
                    onTap: () {
                      widget.onPressed(item);
                      print("${item.existsInFavorites("live")}");
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: NetworkImageViewer(
                            url: item.attributes['tvg-logo'],
                            width: w,
                            height: 70,
                            color: highlight,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          item.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(height: 1),
                        ),
                      ],
                    ),
                  );
                });
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
