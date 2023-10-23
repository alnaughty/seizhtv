// ignore_for_file: must_be_immutable

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:seizhtv/extensions/color.dart';
import 'package:seizhtv/extensions/m3u_entry.dart';
import 'package:seizhtv/globals/network_image_viewer.dart';
import 'package:seizhtv/globals/palette.dart';
import 'package:z_m3u_handler/z_m3u_handler.dart';

import '../../../../data_containers/favorites.dart';
import '../../../../globals/data.dart';
import '../../../../globals/favorite_button.dart';
import '../../../../globals/loader.dart';
import '../../../../globals/ui_additional.dart';

class LiveList extends StatefulWidget {
  LiveList(
      {super.key,
      required this.data,
      required this.onPressed,
      this.showSearchField = false,
      required this.searchClose});
  final List<M3uEntry> data;
  final ValueChanged<M3uEntry> onPressed;
  final bool searchClose;
  bool showSearchField;

  @override
  State<LiveList> createState() => LiveListState();
}

class LiveListState extends State<LiveList> with ColorPalette, UIAdditional {
  static final Favorites _vm = Favorites.instance;
  static final ZM3UHandler _handler = ZM3UHandler.instance;
  late final TextEditingController _search = TextEditingController();
  List<M3uEntry>? searchData;

  fetchFav() async {
    await _handler
        .getDataFrom(type: CollectionType.favorites, refId: refId!)
        .then((value) {
      if (value != null) {
        _vm.populate(value);
      }
    });
  }

  @override
  void initState() {
    searchData = widget.data;
    super.initState();
  }

  // String searchText = "";

  // void search(String text) {
  //   try {
  //     print("TEXT SEARCH IN LIVE: $text");
  //     searchText = text;
  //     endIndex = widget.data.length < 30 ? widget.data.length : 30;
  //     if (text.isEmpty) {
  //       _displayData = List.from(widget.data.unique());
  //       // .sublist(startIndex,
  //       //     endIndex < widget.data.length ? endIndex : widget.data.length));
  //     } else {
  //       text.isEmpty
  //           ? _displayData = List.from(widget.data.unique())
  //           : _displayData = List.from(widget.data
  //                   .unique()
  //                   .where(
  //                     (element) => element.title.toLowerCase().contains(
  //                           text.toLowerCase(),
  //                         ),
  //                   )
  //                   .toList()
  //               // .sublist(
  //               //     startIndex,
  //               //     endIndex > widget.data.length
  //               //         ? widget.data.length
  //               //         : endIndex),
  //               );
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
  // late int endIndex = widget.data.length;
  // //  < 30 ? widget.data.length : 30;
  // late List<M3uEntry> _displayData =
  //     List.from(widget.data.sublist(startIndex, endIndex));

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    if (widget.data.isEmpty) {
      return SeizhTvLoader(
        label: Text(
          "Retrieving_data".tr(),
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      );
    }
    return Column(
      children: [
        AnimatedPadding(
          duration: const Duration(milliseconds: 10),
          padding:
              EdgeInsets.symmetric(horizontal: widget.showSearchField ? 20 : 0),
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
                          child: widget.showSearchField
                              ? TextField(
                                  onChanged: (text) {
                                    if (text.isEmpty) {
                                      searchData = widget.data;
                                    } else {
                                      searchData = List.from(widget.data.where(
                                          (element) => element.title
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
                  itemCount:
                      searchData!.length, // add 1 for the loading indicator
                  itemBuilder: (context, index) {
                    final M3uEntry item = searchData![index];

                    return LayoutBuilder(builder: (context, c) {
                      final double w = c.maxWidth;
                      return Stack(
                        children: [
                          GestureDetector(
                            onTap: () {
                              widget.onPressed(item);
                              print(item.title);
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
                                                  BorderRadius.circular(10.0),
                                            ),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20),
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
                                                        Icons.close_rounded),
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
                              ))
                        ],
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
                  // controller: widget.controller..addListener(_scrollListener),
                ),
        ),
      ],
    );
  }

  // void _scrollListener() {
  //   if (widget.controller.offset >=
  //       widget.controller.position.maxScrollExtent) {
  //     print("DUGANG!");

  //     if (searchText == "") {
  //       setState(() {
  //         if (endIndex < widget.data.length) {
  //           endIndex += 5;
  //           if (endIndex > widget.data.length) {
  //             endIndex = widget.data.length;
  //           }
  //         }
  //         _displayData = List.from(widget.data.sublist(startIndex,
  //             endIndex > widget.data.length ? widget.data.length : endIndex));
  //         print(_displayData.length);
  //       });
  //       return;
  //     }
  //     return;
  //   }
  // }

  int calculateCrossAxisCount(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount =
        (screenWidth / 150).floor(); // Calculate based on item width
    return crossAxisCount < 3 ? 3 : crossAxisCount;
  }
}
