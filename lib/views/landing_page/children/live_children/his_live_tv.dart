// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:seizhtv/extensions/m3u_entry.dart';
import 'package:z_m3u_handler/z_m3u_handler.dart';
import '../../../../globals/network_image_viewer.dart';
import '../../../../globals/palette.dart';
import '../../../../globals/ui_additional.dart';
import '../../../../globals/video_loader.dart';

class HistoryLiveTvPage extends StatefulWidget {
  const HistoryLiveTvPage(
      {super.key, required this.data, required this.onPressed});

  final List<M3uEntry> data;
  final ValueChanged<M3uEntry> onPressed;

  @override
  State<HistoryLiveTvPage> createState() => HistoryLiveTvPageState();
}

class HistoryLiveTvPageState extends State<HistoryLiveTvPage>
    with ColorPalette, VideoLoader, UIAdditional {
  // final History _hisvm = History.instance;
  // static final ZM3UHandler _handler = ZM3UHandler.instance;

  // Future<void> fetchHis() async {
  //   await _handler
  //       .getDataFrom(type: CollectionType.history, refId: refId!)
  //       .then((value) {
  //     if (value != null) {
  //       _hisvm.populate(value);
  //     }
  //   });
  // }

  // @override
  // void initState() {
  //   WidgetsBinding.instance.addPostFrameCallback((_) async {
  //     await fetchHis();
  //   });
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    // return StreamBuilder<CategorizedM3UData>(
    //   stream: _hisvm.stream,
    //   builder: (_, snapshot) {
    //     if (snapshot.hasError || !snapshot.hasData) {
    //       if (!snapshot.hasData) {
    //         return const SeizhTvLoader(
    //           hasBackgroundColor: false,
    //         );
    //       }
    //       return Container();
    //     }
    //     final CategorizedM3UData result = snapshot.data!;
    //     final List<ClassifiedData> live = result.live;
    //     final List<M3uEntry> displayData =
    //         live.expand((element) => element.data).toList();

    //     print("HISTORY: ${displayData.length}");

    if (widget.data.isEmpty) {
      return const Center(
        child: Text("No channel history"),
      );
    }
    return GridView.builder(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: calculateCrossAxisCount(context),
            childAspectRatio: .8, // optional, adjust as needed
            // mainAxisSpacing: 10,
            crossAxisSpacing: 10),
        itemCount: widget.data.length,
        itemBuilder: (context, index) {
          final M3uEntry item = widget.data[index];

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
        });
    //   },
    // );
  }

  int calculateCrossAxisCount(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount =
        (screenWidth / 150).floor(); // Calculate based on item width
    return crossAxisCount < 3 ? 3 : crossAxisCount;
  }
}
