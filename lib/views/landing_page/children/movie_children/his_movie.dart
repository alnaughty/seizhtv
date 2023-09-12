// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:seizhtv/extensions/m3u_entry.dart';
import 'package:z_m3u_handler/z_m3u_handler.dart';
import '../../../../data_containers/history.dart';
import '../../../../globals/data.dart';
import '../../../../globals/loader.dart';
import '../../../../globals/network_image_viewer.dart';
import '../../../../globals/palette.dart';
import '../../../../globals/ui_additional.dart';
import '../../../../globals/video_loader.dart';
import 'details.dart';

class HistoryMoviePage extends StatefulWidget {
  const HistoryMoviePage({super.key});

  @override
  State<HistoryMoviePage> createState() => HistoryMoviePageState();
}

class HistoryMoviePageState extends State<HistoryMoviePage>
    with ColorPalette, VideoLoader, UIAdditional {
  final History _hisvm = History.instance;
  static final ZM3UHandler _handler = ZM3UHandler.instance;

  Future<void> fetchHis() async {
    await _handler
        .getDataFrom(type: CollectionType.history, refId: refId!)
        .then((value) {
      if (value != null) {
        _hisvm.populate(value);
      }
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await fetchHis();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<CategorizedM3UData>(
      stream: _hisvm.stream,
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
        final List<ClassifiedData> movies = result.movies;
        final List<M3uEntry> displayData =
            movies.expand((element) => element.data).toList();

        if (movies.isEmpty) {
          return const Center(
            child: Text("No Movie history"),
          );
        }
        return GridView.builder(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: calculateCrossAxisCount(context),
                childAspectRatio: .8, // optional, adjust as needed
                mainAxisSpacing: 10,
                crossAxisSpacing: 10),
            itemCount: displayData.length,
            itemBuilder: (context, index) {
              final M3uEntry item = displayData[index];

              return LayoutBuilder(builder: (context, c) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: MaterialButton(
                    onPressed: () {
                      String result1 = item.title.replaceAll(
                          RegExp(r"[(]+[0-9]+[)]|[|]\s+[0-9]+\s[|]"), '');
                      String result2 = result1.replaceAll(
                          RegExp(r"[|]+[a-zA-Z]+[|]|[a-zA-Z]+[|] "), '');
                      // widget.onPressed(item);
                      print("${item.existsInFavorites("movie")}");
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
