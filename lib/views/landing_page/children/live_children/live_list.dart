import 'package:flutter/material.dart';
import 'package:seizhtv/extensions/list.dart';
import 'package:seizhtv/globals/network_image_viewer.dart';
import 'package:seizhtv/globals/palette.dart';
import 'package:z_m3u_handler/z_m3u_handler.dart';

class LiveList extends StatefulWidget {
  const LiveList(
      {super.key,
      required this.data,
      required this.controller,
      required this.onPressed});
  final List<M3uEntry> data;
  final ScrollController controller;
  final ValueChanged<M3uEntry> onPressed;
  @override
  State<LiveList> createState() => LiveListState();
}

class LiveListState extends State<LiveList> with ColorPalette {
  String searchText = "";
  void search(String text) {
    try {
      print(text);
      searchText = text;
      endIndex = widget.data.length < 30 ? widget.data.length : 30;
      if (text.isEmpty) {
        _displayData = List.from(widget.data.unique().sublist(startIndex,
            endIndex < widget.data.length ? endIndex : widget.data.length));
      } else {
        _displayData = List.from(
          widget.data
              .unique()
              .where(
                (element) => element.title.toLowerCase().contains(
                      text.toLowerCase(),
                    ),
              )
              .toList()
              .sublist(
                  startIndex,
                  endIndex > widget.data.length
                      ? widget.data.length
                      : endIndex),
        );
      }
      _displayData.sort((a, b) => a.title.compareTo(b.title));

      print(_displayData.length);
      if (mounted) setState(() {});
    } on RangeError {
      _displayData = [];
      if (mounted) setState(() {});
    }
  }

  final int startIndex = 0;
  late int endIndex = widget.data.length < 30 ? widget.data.length : 30;
  late List<M3uEntry> _displayData =
      List.from(widget.data.sublist(startIndex, endIndex));

  @override
  Widget build(BuildContext context) {
    return _displayData.isEmpty
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
                childAspectRatio: .8, // optional, adjust as needed
                mainAxisSpacing: 10,
                crossAxisSpacing: 10),
            itemCount: _displayData.length, // add 1 for the loading indicator
            itemBuilder: (context, index) {
              final M3uEntry item = _displayData[index];
              return LayoutBuilder(builder: (context, c) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: MaterialButton(
                    onPressed: () {
                      widget.onPressed(item);
                      print(item.title);
                    },
                    padding: EdgeInsets.zero,
                    color: card,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ConstrainedBox(
                          constraints:
                              BoxConstraints(maxHeight: c.maxWidth * .8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: NetworkImageViewer(
                              url: item.attributes['tvg-logo'],
                              width: c.maxWidth,
                              height: c.maxWidth * .8,
                              color: highlight,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          item.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            height: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              });
              // return GridTile(
              //   header: Container(
              //     color: Colors.blue,
              //     width: 100,
              //     height: 85,
              //   ),
              //   footer: Align(
              //     alignment: AlignmentDirectional.topStart,
              // child: Text(
              //   item.title,
              //   maxLines: 2,
              //   overflow: TextOverflow.ellipsis,
              // ),
              //   ),
              //   child: Container(),
              // );
            },
            // listen for when the user scrolls to the end of the list
            controller: widget.controller..addListener(_scrollListener),
          );
  }

  void _scrollListener() {
    if (widget.controller.offset >=
        widget.controller.position.maxScrollExtent) {
      print("DUGANG!");
      setState(() {
        if (endIndex < widget.data.length) {
          endIndex += 5;
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

  int calculateCrossAxisCount(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount =
        (screenWidth / 150).floor(); // Calculate based on item width
    return crossAxisCount < 3 ? 3 : crossAxisCount;
  }
}
