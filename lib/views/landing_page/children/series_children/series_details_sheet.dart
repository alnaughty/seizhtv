import 'package:flutter/material.dart';
import 'package:seizhtv/data_containers/favorites.dart';
import 'package:seizhtv/extensions/classified_data.dart';
import 'package:seizhtv/extensions/color.dart';
import 'package:seizhtv/extensions/m3u_entry.dart';
import 'package:seizhtv/globals/data.dart';
import 'package:seizhtv/globals/favorite_button.dart';
import 'package:seizhtv/globals/network_image_viewer.dart';
import 'package:seizhtv/globals/palette.dart';
import 'package:z_m3u_handler/z_m3u_handler.dart';

class SeriesDetailsSheet extends StatefulWidget {
  const SeriesDetailsSheet(
      {super.key, required this.data, required this.onLoadVideo});
  final ClassifiedData data;
  final ValueChanged<M3uEntry> onLoadVideo;
  @override
  State<SeriesDetailsSheet> createState() => _SeriesDetailsSheetState();
}

class _SeriesDetailsSheetState extends State<SeriesDetailsSheet>
    with ColorPalette {
  late bool isFavorite = widget.data.isInFavorite("series");
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
    final Size size = MediaQuery.of(context).size;

    return DraggableScrollableSheet(
      initialChildSize: .5,
      minChildSize: .35,
      maxChildSize:
          (widget.data.data.length > 5 ? 5 : widget.data.data.length) / 5 <= .5
              ? .5
              : (widget.data.data.length > 5 ? 5 : widget.data.data.length) / 5,
      builder: (_, scrollController) => Container(
        width: double.maxFinite,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: ListView(
          controller: scrollController,
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
          children: [
            const SizedBox(
              height: 20,
            ),
            Text(
              widget.data.name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 19,
                height: 1,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Text(
                      "${widget.data.data.length} Episode${widget.data.data.length > 1 ? "s" : ""}",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withOpacity(.5),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Container(
                      height: 3,
                      width: size.width * .25,
                      color: orange,
                    ),
                  ],
                ),
                Expanded(
                  child: LayoutBuilder(builder: (_, c) {
                    final double w = c.maxWidth;
                    return Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        width: w * .7,
                        height: 40,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.white.withOpacity(.7),
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: MaterialButton(
                          padding: EdgeInsets.zero,
                          onPressed: () async {
                            Navigator.of(context).pop(null);
                            if (!isFavorite) {
                              // await widget.data.data[0].addToFavorites(refId!);
                              showDialog(
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
                                      borderRadius: BorderRadius.circular(
                                        10.0,
                                      ),
                                    ),
                                    child: Container(
                                      height: 50,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 15,
                                        horizontal: 20,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            "Added to Favorites",
                                            style: TextStyle(
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
                              for (M3uEntry m3u in widget.data.data) {
                                await m3u.addToFavorites(refId!);
                              }
                            } else {
                              for (M3uEntry m3u in widget.data.data) {
                                await m3u.removeFromFavorites(refId!);
                              }
                              // await widget.data.data[0]
                              //     .removeFromFavorites(refId!);
                            }
                            await fetchFav();
                          },
                          color: Colors.transparent,
                          elevation: 0,
                          height: 40,
                          child: Center(
                            child: Text(
                              isFavorite
                                  ? "Remove from\nfavorites"
                                  : "Add to favorites",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white.withOpacity(.7),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (_, i) {
                final M3uEntry e = widget.data.data[i];
                return ListTile(
                  onTap: () async {
                    widget.onLoadVideo(e);
                  },
                  contentPadding: EdgeInsets.zero,
                  trailing: FavoriteIconButton(
                    onPressedCallback: (bool f) async {
                      if (f) {
                        await e.addToFavorites(refId!);
                      } else {
                        await e.removeFromFavorites(refId!);
                      }
                      await fetchFav();
                    },
                    initValue: e.existsInFavorites("series"),
                    iconSize: 20,
                  ),
                  leading: SizedBox(
                    width: 85,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: NetworkImageViewer(
                        url: e.attributes['tvg-logo']!,
                        height: 60,
                        width: 85,
                        color: highlight,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  title: Text(e.title),
                );
              },
              separatorBuilder: (_, i) => Divider(
                color: Colors.white.withOpacity(.3),
              ),
              itemCount: widget.data.data.length,
            )
            // ...widget.data.data.map(
            // (e) => ListTile(
            //   onTap: () async {
            //     widget.onLoadVideo(e);
            //   },
            //   contentPadding: EdgeInsets.zero,
            //   trailing: FavoriteIconButton(
            //     onPressedCallback: (bool f) async {
            //       if (f) {
            //         await e.addToFavorites(refId!);
            //       } else {
            //         await e.removeFromFavorites(refId!);
            //       }
            //       await fetchFav();
            //     },
            //     initValue: e.existsInFavorites("series"),
            //     iconSize: 20,
            //   ),
            //   leading: SizedBox(
            //     width: 85,
            //     child: ClipRRect(
            //       borderRadius: BorderRadius.circular(10),
            //       child: NetworkImageViewer(
            //         url: e.attributes['tvg-logo']!,
            //         height: 60,
            //         width: 85,
            //         color: highlight,
            //         fit: BoxFit.cover,
            //       ),
            //     ),
            //   ),
            //   title: Text(e.title),
            // ),
            // ),
          ],
        ),
      ),
    );
  }
}
