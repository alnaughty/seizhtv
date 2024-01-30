// ignore_for_file: deprecated_member_use, must_be_immutable, avoid_print, prefer_const_constructors_in_immutables

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:seizhtv/extensions/color.dart';
import 'package:seizhtv/extensions/m3u_entry.dart';
import 'package:z_m3u_handler/z_m3u_handler.dart';
import '../../../../data_containers/favorites.dart';
import '../../../../globals/data.dart';
import '../../../../globals/favorite_button.dart';
import '../../../../globals/network_image_viewer.dart';
import '../../../../globals/palette.dart';
import '../../../../globals/ui_additional.dart';
import '../../../../globals/video_loader.dart';

class LiveCategoryPage extends StatefulWidget {
  LiveCategoryPage(
      {super.key, required this.categorydata, required this.showsearchfield});

  final List<M3uEntry> categorydata;
  late bool showsearchfield;

  @override
  State<LiveCategoryPage> createState() => LiveCategoryPageState();
}

class LiveCategoryPageState extends State<LiveCategoryPage>
    with ColorPalette, VideoLoader, UIAdditional {
  static final Favorites _vm1 = Favorites.instance;
  static final ZM3UHandler _handler = ZM3UHandler.instance;
  final TextEditingController _search = TextEditingController();
  late List<M3uEntry> _displayData = [];
  String searchText = "";

  fetchFav() async {
    await _handler
        .getDataFrom(type: CollectionType.favorites, refId: refId!)
        .then((value) {
      if (value != null) {
        _vm1.populate(value);
      }
    });
  }

  // String searchText = "";

  // void search(String text) {
  //   try {
  //     print("TEXT SEARCH IN CATEGORY LIVE: $text");
  //     searchText = text;
  //     endIndex =
  //         widget.categorydata.length < 30 ? widget.categorydata.length : 30;
  //     if (text.isEmpty) {
  //       _displayData = List.from(widget.categorydata);
  //     } else {
  //       text.isEmpty
  //           ? _displayData = List.from(widget.categorydata)
  //           : _displayData = List.from(widget.categorydata
  //               .where(
  //                 (element) => element.title.toLowerCase().contains(
  //                       text.toLowerCase(),
  //                     ),
  //               )
  //               .toList());
  //     }
  //     _displayData.sort((a, b) => a.title.compareTo(b.title));

  //     print("DISPLAY DATA LENGHT: ${_displayData.length}");
  //     if (mounted) setState(() {});
  //   } on RangeError {
  //     _displayData = [];
  //     if (mounted) setState(() {});
  //   }
  // }

  // final int startIndex = 0;
  // late int endIndex = 0;
  // widget.categorydata.length = List.from(widget.categorydata.sublist(startIndex, endIndex));

  @override
  Widget build(BuildContext context) {
    // return
    //  StreamBuilder(
    //   stream: _vm.stream,
    //   builder: (context, snapshot) {
    // if (snapshot.hasError || !snapshot.hasData) {
    //   if (!snapshot.hasData) {
    //     return const SeizhTvLoader(
    //       hasBackgroundColor: false,
    //     );
    //   }
    //   return Container();
    // }

    // final CategorizedM3UData result = snapshot.data!;
    // final List<ClassifiedData> live = result.live;
    // data = live
    //     .where(
    //         (element) => element.name.contains(widget.category.trimRight()))
    //     .expand((element) => element.data)
    //     .toList()
    //   ..sort((a, b) => a.title.compareTo(b.title));
    // // _displayData = data;

    return Column(
      children: [
        widget.showsearchfield == true
            ? AnimatedPadding(
                duration: const Duration(milliseconds: 400),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  height: 50,
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
                                blurRadius: 2,
                              )
                            ],
                          ),
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                "assets/icons/search.svg",
                                height: 20,
                                width: 20,
                                color: white,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    child: TextField(
                                      onChanged: (text) {
                                        print("SEARCH TEXT: $text");
                                        if (text.isEmpty) {
                                          _displayData =
                                              List.from(widget.categorydata);
                                        } else {
                                          text.isEmpty
                                              ? _displayData =
                                                  List.from(widget.categorydata)
                                              : _displayData =
                                                  List.from(widget.categorydata
                                                      .where(
                                                        (element) => element
                                                            .title
                                                            .toLowerCase()
                                                            .contains(
                                                              text.toLowerCase(),
                                                            ),
                                                      )
                                                      .toList());
                                        }
                                        if (mounted) setState(() {});
                                        searchText = text;
                                      },
                                      cursorColor: orange,
                                      controller: _search,
                                      decoration: InputDecoration(
                                        hintText: "Search".tr(),
                                      ),
                                    )),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            searchText = "";
                            _search.text = "";
                            widget.showsearchfield = false;
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
              )
            : const SizedBox(),
        const SizedBox(height: 10),
        Expanded(
          child: searchText != "" && _displayData.isEmpty
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
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10),
                  itemCount: searchText == ""
                      ? widget.categorydata.length
                      : _displayData.length,
                  itemBuilder: (context, index) {
                    print("DISPLAY DATA LENGHT: ${_displayData.length}");
                    print("DATA LENGHT: ${widget.categorydata.length}");
                    final M3uEntry item = searchText == ""
                        ? widget.categorydata[index]
                        : _displayData[index];
                    // _displayData[index];

                    return LayoutBuilder(
                      builder: (context, c) {
                        final double w = c.maxWidth;
                        return Stack(
                          children: [
                            GestureDetector(
                              onTap: () async {
                                print(item.title);
                                item.addToHistory(refId!);
                                await loadVideo(context, item);
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
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: SizedBox(
                                height: 25,
                                width: 25,
                                child: FavoriteIconButton(
                                  onPressedCallback: (bool f) async {
                                    if (f) {
                                      showDialog(
                                        barrierDismissible: false,
                                        context: context,
                                        builder: (BuildContext context) {
                                          Future.delayed(
                                            const Duration(seconds: 3),
                                            () {
                                              Navigator.of(context).pop(true);
                                            },
                                          );
                                          return Dialog(
                                            alignment: Alignment.topCenter,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                10.0,
                                              ),
                                            ),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 20,
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    "Added_to_Favorites".tr(),
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  IconButton(
                                                    padding:
                                                        const EdgeInsets.all(0),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    icon: const Icon(
                                                      Icons.close_rounded,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                      await item.addToFavorites(refId!);
                                    } else {
                                      await item.removeFromFavorites(refId!);
                                    }
                                    await fetchFav();
                                  },
                                  initValue: item.existsInFavorites("live"),
                                  iconSize: 20,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
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
