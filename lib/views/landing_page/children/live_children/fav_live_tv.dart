// ignore_for_file: avoid_print, must_be_immutable

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:seizhtv/extensions/list.dart';
import 'package:seizhtv/extensions/m3u_entry.dart';
import 'package:z_m3u_handler/z_m3u_handler.dart';
import '../../../../data_containers/favorites.dart';
import '../../../../globals/data.dart';
import '../../../../globals/favorite_button.dart';
import '../../../../globals/network_image_viewer.dart';
import '../../../../globals/palette.dart';
import '../../../../globals/ui_additional.dart';
import '../../../../globals/video_loader.dart';

class FavLiveTvPage extends StatefulWidget {
  FavLiveTvPage(
      {super.key,
      required this.data,
      required this.onPressed,
      this.showSearchField = false});

  final List<M3uEntry> data;
  final ValueChanged<M3uEntry> onPressed;
  bool showSearchField;

  @override
  State<FavLiveTvPage> createState() => FavLiveTvPageState();
}

class FavLiveTvPageState extends State<FavLiveTvPage>
    with ColorPalette, VideoLoader, UIAdditional {
  final Favorites _favvm = Favorites.instance;
  static final ZM3UHandler _handler = ZM3UHandler.instance;

  fetchFav() async {
    await _handler
        .getDataFrom(type: CollectionType.favorites, refId: refId!)
        .then((value) {
      if (value != null) {
        _favvm.populate(value);
      }
    });
  }

  String searchText = "";

  void search(String text) {
    try {
      print("TEXT SEARCH IN CATEGORY LIVE: $text");
      searchText = text;
      endIndex = widget.data.length < 30 ? widget.data.length : 30;
      if (text.isEmpty) {
        _displayData = List.from(widget.data.unique());
      } else {
        text.isEmpty
            ? _displayData = List.from(widget.data.unique())
            : _displayData = List.from(widget.data
                .unique()
                .where((element) =>
                    element.title.toLowerCase().contains(text.toLowerCase()))
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
  late int endIndex = widget.data.length;
  late List<M3uEntry> _displayData =
      List.from(widget.data.sublist(startIndex, endIndex));

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return const Center(
        child: Text("No data added to favorites"),
      );
    }
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
                childAspectRatio: .8,
                crossAxisSpacing: 10),
            itemCount: _displayData.length,
            itemBuilder: (context, index) {
              final M3uEntry item = _displayData[index];

              return LayoutBuilder(
                builder: (context, c) {
                  final double w = c.maxWidth;
                  return Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          widget.onPressed(item);
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
                                  title: "false",
                                  width: w,
                                  height: 80,
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
                                                padding:
                                                    const EdgeInsets.all(0),
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
                          ))
                    ],
                  );
                },
              );
            },
            //   );
            // },
          );
  }

  int calculateCrossAxisCount(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount =
        (screenWidth / 150).floor(); // Calculate based on item width
    return crossAxisCount < 3 ? 3 : crossAxisCount;
  }
}
