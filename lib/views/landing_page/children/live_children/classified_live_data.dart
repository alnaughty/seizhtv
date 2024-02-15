// ignore_for_file: deprecated_member_use

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:seizhtv/extensions/color.dart';
import 'package:seizhtv/extensions/m3u_entry.dart';
import 'package:seizhtv/globals/data.dart';
import 'package:seizhtv/globals/network_image_viewer.dart';
import 'package:seizhtv/globals/palette.dart';
import 'package:seizhtv/globals/video_loader.dart';
import 'package:z_m3u_handler/z_m3u_handler.dart';
import '../../../../data_containers/favorites.dart';
import '../../../../globals/favorite_button.dart';

class ClassifiedLiveData extends StatefulWidget {
  const ClassifiedLiveData({super.key, required this.data});
  final ClassifiedData data;
  @override
  State<ClassifiedLiveData> createState() => _ClassifiedLiveDataState();
}

class _ClassifiedLiveDataState extends State<ClassifiedLiveData>
    with ColorPalette, VideoLoader {
  late final List<M3uEntry> data = widget.data.data
    ..sort((a, b) => a.title.compareTo(b.title));
  late List<M3uEntry> _displyData = List.from(data);
  late final ScrollController _scrollController;
  late final TextEditingController _search;
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
                    Text(
                      "${data.length} Entries",
                      style: TextStyle(
                        color: white.withOpacity(.5),
                        fontSize: 11,
                        height: 1,
                        fontWeight: FontWeight.w300,
                      ),
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
                            _displyData = List.from(data);
                          } else {
                            _displyData = List.from(
                              data.where(
                                (element) =>
                                    element.title.toLowerCase().contains(
                                          text.toLowerCase(),
                                        ),
                              ),
                            );
                          }
                          _displyData
                              .sort((a, b) => a.title.compareTo(b.title));
                          if (mounted) setState(() {});
                        },
                        cursorColor: orange,
                        controller: _search,
                        decoration: const InputDecoration(
                          hintText: "Search",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Expanded(
                child: _displyData.isEmpty
                    ? Center(
                        child: Text("NO RESULT FOUND FOR ${_search.text}"),
                      )
                    : GridView.builder(
                        physics: const ClampingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio:
                                    .8, // optional, adjust as needed
                                mainAxisSpacing: 10,
                                crossAxisSpacing: 10),
                        itemCount: _displyData.length,
                        itemBuilder: (context, index) {
                          final M3uEntry item = _displyData[index];

                          return LayoutBuilder(
                            builder: (context, c) {
                              final double w = c.maxWidth;
                              return Stack(
                                children: [
                                  GestureDetector(
                                    onTap: () async {
                                      item.addToHistory(refId!);
                                      await loadVideo(context, item);
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(
                                          top: 10, right: 10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: NetworkImageViewer(
                                              url: item.attributes['tvg-logo'],
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
                                                builder:
                                                    (BuildContext context) {
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
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                        10.0,
                                                      ),
                                                    ),
                                                    child: Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 20,
                                                      ),
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
                                                              Icons
                                                                  .close_rounded,
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
                                              await item
                                                  .removeFromFavorites(refId!);
                                            }
                                            await fetchFav();
                                          },
                                          initValue:
                                              item.existsInFavorites("live"),
                                          iconSize: 20,
                                        ),
                                      ))
                                ],
                              );
                            },
                          );
                        },
                      )
                // ListView.separated(
                //     itemBuilder: (_, i) {
                //       final M3uEntry entry = _displyData[i];
                //       return ListTile(
                //         onTap: () async {
                //           await showModalBottomSheet(
                //               context: context,
                //               isDismissible: true,
                //               backgroundColor: Colors.transparent,
                //               constraints: const BoxConstraints(
                //                 maxHeight: 230,
                //               ),
                //               builder: (_) {
                //                 return LiveDetails(
                //                   onLoadVideo: () async {
                //                     Navigator.of(context).pop(null);
                //                     await loadVideo(context, entry);
                //                     await entry.addToHistory(refId!);
                //                   },
                //                   entry: entry,
                //                 );
                //               });
                //         },
                //         subtitle: entry.attributes['description'] == null
                //             ? null
                //             : Text(
                //                 entry.attributes['description']!,
                //               ),
                //         title: Text(entry.title),
                //         leading: ClipRRect(
                //           borderRadius: BorderRadius.circular(5),
                //           child: SizedBox(
                //             width: 85,
                //             child: NetworkImageViewer(
                //               url: entry.attributes['tvg-logo']!,
                //               width: 85,
                //               height: 60,
                //               fit: BoxFit.cover,
                //               color: highlight,
                //             ),
                //           ),
                //         ),
                //       );
                //     },
                //     separatorBuilder: (_, i) => Divider(
                //       color: Colors.white.withOpacity(.3),
                //     ),
                //     itemCount: _displyData.length,
                //   ),
                ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}
