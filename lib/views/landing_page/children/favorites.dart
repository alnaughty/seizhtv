import 'package:flutter/material.dart';
import 'package:seizhtv/data_containers/favorites.dart';
import 'package:seizhtv/extensions/color.dart';
import 'package:seizhtv/extensions/state.dart';
import 'package:seizhtv/globals/data.dart';
import 'package:seizhtv/globals/loader.dart';
import 'package:seizhtv/globals/network_image_viewer.dart';
import 'package:seizhtv/globals/palette.dart';
import 'package:z_m3u_handler/z_m3u_handler.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> with ColorPalette {
  final Favorites _vm = Favorites.instance;
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
    return Scaffold(
      backgroundColor: card,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: appbar(4),
      ),
      body: StreamBuilder<CategorizedM3UData>(
          stream: _vm.stream,
          builder: (_, snapshot) {
            if (snapshot.hasError || !snapshot.hasData) {
              if (!snapshot.hasData) {
                return const SeizhTvLoader(
                  hasBackgroundColor: false,
                );
              }
              return Container();
            }
            final CategorizedM3UData _result = snapshot.data!;
            return ListView(
              children: [
                if (_result.live.isNotEmpty) ...{},
                if (_result.movies.isNotEmpty) ...{},
                if (_result.series.isNotEmpty) ...{
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Text(
                      "Series",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: double.maxFinite,
                    height: 180,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (_, i) {
                        final M3uEntry _entry = _result.series
                            .expand((element) => element.data)
                            .toList()[i];
                        return SizedBox(
                          width: 120,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: GestureDetector(
                              onTap: () async {
                                await _entry.removeFromFavorites(refId!);
                                await fetchFav();
                              },
                              child: Column(
                                children: [
                                  Expanded(
                                    child: LayoutBuilder(builder: (_, c) {
                                      return NetworkImageViewer(
                                        url: _entry.attributes['tvg-logo']!,
                                        width: 120,
                                        height: c.maxHeight,
                                        color: card,
                                        fit: BoxFit.cover,
                                      );
                                    }),
                                  ),
                                  Container(
                                    color: card.darken(),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 3),
                                    height: 55,
                                    child: Center(
                                      child: Text(
                                        _entry.title,
                                        style: const TextStyle(
                                          height: 1,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (_, i) => const SizedBox(
                        width: 10,
                      ),
                      itemCount: _result.series
                          .expand((element) => element.data)
                          .toList()
                          .length,
                    ),
                  ),
                },
              ],
            );
          }),
      // body: SingleChildScrollView(
      //   child: Column(
      //     crossAxisAlignment: CrossAxisAlignment.start,
      //     children: [
      //       const Padding(
      //         padding: EdgeInsets.symmetric(horizontal: 15),
      //         child: Text(
      //           "Live TV",
      //           style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      //         ),
      //       ),
      //       const SizedBox(
      //         height: 8,
      //       ),
      //       SizedBox(
      //         height: 210,
      //         width: double.infinity,
      //         child: GridView.count(
      //             scrollDirection: Axis.horizontal,
      //             crossAxisCount: 2,
      //             mainAxisSpacing: 10.0,
      //             crossAxisSpacing: 10.0,
      //             childAspectRatio: 1.0,
      //             children: List.generate(9, (index) {
      //               return Stack(
      //                 children: [
      //                   Container(
      //                     decoration: BoxDecoration(
      //                         image: const DecorationImage(
      //                             image: AssetImage(
      //                               "assets/images/image 24.png",
      //                             ),
      //                             fit: BoxFit.cover),
      //                         color: Colors.teal[100 * (index % 9)],
      //                         borderRadius: BorderRadius.circular(12)),
      //                     alignment: Alignment.center,
      //                   ),
      //                   Align(
      //                     alignment: Alignment.bottomCenter,
      //                     child: Container(
      //                       decoration: BoxDecoration(
      //                           color: ColorPalette().highlight,
      //                           borderRadius: const BorderRadius.only(
      //                               bottomLeft: Radius.circular(12),
      //                               bottomRight: Radius.circular(12))),
      //                       padding: const EdgeInsets.symmetric(horizontal: 10),
      //                       width: double.infinity,
      //                       height: 30,
      //                       child: Column(
      //                         mainAxisAlignment: MainAxisAlignment.center,
      //                         crossAxisAlignment: CrossAxisAlignment.start,
      //                         children: [
      //                           Text('grid item $index'),
      //                         ],
      //                       ),
      //                     ),
      //                   ),
      //                 ],
      //               );
      //             })),
      //       ),
      //       const SizedBox(
      //         height: 16,
      //       ),
      // const Padding(
      //   padding: EdgeInsets.symmetric(horizontal: 15),
      //   child: Text(
      //     "Movies",
      //     style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      //   ),
      // ),
      //       // moviesListWidgets(),
      //       const SizedBox(
      //         height: 16,
      //       ),
      //       const Padding(
      //         padding: EdgeInsets.symmetric(horizontal: 15),
      //         child: Text(
      //           "Series",
      //           style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      //         ),
      //       ),
      //       // moviesListWidgets()
      //     ],
      //   ),
      // ),
    );
  }
}
