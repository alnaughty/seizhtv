// ignore_for_file: avoid_print, must_be_immutable

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:seizhtv/extensions/color.dart';
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

  late final TextEditingController _search = TextEditingController();
  List<M3uEntry>? searchData;

  @override
  void initState() {
    searchData = widget.data;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
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
    return Column(
      children: [
        SizedBox(
          child: AnimatedPadding(
            duration: const Duration(milliseconds: 10),
            padding: EdgeInsets.symmetric(
                horizontal: widget.showSearchField ? 20 : 0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 10),
              height: widget.showSearchField ? size.height * .08 : 0,
              width: double.maxFinite,
              child: Row(
                children: [
                  Expanded(
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
                              blurRadius: 2)
                        ]),
                    child: Row(
                      children: [
                        SvgPicture.asset("assets/icons/search.svg",
                            height: 20, width: 20, color: white),
                        const SizedBox(width: 10),
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: widget.showSearchField
                                ? TextField(
                                    onChanged: (text) {
                                      if (text.isEmpty) {
                                        searchData = widget.data;
                                      } else {
                                        searchData = List.from(widget.data
                                            .where((element) => element.title
                                                .toLowerCase()
                                                .contains(text.toLowerCase())));
                                      }
                                      searchData!.sort(
                                          (a, b) => a.title.compareTo(b.title));
                                      if (mounted) {
                                        setState(() {});
                                      }
                                    },
                                    cursorColor: orange,
                                    controller: _search,
                                    decoration: InputDecoration(
                                      hintText: "Search".tr(),
                                    ),
                                  )
                                : Container(),
                          ),
                        ),
                      ],
                    ),
                  )),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _search.clear();
                        searchData = widget.data;
                        widget.showSearchField = !widget.showSearchField;
                      });
                    },
                    child: Text(
                      "Cancel".tr(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (widget.showSearchField) ...{
          const SizedBox(height: 15),
        },
        Expanded(
          child: searchData!.isEmpty
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
                      childAspectRatio: .8, // optional, adjust as needed
                      // mainAxisSpacing: 10,
                      crossAxisSpacing: 10),
                  itemCount: searchData!.length,
                  itemBuilder: (context, index) {
                    final M3uEntry item = searchData![index];

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
        ),
      ],
    );
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
