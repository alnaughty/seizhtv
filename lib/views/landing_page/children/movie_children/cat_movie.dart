// ignore_for_file: deprecated_member_use, must_be_immutable, avoid_print

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:page_transition/page_transition.dart';
import 'package:seizhtv/extensions/color.dart';
import 'package:seizhtv/extensions/m3u_entry.dart';
import 'package:z_m3u_handler/z_m3u_handler.dart';
import '../../../../data_containers/favorites.dart';
import '../../../../globals/data.dart';
import '../../../../globals/favorite_button.dart';
import '../../../../globals/network_image_viewer.dart';
import '../../../../globals/palette.dart';
import 'details.dart';

class MovieCategoryPage extends StatefulWidget {
  MovieCategoryPage(
      {super.key, required this.categorydata, required this.showsearchfield});

  final List<M3uEntry> categorydata;
  late bool showsearchfield;

  @override
  State<MovieCategoryPage> createState() => MovieCategoryPageState();
}

class MovieCategoryPageState extends State<MovieCategoryPage>
    with ColorPalette {
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

  @override
  Widget build(BuildContext context) {
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
                    "No Result Found for `$searchText`",
                    style: TextStyle(
                      color: Colors.white.withOpacity(.5),
                    ),
                  ),
                )
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, mainAxisExtent: 145),
                  itemCount: searchText == ""
                      ? widget.categorydata.length
                      : _displayData.length,
                  itemBuilder: (context, index) {
                    final M3uEntry item = searchText == ""
                        ? widget.categorydata[index]
                        : _displayData[index];

                    return GestureDetector(
                      onTap: () async {
                        String result1 = item.title.replaceAll(
                            RegExp(r"[0-9]|[(]+[0-9]+[)]|[|]\s+[0-9]+\s[|]"),
                            '');
                        String result2 = result1.replaceAll(
                            RegExp(r"[|]+[a-zA-Z]+[|]|[a-zA-Z]+[|] "), '');

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
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 1.5),
                        child: Stack(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 10, right: 10),
                              child: LayoutBuilder(
                                      builder: (context, c) {
                                        final double w = c.maxWidth;
                                        final double h = c.maxHeight;
                                        return ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              child: NetworkImageViewer(
                                                url: item.attributes['tvg-logo'],
                                                width: w,
                                                height:h, 
                                                fit: BoxFit.cover,
                                                color: highlight,
                                              ),
                                            );
                                      },
                                    ),
                              // Tooltip(
                              //   message: item.title,
                              //   child: Column(
                              //     crossAxisAlignment:
                              //         CrossAxisAlignment.start,
                              //     children: [
                              //       ClipRRect(
                              //         borderRadius:
                              //             BorderRadius.circular(10),
                              //         child: NetworkImageViewer(
                              //           url: item.attributes['tvg-logo'],
                              //           width: w,
                              //           height: 90,
                              //           fit: BoxFit.cover,
                              //           color: highlight,
                              //         ),
                              //       ),
                              //       const SizedBox(height: 3),
                              //       Tooltip(
                              //         message: item.title,
                              //         child: Text(
                              //           item.title,
                              //           style:
                              //               const TextStyle(fontSize: 12),
                              //           maxLines: 2,
                              //           overflow: TextOverflow.ellipsis,
                              //         ),
                              //       ),
                              //     ],
                              //   ),
                              // ),
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
                                                  BorderRadius.circular(10),
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
                                                        fontSize: 16),
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
                                  initValue: item.existsInFavorites("movie"),
                                  iconSize: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
