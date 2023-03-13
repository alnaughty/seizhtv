import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:seizhtv/data_containers/loaded_m3u_data.dart';
import 'package:seizhtv/extensions/color.dart';
import 'package:seizhtv/globals/data.dart';
import 'package:seizhtv/globals/loader.dart';
import 'package:seizhtv/globals/network_image_viewer.dart';
import 'package:seizhtv/globals/palette.dart';
import 'package:seizhtv/globals/ui_additional.dart';
import 'package:seizhtv/globals/video_loader.dart';
import 'package:seizhtv/views/landing_page/children/series_children/series_details_sheet.dart';
import 'package:z_m3u_handler/z_m3u_handler.dart';

class SearchSeries extends StatefulWidget {
  const SearchSeries({super.key});

  @override
  State<SearchSeries> createState() => _SearchSeriesState();
}

class _SearchSeriesState extends State<SearchSeries>
    with ColorPalette, VideoLoader, UIAdditional {
  final LoadedM3uData _vm = LoadedM3uData.instance;
  late final ScrollController _scrollController;
  late final TextEditingController _search;
  List<ClassifiedData>? allData;
  List<ClassifiedData>? _displayData;
  initPlatform() {
    _vm.stream.listen((event) {
      allData = List.from(event.series);
      _displayData = List.from(event.series);
      _displayData!.sort((a, b) => a.name.compareTo(b.name));
      if (mounted) setState(() {});
      print(_displayData?.length);
    });
  }

  @override
  void initState() {
    _search = TextEditingController();
    _scrollController = ScrollController();
    // TODO: implement initState
    initPlatform();
    super.initState();
  }

  @override
  void dispose() {
    _search.dispose();
    _scrollController.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: card,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Row(
          children: [
            SvgPicture.asset(
              "assets/images/logo-full.svg",
              height: 25,
              color: orange,
            ),
            Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 10,
              ),
              height: 25,
              width: 1.5,
              color: Colors.white.withOpacity(.5),
            ),
            Text(
              "Series Search".toUpperCase(),
              style: TextStyle(
                color: white,
                fontSize: 15,
                height: 1,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      body: _displayData == null
          ? const Center(
              child: SeizhTvLoader(
                hasBackgroundColor: false,
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                        color: highlight,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: highlight.darken().withOpacity(1),
                            offset: const Offset(2, 2),
                            blurRadius: 2,
                          )
                        ]),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          "assets/icons/search.svg",
                          height: 20,
                          width: 20,
                          color: white,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: TextField(
                            onChanged: (text) {
                              if (text.isEmpty) {
                                _displayData = allData;
                              } else {
                                _displayData = List.from(
                                  allData!.where(
                                    (element) =>
                                        element.name.toLowerCase().contains(
                                              text.toLowerCase(),
                                            ),
                                  ),
                                );
                                _displayData!
                                    .sort((a, b) => a.name.compareTo(b.name));
                              }
                              if (mounted) setState(() {});
                            },
                            cursorColor: orange,
                            controller: _search,
                            decoration: const InputDecoration(
                              hintText: "Search",
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: _displayData!.isEmpty
                      ? Center(
                          child: Text("No Result found for `${_search.text}`"),
                        )
                      : Scrollbar(
                          controller: _scrollController,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: LayoutBuilder(
                              builder: (context, c) {
                                final double w = c.maxWidth;
                                return GridView.count(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  crossAxisCount: 3,
                                  mainAxisSpacing: 10,
                                  crossAxisSpacing: 10,
                                  childAspectRatio: .7,
                                  children: [
                                    ..._displayData!.map(
                                      (e) {
                                        return LayoutBuilder(
                                          builder: (_, c) {
                                            final double w = c.maxWidth;
                                            final double h = c.maxHeight;
                                            return ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              child: MaterialButton(
                                                padding: EdgeInsets.zero,
                                                onPressed: () async {
                                                  await showModalBottomSheet(
                                                    context: context,
                                                    isDismissible: true,
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    isScrollControlled: true,
                                                    builder: (_) =>
                                                        SeriesDetailsSheet(
                                                      data: e,
                                                      onLoadVideo: (M3uEntry
                                                          entry) async {
                                                        Navigator.of(context)
                                                            .pop(null);
                                                        await loadVideo(
                                                            context, entry);
                                                        await entry
                                                            .addToHistory(
                                                                refId!);
                                                      },
                                                    ),
                                                  );
                                                },
                                                child: NetworkImageViewer(
                                                  url: e.data[0]
                                                      .attributes['tvg-logo']!,
                                                  height: h,
                                                  width: w,
                                                  fit: BoxFit.cover,
                                                  color: card,
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    )
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                )
              ],
            ),
    );
  }
}
