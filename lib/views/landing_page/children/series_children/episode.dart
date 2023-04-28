// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:seizhtv/extensions/classified_data.dart';
import 'package:seizhtv/extensions/m3u_entry.dart';
import 'package:z_m3u_handler/z_m3u_handler.dart';

import '../../../../data_containers/favorites.dart';
import '../../../../globals/data.dart';
import '../../../../globals/favorite_button.dart';
import '../../../../globals/network_image_viewer.dart';
import '../../../../globals/palette.dart';
import '../../../../globals/video_loader.dart';

class EpisodePage extends StatefulWidget {
  const EpisodePage({super.key, required this.data});
  final ClassifiedData data;

  @override
  State<EpisodePage> createState() => _EpisodePageState();
}

class _EpisodePageState extends State<EpisodePage>
    with ColorPalette, VideoLoader {
  late bool isFavorite = widget.data.isInFavorite("series");
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
    final Size size = MediaQuery.of(context).size;

    return Stack(
      children: [
        Material(
          color: Colors.transparent,
          elevation: 0,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Row(
                  children: [
                    Column(
                      children: [
                        Text(
                          "${widget.data.data.length} Episode${widget.data.data.length > 1 ? "s" : ""}",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withOpacity(.5),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          height: 3,
                          width: size.width * .25,
                          color: orange,
                        ),
                      ],
                    ),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (_, c) {
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
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const Text(
                                                  "Added to Favorites",
                                                  style: TextStyle(
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
                                    for (M3uEntry m3u in widget.data.data) {
                                      await m3u.addToFavorites(refId!);
                                    }
                                  } else {
                                    for (M3uEntry m3u in widget.data.data) {
                                      await m3u.removeFromFavorites(refId!);
                                    }
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
                        },
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 30),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (_, i) {
                    final M3uEntry e = widget.data.data[i];

                    return ListTile(
                      onTap: () async {
                        e.addToHistory(refId!);
                        await loadVideo(context, e);
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
              ],
            ),
          ),
        ),
      ],
    );
  }
}
