// ignore_for_file: deprecated_member_use

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:seizhtv/extensions/m3u_entry.dart';
import 'package:z_m3u_handler/z_m3u_handler.dart';
import '../../../../data_containers/loaded_m3u_data.dart';
import '../../../../globals/data.dart';
import '../../../../globals/favorite_button.dart';
import '../../../../globals/loader.dart';
import '../../../../globals/network_image_viewer.dart';
import '../../../../globals/palette.dart';
import '../../../../globals/ui_additional.dart';
import '../../../../globals/video_loader.dart';
import 'details.dart';

class MovieCategoryPage extends StatefulWidget {
  const MovieCategoryPage({super.key, required this.category});
  final String category;

  @override
  State<MovieCategoryPage> createState() => _MovieCategoryPageState();
}

class _MovieCategoryPageState extends State<MovieCategoryPage>
    with ColorPalette, VideoLoader, UIAdditional {
  final LoadedM3uData _vm = LoadedM3uData.instance;
  final LoadedM3uData _vm1 = LoadedM3uData.instance;
  static final ZM3UHandler _handler = ZM3UHandler.instance;

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
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _vm.stream,
        builder: (context, snapshot) {
          if (snapshot.hasError || !snapshot.hasData) {
            if (!snapshot.hasData) {
              return const SeizhTvLoader(
                hasBackgroundColor: false,
              );
            }
            return Container();
          }

          final CategorizedM3UData result = snapshot.data!;
          final List<ClassifiedData> movie = result.movies;
          final List<M3uEntry> _data = movie
              .where((element) => element.name.contains(widget.category))
              .expand((element) => element.data)
              .toList()
            ..sort((a, b) => a.title.compareTo(b.title));

          return GridView.builder(
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, mainAxisExtent: 145),
            itemCount: _data.length,
            itemBuilder: (context, index) {
              final M3uEntry item = _data[index];

              return GestureDetector(
                onTap: () async {
                  String result1 = item.title.replaceAll(
                      RegExp(r"[0-9]|[(]+[0-9]+[)]|[|]\s+[0-9]+\s[|]"), '');
                  String result2 = result1.replaceAll(
                      RegExp(r"[|]+[a-zA-Z]+[|]|[a-zA-Z]+[|] "), '');

                  Navigator.push(
                    context,
                    PageTransition(
                      child: MovieDetailsPage(
                        data: item,
                        title: result2,
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
                            return Tooltip(
                              message: item.title,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: NetworkImageViewer(
                                      url: item.attributes['tvg-logo'],
                                      width: w,
                                      height: 90,
                                      fit: BoxFit.cover,
                                      color: highlight,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Tooltip(
                                    message: item.title,
                                    child: Text(
                                      item.title,
                                      style: const TextStyle(fontSize: 12),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
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
                                        Navigator.of(context).pop(true);
                                      },
                                    );
                                    return Dialog(
                                      alignment: Alignment.topCenter,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Added_to_Favorites".tr(),
                                              style:
                                                  const TextStyle(fontSize: 16),
                                            ),
                                            IconButton(
                                              padding: const EdgeInsets.all(0),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              icon: const Icon(
                                                  Icons.close_rounded),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                                await item.addToFavorites(refId!);
                              } else {
                                await item.removeFromFavorites(refId!);
                              }
                              await fetchFav();
                            },
                            initValue: item.existsInFavorites("movie"),
                            iconSize: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );

          // return ListView.separated(
          //   shrinkWrap: true,
          //   itemBuilder: (_, i) {
          //     final ClassifiedData data = movie[i];
          //     return ListTile(
          //       onTap: () async {
          //         await Navigator.push(
          //           context,
          //           PageTransition(
          //               child: ClassifiedMovieData(data: data),
          //               type: PageTransitionType.leftToRight),
          //         );
          //       },
          //       trailing: const Icon(Icons.chevron_right),
          //       contentPadding: const EdgeInsets.symmetric(horizontal: 15),
          //       subtitle: Text("${data.data.classify().length} Entries"),
          //       leading: SvgPicture.asset(
          //         "assets/icons/logo-ico.svg",
          //         width: 50,
          //         color: orange,
          //         fit: BoxFit.contain,
          //       ),
          //       title: Hero(
          //         tag: data.name.toUpperCase(),
          //         child: Material(
          //           color: Colors.transparent,
          //           elevation: 0,
          //           child: Text(data.name),
          //         ),
          //       ),
          //     );
          //   },
          //   itemCount: movie.length,
          //   separatorBuilder: (_, __) => const SizedBox(height: 5),
          // );
        });
  }
}
