import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:seizhtv/data_containers/favorites.dart';
import 'package:seizhtv/extensions/color.dart';
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
        print("FETCH DATA FROM FAV: $value");
        _vm.populate(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 230,
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
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: LayoutBuilder(builder: (_, c) {
                final double h = c.maxHeight;
                return Row(
                  children: [
                    SizedBox(
                      width: 100,
                      height: h,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: NetworkImageViewer(
                          url: widget.entry.attributes['tvg-logo']!,
                          height: h,
                          width: 100,
                          color: highlight,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      child: LayoutBuilder(builder: (_, c) {
                        final double w = c.maxWidth;
                        return SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.entry.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                  height: 1,
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Container(
                                width: w * .5,
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
                                    if (!widget.entry
                                        .existsInFavorites("live")) {
                                      await widget.entry.addToFavorites(refId!);
                                    } else {
                                      await widget.entry
                                          .removeFromFavorites(refId!);
                                    }
                                    await fetchFav();
                                  },
                                  color: Colors.transparent,
                                  elevation: 0,
                                  height: 40,
                                  child: Center(
                                    child: Text(
                                      widget.entry.existsInFavorites("live")
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
                              const SizedBox(
                                height: 10,
                              )
                            ],
                          ),
                        );
                      }),
                    ),
                  ],
                );
              }),
            ),
            const SizedBox(
              height: 10,
            ),
            MaterialButton(
              padding: EdgeInsets.zero,
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
