// ignore_for_file: deprecated_member_use, avoid_print, must_be_immutable

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:page_transition/page_transition.dart';
import 'package:seizhtv/extensions/color.dart';
import 'package:seizhtv/views/landing_page/children/series_children/details.dart';
import 'package:z_m3u_handler/extension.dart';
import 'package:z_m3u_handler/z_m3u_handler.dart';
import '../../../../data_containers/favorites.dart';
import '../../../../globals/data.dart';
import '../../../../globals/favorite_button.dart';
import '../../../../globals/network_image_viewer.dart';
import '../../../../globals/palette.dart';
import '../../../../globals/ui_additional.dart';
import '../../../../globals/video_loader.dart';

class SeriesCategoryPage extends StatefulWidget {
  SeriesCategoryPage(
      {super.key,
      required this.categorydata,
      required this.showsearchfield,
      required this.onUpdateCallback});

  final List<ClassifiedData> categorydata;
  final ValueChanged<M3uEntry> onUpdateCallback;
  late bool showsearchfield;

  @override
  State<SeriesCategoryPage> createState() => SeriesCategoryPageState();
}

class SeriesCategoryPageState extends State<SeriesCategoryPage>
    with ColorPalette, VideoLoader, UIAdditional {
  static final Favorites _vm1 = Favorites.instance;
  static final ZM3UHandler _handler = ZM3UHandler.instance;
  List<ClassifiedData> favData = [];
  static final Favorites _fav = Favorites.instance;
  late List<ClassifiedData> _favdata;
  late List<ClassifiedData> _displayData = [];
  final TextEditingController _search = TextEditingController();
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

  initFavStream() {
    _fav.stream.listen((event) {
      _favdata = List.from(event.series);

      for (final ClassifiedData item in _favdata) {
        late final List<ClassifiedData> data = item.data.classify()
          ..sort((a, b) => a.name.compareTo(b.name));

        favData.addAll(List.from(data));
      }
    });
  }

  @override
  void initState() {
    fetchFav();
    initFavStream();
    super.initState();
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
                                                            .name
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
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: calculateCrossAxisCount(context),
                      childAspectRatio: .8,
                      crossAxisSpacing: 10,
                      mainAxisExtent: 150),
                  itemCount: searchText == ""
                      ? widget.categorydata.length
                      : _displayData.length,
                  itemBuilder: (context, i) {
                    final ClassifiedData datas = searchText == ""
                        ? widget.categorydata[i]
                        : _displayData[i];
                    bool isFavorite = false;
                    for (final ClassifiedData fav in favData) {
                      if (datas.name == fav.name) {
                        if (fav.data.length == datas.data.length) {
                          isFavorite = true;
                        }
                      }
                    }

                    return GestureDetector(
                      onTap: () async {
                        String title = '';

                        String result1 = datas.name.replaceAll(
                            RegExp(r"[(]+[a-zA-Z]+[)]|[0-9]|[|]\s+[0-9]+\s[|]"),
                            '');
                        String result2 = result1.replaceAll(
                            RegExp(r"[|]+[a-zA-Z]+[|]|[a-zA-Z]+[|] "), '');

                        String result3 =
                            datas.name.replaceAll(RegExp('[^0-9]'), '');

                        if (result2.contains('FHD MULTI')) {
                          title = result2.replaceAll('FHD MULTI', '').trim();
                        } else if (result2.contains('FHD')) {
                          title = result2.replaceAll('FHD', '').trim();
                        } else if (result2.contains('HD')) {
                          title = result2.replaceAll('HD', '').trim();
                        } else if (result2.contains('SD')) {
                          title = result2.replaceAll('SD', '').trim();
                        }

                        print("TITLE: ${datas.name}");
                        print("SERIES TITLE (result1): $result1");
                        print("SERIES TITLE (result2): $result2");
                        print("SERIES TITLE (result3): $result3");
                        print("SERIES TITLE (result3): $title");

                        Navigator.push(
                          context,
                          PageTransition(
                            child: SeriesDetailsPage(
                              data: datas,
                              title: title,
                              year: result3,
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
                                    borderRadius: BorderRadius.circular(5),
                                    child: NetworkImageViewer(
                                      url: datas.data[0].attributes['tvg-logo'],
                                      title: datas.data[0].title,
                                      width: w,
                                      height: h,
                                      fit: BoxFit.cover,
                                      color: highlight,
                                    ),
                                  );
                                },
                              ),
                              // Column(
                              //   crossAxisAlignment:
                              //       CrossAxisAlignment.start,
                              //   children: [
                              //     ClipRRect(
                              //       borderRadius:
                              //           BorderRadius.circular(5),
                              //       child: NetworkImageViewer(
                              //         url: datas
                              //             .data[0].attributes['tvg-logo'],
                              //         width: w,
                              //         height: 75,
                              //         fit: BoxFit.cover,
                              //         color: highlight,
                              //       ),
                              //     ),
                              //     const SizedBox(height: 2),
                              //     Tooltip(
                              //       message: datas.name,
                              //       child: Text(
                              //         datas.name,
                              //         style:
                              //             const TextStyle(fontSize: 12),
                              //         maxLines: 2,
                              //         overflow: TextOverflow.ellipsis,
                              //       ),
                              //     ),
                              //     Row(
                              //       children: [
                              //         Text("${datas.data.length} ",
                              //             style: const TextStyle(
                              //                 fontSize: 12,
                              //                 color: Colors.grey)),
                              //         Text("Episodes".tr(),
                              //             style: const TextStyle(
                              //                 fontSize: 12,
                              //                 color: Colors.grey)),
                              //       ],
                              //     ),
                              //   ],
                              // ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: SizedBox(
                                height: 25,
                                width: 25,
                                child: FavoriteIconButton(
                                  onPressedCallback: (bool isFavorite) async {
                                    if (isFavorite) {
                                      showDialog(
                                        barrierDismissible: false,
                                        context: context,
                                        builder: (BuildContext context) {
                                          Future.delayed(
                                            const Duration(seconds: 5),
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
                                                      Icons.close_rounded,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                      for (M3uEntry m3u in datas.data) {
                                        await m3u.addToFavorites(refId!);
                                        widget.onUpdateCallback(m3u);
                                      }
                                    } else {
                                      for (M3uEntry m3u in datas.data) {
                                        await m3u.removeFromFavorites(refId!);
                                        widget.onUpdateCallback(m3u);
                                      }
                                    }
                                    await fetchFav();
                                  },
                                  initValue: isFavorite,
                                  iconSize: 20,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  }),
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
