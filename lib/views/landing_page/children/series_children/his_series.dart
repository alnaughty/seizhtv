import 'package:flutter/material.dart';
import 'package:seizhtv/extensions/m3u_entry.dart';
import 'package:z_m3u_handler/z_m3u_handler.dart';
import '../../../../data_containers/history.dart';
import '../../../../globals/data.dart';
import '../../../../globals/loader.dart';
import '../../../../globals/network_image_viewer.dart';
import '../../../../globals/palette.dart';
import '../../../../globals/ui_additional.dart';
import '../../../../globals/video_loader.dart';

class HistorySeriesPage extends StatefulWidget {
  const HistorySeriesPage({super.key});

  @override
  State<HistorySeriesPage> createState() => HistorySeriesPageState();
}

class HistorySeriesPageState extends State<HistorySeriesPage>
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
  void dispose() {
    super.dispose();
    _hisvm.dispose();
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
        final List<ClassifiedData> series = result.series;
        final List<M3uEntry> displayData =
            series.expand((element) => element.data).toList();

        if (series.isEmpty) {
          return const Center(
            child: Text("No Series history"),
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
                      // widget.onPressed(item);
                      print("${item.existsInFavorites("series")}");
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
