// ignore_for_file: deprecated_member_use, avoid_print

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:page_transition/page_transition.dart';
import 'package:seizhtv/extensions/color.dart';
import 'package:seizhtv/globals/network_image_viewer.dart';
import 'package:seizhtv/globals/palette.dart';
import 'package:seizhtv/globals/video_loader.dart';
import 'package:z_m3u_handler/extension.dart';
import 'package:z_m3u_handler/z_m3u_handler.dart';
import '../../../../data_containers/favorites.dart';
import '../../../../globals/data.dart';
import '../../../../globals/favorite_button.dart';
import '../../../../services/tv_series_api.dart';
import 'details.dart';

class ClassifiedSeriesData extends StatefulWidget {
  const ClassifiedSeriesData({super.key, required this.data});
  final ClassifiedData data;
  @override
  State<ClassifiedSeriesData> createState() => _ClassifiedSeriesDataState();
}

class _ClassifiedSeriesDataState extends State<ClassifiedSeriesData>
    with ColorPalette, VideoLoader, TVSeriesAPI {
  late final List<ClassifiedData> _data = widget.data.data.classify()
    ..sort((a, b) => a.name.compareTo(b.name));
  late List<ClassifiedData> _displayData = List.from(_data);
  late final ScrollController _scrollController;
  late final TextEditingController _search;
  static final ZM3UHandler _handler = ZM3UHandler.instance;
  final Favorites _favvm = Favorites.instance;
  late List<ClassifiedData> seriesData = [];
  List<ClassifiedData> favData = [];
  late List<ClassifiedData> _favdata;

  fetchFav() async {
    await _handler
        .getDataFrom(type: CollectionType.favorites, refId: refId!)
        .then((value) {
      if (value != null) {
        _favvm.populate(value);
      }
    });
  }

  initFavStream() {
    _favvm.stream.listen((event) {
      _favdata = List.from(event.series);

      for (final ClassifiedData item in _favdata) {
        late final List<ClassifiedData> data = item.data.classify()
          ..sort((a, b) => a.name.compareTo(b.name));

        favData.addAll(List.from(data));
      }
      print("SERIES FAV: ${favData.length}");
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
                          _displayData.sort((a, b) => a.name.compareTo(b.name));
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
                                  childAspectRatio: .8,
                                  mainAxisSpacing: 5,
                                  crossAxisSpacing: 10),
                          itemCount: _displayData.length,
                          itemBuilder: (context, i) {
                            bool isFavorite = false;
                            for (final ClassifiedData fav in favData) {
                              if (_displayData[i].name == fav.name) {
                                if (fav.data.length ==
                                    _displayData[i].data.length) {
                                  isFavorite = true;
                                }
                              }
                            }

                            return GestureDetector(
                              onTap: () async {
                                String result1 = _displayData[i].name.replaceAll(
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
                                      data: _displayData[i],
                                      title: result2,
                                    ),
                                    type: PageTransitionType.rightToLeft,
                                  ),
                                );
                              },
                              child: Stack(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(
                                        top: 10, right: 10),
                                    child: LayoutBuilder(
                                      builder: (context, c) {
                                        final double w = c.maxWidth;
                                        return Tooltip(
                                          message: _displayData[i].name,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                child: NetworkImageViewer(
                                                  url: _displayData[i]
                                                      .data[0]
                                                      .attributes['tvg-logo'],
                                                  width: w,
                                                  height: 53,
                                                  fit: BoxFit.cover,
                                                  color: highlight,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Tooltip(
                                                message: _displayData[i].name,
                                                child: Text(
                                                  _displayData[i].name,
                                                  style: const TextStyle(
                                                      fontSize: 12),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                      "${_displayData[i].data.length} ",
                                                      style: const TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.grey)),
                                                  Text("Episodes".tr(),
                                                      style: const TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.grey)),
                                                ],
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
                                        onPressedCallback:
                                            (bool isFavorite) async {
                                          if (isFavorite) {
                                            showDialog(
                                              barrierDismissible: false,
                                              context: context,
                                              builder: (BuildContext context) {
                                                Future.delayed(
                                                  const Duration(seconds: 3),
                                                  () {
                                                    Navigator.of(context)
                                                        .pop(true);
                                                  },
                                                );
                                                return Dialog(
                                                  alignment:
                                                      Alignment.topCenter,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
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
                                            for (M3uEntry m3u
                                                in _displayData[i].data) {
                                              await m3u.addToFavorites(refId!);
                                            }
                                          } else {
                                            for (M3uEntry m3u
                                                in _displayData[i].data) {
                                              await m3u
                                                  .removeFromFavorites(refId!);
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
                            );
                          })
                      //  ListView.separated(
                      //   itemCount: _displayData.length,
                      //   itemBuilder: (_, i) {
                      //     final ClassifiedData _d = _displayData[i];
                      //     return ListTile(
                      //       title: Text(_d.name),
                      //       onTap: () async {
                      //         String result1 = _d.name.replaceAll(
                      //             RegExp(r"[(]+[a-zA-Z]+[)]|[|]\s+[0-9]+\s[|]"),
                      //             '');
                      //         String result2 = result1.replaceAll(
                      //             RegExp(r"[|]+[a-zA-Z]+[|]|[a-zA-Z]+[|] "),
                      //             '');

                      //         Navigator.push(
                      //           context,
                      //           PageTransition(
                      //             child: SeriesDetailsPage(
                      //               data: _d,
                      //               title: result2,
                      //             ),
                      //             type: PageTransitionType.rightToLeft,
                      //           ),
                      //         );
                      //         // }
                      //         // }
                      //         // );
                      //         // await showModalBottomSheet(
                      //         //   context: context,
                      //         //   isDismissible: true,
                      //         //   backgroundColor: Colors.transparent,
                      //         //   isScrollControlled: true,
                      //         //   builder: (_) => SeriesDetailsSheet(
                      //         //     data: _d,
                      //         //     onLoadVideo: (M3uEntry entry) async {
                      //         //       Navigator.of(context).pop(null);
                      //         //       await loadVideo(context, entry);
                      //         //       await entry.addToHistory(refId!);
                      //         //     },
                      //         //   ),
                      //         // );
                      //         // await showModalBottomSheet(
                      //         //     context: context,
                      //         //     isDismissible: true,
                      //         //     backgroundColor: Colors.transparent,
                      //         //     constraints: const BoxConstraints(
                      //         //       maxHeight: 230,
                      //         //     ),
                      //         //     builder: (_) {
                      //         //       return SeriesDetailsSheet(
                      //         //         data: _d,
                      //         //         onLoadVideo: (entry) {},
                      //         //       );
                      //         //       // return MovieDetails(
                      //         //       //   data: _entry,
                      //         //       //   onLoadVideo: () async {
                      //         //       //     Navigator.of(context).pop(null);
                      //         //       //     _entry.addToHistory(refId!);
                      //         //       //     await loadVideo(context, _entry);
                      //         //       //   },
                      //         //       // );
                      //         //     });
                      //       },
                      //       subtitle: Row(
                      //         children: [
                      //           Text("${_d.data.length} "),
                      //           Text("Episodes".tr()),
                      //         ],
                      //       ),
                      //       leading: ClipRRect(
                      //         borderRadius: BorderRadius.circular(5),
                      //         child: SizedBox(
                      //           width: 85,
                      //           child: NetworkImageViewer(
                      //             url: _d.data[0].attributes['tvg-logo']!,
                      //             width: 85,
                      //             height: 60,
                      //             fit: BoxFit.cover,
                      //             color: highlight,
                      //           ),
                      //         ),
                      //       ),
                      //     );
                      //   },
                      //   separatorBuilder: (_, i) => Divider(
                      //     color: Colors.white.withOpacity(.3),
                      //   ),
                      // ),
                      // child: ListTile(
                      //   // subtitle: entry.attributes['description'] == null
                      //   //     ? null
                      //   //     : Text(
                      //   //         entry.attributes['description']!,
                      //   //       ),
                      //   title: Text(_entry.title),
                      // leading: ClipRRect(
                      //   borderRadius: BorderRadius.circular(5),
                      //   child: SizedBox(
                      //     width: 85,
                      //     child: NetworkImageViewer(
                      //       url: entry.attributes['tvg-logo']!,
                      //       width: 85,
                      //       height: 60,
                      //       fit: BoxFit.cover,
                      //       color: highlight,
                      //     ),
                      //   ),
                      // ),
                      // ),
                      // child: GridView.count(
                      //   controller: _scrollController,
                      //   mainAxisSpacing: 10,
                      //   crossAxisSpacing: 10,
                      //   padding: const EdgeInsets.symmetric(horizontal: 15),
                      //   crossAxisCount: 3,
                      //   childAspectRatio: .6,
                      //   children: List.generate(_displayData.length, (index) {
                      //     final ClassifiedData _entry = _displayData[index];
                      //     return LayoutBuilder(builder: (context, c) {
                      //       final double w = c.maxWidth;
                      //       final double h = c.maxHeight;
                      //       return ClipRRect(
                      //         borderRadius: BorderRadius.circular(5),
                      //         child: Tooltip(
                      //           message: _entry.name,
                      //           child: GestureDetector(
                      //             onTap: () async {
                      // await showModalBottomSheet(
                      //     context: context,
                      //     isDismissible: true,
                      //     backgroundColor: Colors.transparent,
                      //     constraints: const BoxConstraints(
                      //       maxHeight: 230,
                      //     ),
                      //     builder: (_) {
                      //       return MovieDetails(
                      //         data: _entry,
                      //         onLoadVideo: () async {
                      //           Navigator.of(context).pop(null);
                      //           _entry.addToHistory(refId!);
                      //           await loadVideo(context, _entry);
                      //         },
                      //       );
                      //     });
                      //             },
                      //             child: NetworkImageViewer(
                      //               url: _entry.data[0].attributes['tvg-logo'],
                      //               width: w,
                      //               height: h,
                      //               fit: BoxFit.cover,
                      //               color: highlight,
                      //             ),
                      //           ),
                      //         ),
                      //       );
                      //     });
                      //   }),
                      // ),
                      ),
            )
          ],
        ),
      ),
    );
  }
}
