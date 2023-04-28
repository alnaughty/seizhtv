// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:seizhtv/data_containers/favorites.dart';
import 'package:seizhtv/extensions/m3u_entry.dart';
import 'package:seizhtv/globals/data.dart';
import 'package:seizhtv/globals/network_image_viewer.dart';
import 'package:seizhtv/globals/palette.dart';
import 'package:z_m3u_handler/z_m3u_handler.dart';

class MovieDetails extends StatefulWidget {
  const MovieDetails(
      {super.key, required this.data, required this.onLoadVideo});
  final ClassifiedData data;
  final ValueChanged<M3uEntry> onLoadVideo;
  @override
  State<MovieDetails> createState() => _MovieDetailsState();
}

class _MovieDetailsState extends State<MovieDetails> with ColorPalette {
  static final Favorites _vm = Favorites.instance;
  static final ZM3UHandler _handler = ZM3UHandler.instance;
  late int? chosenIndex = widget.data.data.length == 1 ? 0 : null;
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
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      width: double.maxFinite,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Text(widget.data.data.length.toString()),
            Expanded(
              child: LayoutBuilder(builder: (context, c) {
                final double h = c.maxHeight;
                return Row(
                  children: [
                    // Text(widget.data.data.length.toString()),
                    Expanded(
                      child: ListView.separated(
                        // scrollDirection: Axis.horizontal,
                        itemBuilder: (_, i) {
                          final M3uEntry _data = widget.data.data[i];
                          return ListTile(
                            title: Text(_data.title),
                            subtitle: AnimatedContainer(
                              duration: const Duration(milliseconds: 400),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.white.withOpacity(.7),
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              width: chosenIndex == i ? c.maxWidth : 0,
                              height: chosenIndex == i ? 40 : 0,
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: chosenIndex == null
                                    ? Container()
                                    : MaterialButton(
                                        padding: EdgeInsets.zero,
                                        elevation: 0,
                                        onPressed: () async {
                                          await showDialog(
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
                                                alignment: Alignment.topCenter,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    10.0,
                                                  ),
                                                ),
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    vertical: 5,
                                                    horizontal: 20,
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          "${_data.title} Removed from Favorites",
                                                        ),
                                                      ),
                                                      IconButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
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
                                          await widget.data.data[chosenIndex!]
                                              .removeFromFavorites(refId!);
                                          Navigator.of(context).pop();
                                        },
                                        child: Center(
                                          child: Text(
                                            _data.existsInFavorites("movie")
                                                ? "Remove from\nfavorites"
                                                : "Add to favorites",
                                            // "Remove from\nfavorites",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 10,
                                              color:
                                                  Colors.white.withOpacity(.7),
                                            ),
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                            onTap: () {
                              chosenIndex = i;
                              if (mounted) setState(() {});
                            },
                          );
                        },
                        separatorBuilder: (_, i) => Divider(
                          color: Colors.white.withOpacity(.3),
                        ),
                        itemCount: widget.data.data.length,
                      ),
                    ),
                    AnimatedContainer(
                      height: h,
                      margin:
                          EdgeInsets.only(left: chosenIndex == null ? 0 : 5),
                      width: chosenIndex == null ? 0 : 100,
                      duration: const Duration(
                        milliseconds: 500,
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        child: chosenIndex == null
                            ? Container()
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: NetworkImageViewer(
                                    url: widget.data.data[chosenIndex!]
                                        .attributes['tvg-logo'],
                                    width: 100,
                                    height: h,
                                    color: highlight),
                              ),
                      ),
                    )
                  ],
                );
              }),
            ),
            // Expanded(
            //   child: LayoutBuilder(builder: (_, c) {
            //     final double h = c.maxHeight;
            //     return Row(
            //       children: [
            //         SizedBox(
            //           width: 80,
            //           height: h,
            //           child: ClipRRect(
            //             borderRadius: BorderRadius.circular(10),
            //             child: NetworkImageViewer(
            //               url: widget.data.data[0].attributes['tvg-logo']!,
            //               height: h,
            //               width: 80,
            //               color: card.darken(),
            //               fit: BoxFit.cover,
            //             ),
            //           ),
            //         ),
            //         const SizedBox(
            //           width: 20,
            //         ),
            //         Expanded(
            //           child: LayoutBuilder(builder: (_, c) {
            //             final double w = c.maxWidth;
            //             return SingleChildScrollView(
            //               child: Column(
            //                 crossAxisAlignment: CrossAxisAlignment.start,
            //                 children: [
            //                   Text(
            //                     widget.data.title,
            //                     style: const TextStyle(
            //                       color: Colors.white,
            //                       fontWeight: FontWeight.w600,
            //                       fontSize: 18,
            //                       height: 1,
            //                     ),
            //                   ),
            //                   if (widget.data.attributes['description'] !=
            //                       null) ...{
            //                     Text(
            //                       widget.data.attributes['description'],
            //                       style: const TextStyle(
            //                         color: Colors.white,
            //                         fontWeight: FontWeight.w400,
            //                         fontSize: 15,
            //                         height: 1,
            //                       ),
            //                     ),
            //                   },
            //                   const SizedBox(
            //                     height: 10,
            //                   ),
            //                   Container(
            //                     width: w * .5,
            //                     height: 40,
            // decoration: BoxDecoration(
            //   border: Border.all(
            //     color: Colors.white.withOpacity(.7),
            //   ),
            //   borderRadius: BorderRadius.circular(5),
            // ),
            //                     child: MaterialButton(
            //                       padding: EdgeInsets.zero,
            //                       onPressed: () async {
            //                         Navigator.of(context).pop(null);
            //                         if (!widget.data
            //                             .existsInFavorites("movie")) {
            //                           await widget.data.addToFavorites(refId!);
            //                         } else {
            //                           await widget.data
            //                               .removeFromFavorites(refId!);
            //                         }
            //                         await fetchFav();
            //                       },
            //                       color: Colors.transparent,
            //                       elevation: 0,
            //                       height: 40,
            // child: Center(
            //   child: Text(
            //     widget.data.existsInFavorites("movie")
            //         ? "Remove from\nfavorites"
            //         : "Add to favorites",
            //     textAlign: TextAlign.center,
            //     style: TextStyle(
            //       fontSize: 10,
            //       color: Colors.white.withOpacity(.7),
            //     ),
            //   ),
            // ),
            //                     ),
            //                   ),
            //                   const SizedBox(
            //                     height: 10,
            //                   )
            //                 ],
            //               ),
            //             );
            //           }),
            //         ),
            //       ],
            //     );
            //   }),
            // ),
            const SizedBox(
              height: 10,
            ),
            MaterialButton(
              padding: EdgeInsets.zero,
              onPressed: chosenIndex == null
                  ? null
                  : () {
                      widget.onLoadVideo(widget.data.data[chosenIndex!]);
                    },
              height: 50,
              color: Colors.white,
              disabledColor: Colors.grey.withOpacity(.5),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      "assets/icons/play.svg",
                      color: cardColor,
                      height: 25,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      "PLAY NOW",
                      style: TextStyle(
                        color: cardColor,
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
