// ignore_for_file: avoid_print

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
  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return const Center(
        child: Text("No Movie history"),
      );
    }
    return GridView.builder(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: calculateCrossAxisCount(context),
          childAspectRatio: .8,
          crossAxisSpacing: 8),
      itemCount: widget.data.length,
      itemBuilder: (context, index) {
        final M3uEntry item = widget.data[index];

        return LayoutBuilder(builder: (context, c) {
          final double w = c.maxWidth;
          return GestureDetector(
            onTap: () {
              String result1 = item.title.replaceAll(
                  RegExp(r"[0-9]|[(]+[0-9]+[)]|[|]\s+[0-9]+\s[|]"), '');
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: NetworkImageViewer(
                      url: item.attributes['tvg-logo'],
                      width: w,
                      height: 75,
                      color: highlight,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(height: 1),
                  ),
                ],
              ),
            ),
          );
          // MaterialButton(
          //   onPressed: () {
          //     String result1 = item.title.replaceAll(
          //         RegExp(r"[(]+[0-9]+[)]|[|]\s+[0-9]+\s[|]"), '');
          //     String result2 = result1.replaceAll(
          //         RegExp(r"[|]+[a-zA-Z]+[|]|[a-zA-Z]+[|] "), '');

          //     Navigator.push(
          //       context,
          //       PageTransition(
          //         child: MovieDetailsPage(
          //           data: item,
          //           title: result2,
          //         ),
          //         type: PageTransitionType.rightToLeft,
          //       ),
          //     );
          //   },
          //   padding: EdgeInsets.zero,
          //   color: card,
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     mainAxisAlignment: MainAxisAlignment.start,
          //     children: [
          //       ConstrainedBox(
          //         constraints:
          //             BoxConstraints(maxHeight: c.maxWidth * .7),
          //         child: ClipRRect(
          //           borderRadius: BorderRadius.circular(10),
          //           child: NetworkImageViewer(
          //             url: item.attributes['tvg-logo'],
          //             width: c.maxWidth,
          //             height: c.maxWidth * .9,
          //             color: highlight,
          //             fit: BoxFit.cover,
          //           ),
          //         ),
          //       ),
          //       const SizedBox(
          //         height: 5,
          //       ),
          //       Text(
          //         item.title,
          //         maxLines: 2,
          //         overflow: TextOverflow.ellipsis,
          //         style: const TextStyle(
          //           height: 1,
          //         ),
          //       ),
          //     ],
          //   ),
          // );
        });
      },
    );
  }

  int calculateCrossAxisCount(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount =
        (screenWidth / 150).floor(); // Calculate based on item width
    return crossAxisCount < 3 ? 3 : crossAxisCount;
  }
}
