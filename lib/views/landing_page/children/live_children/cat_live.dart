// ignore_for_file: deprecated_member_use, must_be_immutable, avoid_print

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:seizhtv/extensions/m3u_entry.dart';
import 'package:z_m3u_handler/z_m3u_handler.dart';
import '../../../../data_containers/favorites.dart';
import '../../../../data_containers/loaded_m3u_data.dart';
import '../../../../globals/data.dart';
import '../../../../globals/favorite_button.dart';
import '../../../../globals/loader.dart';
import '../../../../globals/network_image_viewer.dart';
import '../../../../globals/palette.dart';
import '../../../../globals/ui_additional.dart';
import '../../../../globals/video_loader.dart';

class LiveCategoryPage extends StatefulWidget {
  LiveCategoryPage(
      {super.key,
      required this.category,
      this.showSearchField = false,
      required this.categoryData});

  final String category;
  bool showSearchField;
  final List<M3uEntry> categoryData;

  @override
  State<LiveCategoryPage> createState() => LiveCategoryPageState();
}

class LiveCategoryPageState extends State<LiveCategoryPage>
    with ColorPalette, VideoLoader, UIAdditional {
  final LoadedM3uData _vm = LoadedM3uData.instance;
  static final Favorites _vm1 = Favorites.instance;
  static final ZM3UHandler _handler = ZM3UHandler.instance;
  late List<M3uEntry> data = [];
  fetchFav() async {
    await _handler
        .getDataFrom(type: CollectionType.favorites, refId: refId!)
        .then((value) {
      if (value != null) {
        _vm1.populate(value);
      }
    });
  }

  String searchText = "";

  void search(String text) {
    try {
      print("TEXT SEARCH IN CATEGORY LIVE: $text");
      searchText = text;
      endIndex =
          widget.categoryData.length < 30 ? widget.categoryData.length : 30;
      if (text.isEmpty) {
        _displayData = List.from(widget.categoryData);
      } else {
        text.isEmpty
            ? _displayData = List.from(widget.categoryData)
            : _displayData = List.from(widget.categoryData
                .where(
                  (element) => element.title.toLowerCase().contains(
                        text.toLowerCase(),
                      ),
                )
                .toList());
      }
      _displayData.sort((a, b) => a.title.compareTo(b.title));

      print("DISPLAY DATA LENGHT: ${_displayData.length}");
      if (mounted) setState(() {});
    } on RangeError {
      _displayData = [];
      if (mounted) setState(() {});
    }
  }

  final int startIndex = 0;
  late int endIndex = widget.categoryData.length;
  late List<M3uEntry> _displayData =
      List.from(widget.categoryData.sublist(startIndex, endIndex));
  @override
  Widget build(BuildContext context) {
    // return StreamBuilder(
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
    // _displayData = List.from(data.sublist(startIndex, endIndex));

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
                                        borderRadius: BorderRadius.circular(
                                          10.0,
                                        ),
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Added_to_Favorites".tr(),
                                              style: const TextStyle(
                                                fontSize: 16,
                                              ),
                                            ),
                                            IconButton(
                                              padding: const EdgeInsets.all(0),
                                              onPressed: () {
                                                Navigator.of(context).pop();
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
              //   },
              // );
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
