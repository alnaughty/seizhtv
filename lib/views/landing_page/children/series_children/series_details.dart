import 'package:flutter/material.dart';
import 'package:seizhtv/data_containers/favorites.dart';
import 'package:seizhtv/extensions/color.dart';
import 'package:seizhtv/extensions/m3u_entry.dart';
import 'package:seizhtv/extensions/state.dart';
import 'package:seizhtv/globals/carousel.dart';
import 'package:seizhtv/globals/component.dart';
import 'package:seizhtv/globals/data.dart';
import 'package:seizhtv/globals/favorite_button.dart';
import 'package:seizhtv/globals/network_image_viewer.dart';
import 'package:seizhtv/globals/palette.dart';
import 'package:z_m3u_handler/z_m3u_handler.dart';

class SeriesDetails extends StatefulWidget {
  const SeriesDetails({super.key, required this.data});
  final ClassifiedData data;
  @override
  State<SeriesDetails> createState() => _SeriesDetailsState();
}

class _SeriesDetailsState extends State<SeriesDetails> with ColorPalette {
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
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: card,
      body: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            SizedBox(
              height: size.height * .65,
              width: size.width,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: LayoutBuilder(builder: (_, c) {
                      final double w = c.maxWidth;
                      final double h = c.maxHeight;
                      return AnimatedCarousel(
                        viewportFraction: 1,
                        minValue: 0.3,
                        changeDuration: const Duration(seconds: 5),
                        children: List.generate(
                          widget.data.data.length <= 5
                              ? widget.data.data.length
                              : widget.data.data
                                  .sublist(widget.data.data.length - 5)
                                  .length,
                          (index) {
                            final M3uEntry _entry = widget.data.data[index];
                            return NetworkImageViewer(
                              url: _entry.attributes['tvg-logo']!,
                              height: h,
                              width: w,
                              color: card.darken(),
                              fit: BoxFit.fitHeight,
                            );
                          },
                        ),
                      );
                    }),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: PreferredSize(
                      preferredSize: const Size.fromHeight(60),
                      child: appbar(
                        0,
                        showLeading: true,
                        title: Container(),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: (size.height * .65) * .55,
                      width: size.width,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            card,
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    left: 15,
                    right: 15,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.data.name,
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w600,
                            height: 1,
                          ),
                        ),
                        Text(
                          "${widget.data.data.length} Episode${widget.data.data.length > 1 ? "s" : ""}",
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withOpacity(1)),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              itemBuilder: (_, i) {
                final M3uEntry _entry = widget.data.data[i];
                return ListTile(
                  onTap: () async {
                    await loadVideo(context, _entry);
                  },
                  contentPadding: EdgeInsets.zero,
                  trailing: FavoriteIconButton(
                    iconSize: 20,
                    onPressedCallback: (bool isFav) async {
                      if (isFav) {
                        await _entry.addToFavorites(refId!);
                      } else {
                        await _entry.removeFromFavorites(refId!);
                      }
                      await fetchFav();
                    },
                    initValue: _entry.existsInFavorites("series"),
                  ),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: NetworkImageViewer(
                      url: _entry.attributes['tvg-logo']!,
                      width: 120,
                      height: 60,
                      color: card.darken(),
                      fit: BoxFit.cover,
                    ),
                    // child: Container(
                    //   width: w * .4,
                    //   height: c.maxHeight,
                    //   color: Colors.blue,
                    // ),
                  ),
                  title: Text(
                    _entry.title,
                  ),
                );
                // return SizedBox(
                //   height: 100,
                //   width: size.width,
                //   child: MaterialButton(
                //     padding: EdgeInsets.zero,
                //     height: 100,
                //     onPressed: () async {
                //       await loadVideo(context, _entry);
                //     },
                //     child: Center(
                //       child: LayoutBuilder(builder: (_, c) {
                //         final double w = c.maxWidth;
                //         return Row(
                //           crossAxisAlignment: CrossAxisAlignment.start,
                //           children: [
                // ClipRRect(
                //   borderRadius: BorderRadius.circular(5),
                //   child: NetworkImageViewer(
                //     url: _entry.attributes['tvg-logo']!,
                //     width: 150,
                //     height: c.maxHeight,
                //     color: card.darken(),
                //     fit: BoxFit.cover,
                //   ),
                //   // child: Container(
                //   //   width: w * .4,
                //   //   height: c.maxHeight,
                //   //   color: Colors.blue,
                //   // ),
                // ),
                //             const SizedBox(
                //               width: 10,
                //             ),
                //             Expanded(
                // child: Text(
                //   _entry.title,
                // ),
                //             ),
                //           ],
                //         );
                //       }),
                //     ),
                //   ),
                // );
              },
              separatorBuilder: (_, i) => Divider(
                color: Colors.white.withOpacity(.2),
              ),
              itemCount: widget.data.data.length,
            )
            // ...widget.data.data.map(
            //   (e) => Container(
            //     height: 100,
            //     width: size.width,
            //     color: Colors.red,
            //   ),
            // )
          ],
        ),
      ),
    );
  }
}
