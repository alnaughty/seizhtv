// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:seizhtv/data_containers/favorites.dart';
import 'package:seizhtv/extensions/m3u_entry.dart';
import 'package:seizhtv/globals/data.dart';
import 'package:seizhtv/globals/network_image_viewer.dart';
import 'package:seizhtv/globals/palette.dart';
import 'package:z_m3u_handler/z_m3u_handler.dart';

class LiveDetails extends StatefulWidget {
  const LiveDetails(
      {super.key, required this.onLoadVideo, required this.entry});
  final M3uEntry entry;
  final Function()? onLoadVideo;
  @override
  State<LiveDetails> createState() => _LiveDetailsState();
}

class _LiveDetailsState extends State<LiveDetails> with ColorPalette {
  static final Favorites _vm = Favorites.instance;
  static final ZM3UHandler _handler = ZM3UHandler.instance;
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
      height: 400,
      width: double.maxFinite,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 20,
      ),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: NetworkImageViewer(
              url: widget.entry.attributes['tvg-logo']!,
              title: widget.entry.title,
              height: 200,
              width: double.infinity,
              color: highlight,
              fit: BoxFit.fill,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            widget.entry.title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 20,
              height: 1,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 30),
          // Expanded(
          //   child: LayoutBuilder(builder: (_, c) {
          //     final double h = c.maxHeight;
          //     return Row(
          //       children: [
          //         SizedBox(
          //           width: 100,
          //           height: h,
          // child: ClipRRect(
          //   borderRadius: BorderRadius.circular(10),
          //   child: NetworkImageViewer(
          //     url: widget.entry.attributes['tvg-logo']!,
          //     height: h,
          //     width: 100,
          //     color: highlight,
          //     fit: BoxFit.cover,
          //   ),
          // ),
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
          // Text(
          //   widget.entry.title,
          //   style: const TextStyle(
          //     color: Colors.white,
          //     fontWeight: FontWeight.w600,
          //     fontSize: 18,
          //     height: 1,
          //   ),
          // ),
          //                   const SizedBox(
          //                     height: 10,
          //                   ),
          //                   Container(
          //                     width: w * .5,
          //                     height: 40,
          //                     decoration: BoxDecoration(
          //                       border: Border.all(
          //                         color: Colors.white.withOpacity(.7),
          //                       ),
          //                       borderRadius: BorderRadius.circular(5),
          //                     ),
          //                     child: MaterialButton(
          //                       padding: EdgeInsets.zero,
          //                       onPressed: () async {
          //                         Navigator.of(context).pop(null);
          //                         if (!widget.entry
          //                             .existsInFavorites("live")) {
          //                           await widget.entry.addToFavorites(refId!);
          //                         } else {
          //                           await widget.entry
          //                               .removeFromFavorites(refId!);
          //                         }
          //                         await fetchFav();
          //                       },
          //                       color: Colors.transparent,
          //                       elevation: 0,
          //                       height: 40,
          //                       child: Center(
          //                         child: Text(
          //                           widget.entry.existsInFavorites("live")
          //                               ? "om\nfavorites"
          //                               : "Add to favorites",
          //                           textAlign: TextAlign.center,
          //                           style: TextStyle(
          //                             fontSize: 10,
          //                             color: Colors.white.withOpacity(.7),
          //                           ),
          //                         ),
          //                       ),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MaterialButton(
                padding: const EdgeInsets.all(10),
                onPressed: widget.onLoadVideo,
                height: 50,
                color: Colors.white,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        "assets/icons/play.svg",
                        color: cardColor,
                        height: 25,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "Watch_Now".tr(),
                        style: TextStyle(color: cardColor),
                      )
                    ],
                  ),
                ),
              ),
              // const SizedBox(width: 5),
              MaterialButton(
                // style: ElevatedButton.styleFrom(
                //   elevation: 0,
                //   backgroundColor: Colors.transparent,
                // ),
                padding: const EdgeInsets.all(10),
                minWidth: 50,
                onPressed: () async {
                  print("SELECTED ITEM: ${widget.entry}");
                  print(
                      "item.existsInFavorites(live): ${widget.entry.existsInFavorites("live")}");
                  if (!widget.entry.existsInFavorites("live")) {
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (BuildContext context) {
                        // Future.delayed(
                        //   const Duration(seconds: 3),
                        //   () {
                        //     Navigator.of(context).pop(true);
                        //   },
                        // );
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Add_to_favorites".tr(),
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
                    await widget.entry.addToFavorites(refId!);
                    Navigator.of(context).pop(null);
                  } else {
                    await widget.entry.removeFromFavorites(refId!);
                    // Navigator.of(context).pop(null);
                  }
                  Navigator.of(context).pop(null);
                  await fetchFav();
                },
                child: Column(
                  children: [
                    SvgPicture.asset(
                      "assets/icons/favorites.svg",
                      color: Colors.white,
                      height: 20,
                    ),
                    const SizedBox(height: 5),
                    SizedBox(
                      // width: 100,
                      child: Text(
                        widget.entry.existsInFavorites("live")
                            ? "Remove_from_favorites".tr()
                            : "Add_to_favorites".tr(),
                        style: const TextStyle(fontSize: 10),
                        textAlign: TextAlign.center,
                      ),
                    )
                  ],
                ),
              ),
              // const SizedBox(width: 10),
              MaterialButton(
                minWidth: 50,
                padding: const EdgeInsets.all(0),
                onPressed: () async {},
                child: Column(
                  children: [
                    SvgPicture.asset(
                      "assets/icons/info.svg",
                      color: Colors.white,
                      height: 20,
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "More Info",
                      style: TextStyle(fontSize: 10),
                    )
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
