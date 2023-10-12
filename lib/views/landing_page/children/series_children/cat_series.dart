// ignore_for_file: deprecated_member_use

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:seizhtv/views/landing_page/children/series_children/details.dart';
import 'package:z_m3u_handler/extension.dart';
import 'package:z_m3u_handler/z_m3u_handler.dart';
import '../../../../data_containers/favorites.dart';
import '../../../../data_containers/loaded_m3u_data.dart';
import '../../../../globals/data.dart';
import '../../../../globals/favorite_button.dart';
import '../../../../globals/loader.dart';
import '../../../../globals/network_image_viewer.dart';
import '../../../../globals/palette.dart';
import '../../../../globals/ui_additional.dart';
import '../../../../globals/video_loader.dart';

class SeriesCategoryPage extends StatefulWidget {
  const SeriesCategoryPage({super.key, required this.category});

  final String category;

  @override
  State<SeriesCategoryPage> createState() => SeriesCategoryPageState();
}

class SeriesCategoryPageState extends State<SeriesCategoryPage>
    with ColorPalette, VideoLoader, UIAdditional {
  final LoadedM3uData _vm = LoadedM3uData.instance;
  static final Favorites _vm1 = Favorites.instance;
  static final ZM3UHandler _handler = ZM3UHandler.instance;
  late List<ClassifiedData> seriesData = [];
  List<ClassifiedData> favData = [];
  static final Favorites _fav = Favorites.instance;
  late List<ClassifiedData> _favdata;

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
        final List<ClassifiedData> series = result.series
          ..sort((a, b) => a.name.compareTo(b.name));

        final Iterable<ClassifiedData> data =
            series.where((element) => element.name.contains(widget.category));

        print("${data.first.name}  ${data.first.data.classify().length}");

        return GridView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: .8,
                mainAxisSpacing: 5,
                crossAxisSpacing: 10),
            itemCount: data.first.data.classify().length,
            itemBuilder: (context, i) {
              final ClassifiedData datas = data.first.data.classify()[i];
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
                  String result1 = datas.name.replaceAll(
                      RegExp(r"[(]+[a-zA-Z]+[)]|[0-9]|[|]\s+[0-9]+\s[|]"), '');
                  String result2 = result1.replaceAll(
                      RegExp(r"[|]+[a-zA-Z]+[|]|[a-zA-Z]+[|]"), '');

                  Navigator.push(
                    context,
                    PageTransition(
                      child: SeriesDetailsPage(
                        data: datas,
                        title: result2,
                      ),
                      type: PageTransitionType.rightToLeft,
                    ),
                  );
                },
                child: Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 10, right: 10),
                      child: LayoutBuilder(
                        builder: (context, c) {
                          final double w = c.maxWidth;
                          return Tooltip(
                            message: datas.name,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: NetworkImageViewer(
                                    url: datas.data[0].attributes['tvg-logo'],
                                    width: w,
                                    height: 53,
                                    fit: BoxFit.cover,
                                    color: highlight,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Tooltip(
                                  message: datas.name,
                                  child: Text(
                                    datas.name,
                                    style: const TextStyle(fontSize: 12),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text("${datas.data.length} ",
                                        style: const TextStyle(
                                            fontSize: 12, color: Colors.grey)),
                                    Text("Episodes".tr(),
                                        style: const TextStyle(
                                            fontSize: 12, color: Colors.grey)),
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
                                      borderRadius: BorderRadius.circular(10.0),
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
                              for (M3uEntry m3u in datas.data) {
                                await m3u.addToFavorites(refId!);
                              }
                            } else {
                              for (M3uEntry m3u in datas.data) {
                                await m3u.removeFromFavorites(refId!);
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
            });
      },
    );
  }
}
