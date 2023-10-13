// ignore_for_file: must_be_immutable

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:page_transition/page_transition.dart';
import 'package:seizhtv/extensions/color.dart';
import 'package:z_m3u_handler/z_m3u_handler.dart';
import '../../../../globals/network_image_viewer.dart';
import '../../../../globals/palette.dart';
import '../../../../globals/ui_additional.dart';
import '../../../../globals/video_loader.dart';
import 'details.dart';

class FavSeriesPage extends StatefulWidget {
  FavSeriesPage({super.key, required this.data, this.showSearchField = false});
  final List<ClassifiedData> data;
  bool showSearchField;

  @override
  State<FavSeriesPage> createState() => FavSeriesPageState();
}

class FavSeriesPageState extends State<FavSeriesPage>
    with ColorPalette, VideoLoader, UIAdditional {
  late final TextEditingController _search = TextEditingController();
  List<ClassifiedData>? searchData;

  @override
  void initState() {
    searchData = widget.data;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    if (widget.data.isEmpty) {
      return const Center(
        child: Text("No data added to favorites"),
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
                                            .where((element) => element.name
                                                .toLowerCase()
                                                .contains(text.toLowerCase())));
                                      }
                                      searchData!.sort(
                                          (a, b) => a.name.compareTo(b.name));
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
                      childAspectRatio: .8,
                      crossAxisSpacing: 10),
                  itemCount: searchData!.length,
                  itemBuilder: (context, index) {
                    final ClassifiedData item = searchData![index];

                    return LayoutBuilder(
                      builder: (context, c) {
                        final double w = c.maxWidth;
                        return Stack(
                          children: [
                            GestureDetector(
                              onTap: () {
                                String result1 = item.name.replaceAll(
                                    RegExp(
                                        r"[(]+[a-zA-Z]+[)]|[|]\s+[0-9]+\s[|]"),
                                    '');
                                String result2 = result1.replaceAll(
                                    RegExp(r"[|]+[a-zA-Z]+[|]|[a-zA-Z]+[|] "),
                                    '');

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
                                margin:
                                    const EdgeInsets.only(top: 10, right: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: NetworkImageViewer(
                                        url:
                                            item.data[0].attributes['tvg-logo'],
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
                  },
                ),
        ),
      ],
    );
  }

  int calculateCrossAxisCount(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount =
        (screenWidth / 150).floor(); // Calculate based on item width
    return crossAxisCount < 3 ? 3 : crossAxisCount;
  }
}
