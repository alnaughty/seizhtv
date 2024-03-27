// ignore_for_file: deprecated_member_use, no_leading_underscores_for_local_identifiers

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:page_transition/page_transition.dart';
import 'package:seizhtv/extensions/color.dart';
import 'package:seizhtv/extensions/m3u_entry.dart';
import 'package:seizhtv/globals/network_image_viewer.dart';
import 'package:seizhtv/globals/palette.dart';
import 'package:seizhtv/globals/video_loader.dart';
import 'package:seizhtv/services/movie_api.dart';
import 'package:z_m3u_handler/extension.dart';
import 'package:z_m3u_handler/z_m3u_handler.dart';

import '../../../../data_containers/favorites.dart';
import '../../../../globals/data.dart';
import '../../../../globals/favorite_button.dart';
import 'details.dart';

class ClassifiedMovieData extends StatefulWidget {
  const ClassifiedMovieData({
    super.key,
    required this.data,
  });
  final ClassifiedData data;
  @override
  State<ClassifiedMovieData> createState() => _ClassifiedMovieDataState();
}

class _ClassifiedMovieDataState extends State<ClassifiedMovieData>
    with ColorPalette, VideoLoader, MovieAPI {
  late final List<ClassifiedData> _data = widget.data.data.classify().toList()
    ..sort((a, b) => a.name.compareTo(b.name));
  late List<M3uEntry> _displayData =
      List.from(_data.expand((element) => element.data));
  static final ZM3UHandler _handler = ZM3UHandler.instance;
  late final ScrollController _scrollController;
  late final TextEditingController _search;
  final Favorites _vm1 = Favorites.instance;

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
  void initState() {
    _search = TextEditingController();
    _scrollController = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    _search.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: card,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: Row(
            children: [
              SvgPicture.asset("assets/images/logo.svg", height: 25),
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 10,
                ),
                height: 25,
                width: 1.5,
                color: Colors.white.withOpacity(.5),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Hero(
                      tag: widget.data.name.toUpperCase(),
                      child: Material(
                        color: Colors.transparent,
                        elevation: 0,
                        child: Text(
                          widget.data.name.toUpperCase(),
                          maxLines: 1,
                          style: TextStyle(
                            color: white,
                            fontSize: 15,
                            height: 1,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          "${_data.length} ",
                          style: TextStyle(
                            color: white.withOpacity(.5),
                            fontSize: 11,
                            height: 1,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        Text(
                          "Entries".tr(),
                          style: TextStyle(
                            color: white.withOpacity(.5),
                            fontSize: 11,
                            height: 1,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
        body: Column(
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
                            _displayData = List.from(_data);
                          } else {
                            _displayData = List.from(
                              _data.where(
                                (element) =>
                                    element.name.toLowerCase().contains(
                                          text.toLowerCase(),
                                        ),
                              ),
                            );
                          }
                          _displayData
                              .sort((a, b) => a.title.compareTo(b.title));
                          if (mounted) setState(() {});
                        },
                        cursorColor: orange,
                        controller: _search,
                        decoration: InputDecoration(
                          hintText: "Search".tr(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: _displayData.isEmpty
                  ? Center(
                      child: Text("NO RESULT FOUND FOR ${_search.text}"),
                    )
                  : Scrollbar(
                      controller: _scrollController,
                      child: GridView.builder(
                        shrinkWrap: true,
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisExtent: 155,
                        ),
                        itemCount: _displayData.length,
                        itemBuilder: (context, i) {
                          final M3uEntry d = _displayData[i];

                          return GestureDetector(
                            onTap: () async {
                              String result1 = d.title.replaceAll(
                                  RegExp(r"[(]+[0-9]+[)]|[|]\s+[0-9]+\s[|]"),
                                  '');
                              String result2 = result1.replaceAll(
                                  RegExp(r"[|]+[a-zA-Z]+[|]|[a-zA-Z]+[|] "),
                                  '');

                              print("RESULT 2: $result2");

                              Navigator.push(
                                context,
                                PageTransition(
                                  child: MovieDetailsPage(
                                    data: d,
                                    title: result2,
                                  ),
                                  type: PageTransitionType.rightToLeft,
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.all(5),
                              child: Stack(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(
                                        top: 10, right: 10),
                                    child: LayoutBuilder(
                                      builder: (context, c) {
                                        final double w = c.maxWidth;
                                        return Tooltip(
                                          message: d.title,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              NetworkImageViewer(
                                                url: d.attributes['tvg-logo'],
                                                title: d.title,
                                                width: w,
                                                height: 90,
                                                fit: BoxFit.cover,
                                                color: highlight,
                                              ),
                                              const SizedBox(height: 3),
                                              Tooltip(
                                                message: d.title,
                                                child: Text(
                                                  d.title,
                                                  style: const TextStyle(
                                                      fontSize: 12),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
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
                                                  Navigator.of(context)
                                                      .pop(true);
                                                });
                                                return Dialog(
                                                  alignment:
                                                      Alignment.topCenter,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 20),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          "Added_to_Favorites"
                                                              .tr(),
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                        IconButton(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(0),
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          icon: const Icon(Icons
                                                              .close_rounded),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                            await d.addToFavorites(refId!);
                                          } else {
                                            await d.removeFromFavorites(refId!);
                                          }
                                          await fetchFav();
                                        },
                                        initValue: d.existsInFavorites("movie"),
                                        iconSize: 20,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      )
                      //  GridView.count(
                      //   controller: _scrollController,
                      //   mainAxisSpacing: 10,
                      //   crossAxisSpacing: 10,
                      //   padding: const EdgeInsets.symmetric(horizontal: 15),
                      //   crossAxisCount: 3,
                      //   childAspectRatio: .6,
                      //   children: List.generate(
                      //     _displayData.length,
                      //     (index) {
                      //       final ClassifiedData _entry = _displayData[index];

                      //       return LayoutBuilder(
                      //         builder: (context, c) {
                      //           final double w = c.maxWidth;
                      //           final double h = c.maxHeight;
                      //           return ClipRRect(
                      //             borderRadius: BorderRadius.circular(5),
                      //             child: Tooltip(
                      //               message: _entry.name,
                      //               child: GestureDetector(
                      //                 onTap: () async {
                      //                   String str1 = _entry.name;
                      //                   String result1 = str1.replaceAll(
                      //                       RegExp(
                      //                           r"[(]+[0-9]+[)]|[|]\s+[0-9]+\s[|]"),
                      //                       '');
                      //                   String result2 = result1.replaceAll(
                      //                       RegExp(
                      //                           r"[|]+[a-zA-Z]+[|]|[a-zA-Z]+[|] "),
                      //                       '');

                      //                   print("MOVIE TITLE: $result2");

                      //                   // Navigator.push(
                      //                   //   context,
                      //                   //   PageTransition(
                      //                   //     child: MovieDetailsPage(
                      //                   //       data: _entry.data,
                      //                   //       title: result2,
                      //                   //     ),
                      //                   //     type:
                      //                   //         PageTransitionType.leftToRight,
                      //                   //   ),
                      //                   // );
                      //                 },
                      //                 child: NetworkImageViewer(
                      //                   url: _entry
                      //                       .data[0].attributes['tvg-logo'],
                      //                   width: w,
                      //                   height: h,
                      //                   fit: BoxFit.cover,
                      //                   color: highlight,
                      //                 ),
                      //               ),
                      //             ),
                      //           );
                      //         },
                      //       );
                      //     },
                      //   ),
                      // ),
                      ),
            )
          ],
        ),
      ),
    );
  }
}
