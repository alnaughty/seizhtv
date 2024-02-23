import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:seizhtv/extensions/classified_data.dart';
import 'package:seizhtv/extensions/state.dart';
import 'package:seizhtv/globals/palette.dart';
import 'package:seizhtv/services/tv_series_api.dart';
import 'package:z_m3u_handler/z_m3u_handler.dart';
import '../../../../data_containers/favorites.dart';
import '../../../../globals/data.dart';
import '../../../../globals/network.dart';
import '../../../../globals/network_image_viewer.dart';
import '../../../../globals/ui_additional.dart';
import '../../../../globals/video_loader.dart';
import '../../../../models/tvseries_details.dart';
import '../../../../viewmodel/seriesdetails.dart';
import '../details.dart';
import 'episode.dart';

class SeriesDetailsPage extends StatefulWidget {
  const SeriesDetailsPage(
      {super.key, required this.data, required this.title, this.year});
  final ClassifiedData data;
  final String title;
  final String? year;

  @override
  State<SeriesDetailsPage> createState() => _SeriesDetailsPageState();
}

class _SeriesDetailsPageState extends State<SeriesDetailsPage>
    with
        UIAdditional,
        TVSeriesAPI,
        ColorPalette,
        VideoLoader,
        SingleTickerProviderStateMixin {
  static final SeriesDetailsViewModel _viewModel =
      SeriesDetailsViewModel.instance;
  static final Favorites _vm = Favorites.instance;
  static final ZM3UHandler _handler = ZM3UHandler.instance;
  late bool isFavorite = widget.data.isInFavorite("series");
  late TabController _tabController;
  late int? chosenIndex = widget.data.data.length == 1 ? 0 : null;
  late ClassifiedData data;
  List<M3uEntry> seasons = [];

  @override
  void initState() {
    fetchFav();
    print("TITLE: ${widget.title}");
    print("YEAR RELEASE: ${widget.year}");
    searchTV(title: widget.title, year: widget.year).then((value) {
      if (value != null) {
        seriesDetails(value);
      }
    });

    data = widget.data;

    for (final M3uEntry datas in widget.data.data) {
      if (datas.title.length >= 5) {
        datas.title = datas.title.substring(0, datas.title.length - 3);
      }
    }
    final titles = widget.data.data.map((e) => e.title).toSet();

    for (final title in titles) {
      final item =
          widget.data.data.firstWhere((element) => element.title == title);
      seasons.add(item);
    }

    _tabController = TabController(vsync: this, length: 2);
    print("DATAAAA: ${seasons.length}");
    super.initState();
  }

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
  void dispose() {
    _tabController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: card,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: appbar1(),
      ),
      body: SingleChildScrollView(
        child: StreamBuilder<TVSeriesDetails>(
          stream: _viewModel.stream,
          builder: (context, snapshot) {
            if (snapshot.hasData && !snapshot.hasError) {
              final TVSeriesDetails result = snapshot.data!;

              return Column(
                children: [
                  SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      imageUrl: "${Network.imageUrl}${result.backdropPath}",
                      placeholder: (context, url) => shimmerLoading(
                        highlight,
                        200,
                        width: double.infinity,
                      ),
                      errorWidget: (context, url, error) => Image.asset(
                        "${widget.data.data[0].attributes['tvg-logo']}",
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.data.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 22,
                                    height: 1.1),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              width: size.width * .30,
                              height: 40,
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.white.withOpacity(.7)),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: MaterialButton(
                                padding: EdgeInsets.zero,
                                onPressed: () async {
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
                                              borderRadius:
                                                  BorderRadius.circular(10.0)),
                                          child: Container(
                                            height: 50,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 15, horizontal: 20),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  "Added_to_Favorites".tr(),
                                                  style: const TextStyle(
                                                      fontSize: 16),
                                                ),
                                                IconButton(
                                                  padding:
                                                      const EdgeInsets.all(0),
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
                                  child: !isFavorite
                                      ? Text(
                                          "Add_to_favorites".tr(),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.white.withOpacity(.7),
                                          ),
                                        )
                                      : Text(
                                          "Favorites".tr(),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white.withOpacity(.7),
                                          ),
                                        ),
                                ),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Text(DateFormat('yyyy').format(result.date!)),
                            const SizedBox(width: 15),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white),
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(5),
                                ),
                              ),
                              child: Text(
                                result.voteAverage.toStringAsFixed(1),
                              ),
                            ),
                            // const SizedBox(width: 15),
                            // RichText(
                            //   text: TextSpan(
                            //     text: "${seasons.length} ",
                            //     style: const TextStyle(
                            //       fontFamily: "Poppins",
                            //     ),
                            //     children: [
                            //       TextSpan(
                            //         text:
                            //             "Season${seasons.length == 1 ? "" : "s"}"
                            //                 .tr(),
                            //       ),
                            //     ],
                            //   ),
                            // ),
                            const SizedBox(width: 15),
                            SizedBox(
                              height: 25,
                              width: 30,
                              child: MaterialButton(
                                color: Colors.grey,
                                padding: const EdgeInsets.all(0),
                                onPressed: () {},
                                child: const Text(
                                  "HD",
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        Text(
                          "Storyline".tr(),
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "${result.overview}",
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w400),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 550,
                          child: Column(
                            children: [
                              Container(
                                decoration: const BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(color: Colors.grey)),
                                ),
                                child: DefaultTabController(
                                  length: 2,
                                  child: TabBar(
                                    controller: _tabController,
                                    indicatorColor: orange,
                                    indicatorWeight: 2,
                                    tabs: [
                                      Text(
                                        "Episodes".tr(),
                                        style: TextStyle(
                                          color: white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        "Info".tr(),
                                        style: TextStyle(
                                          color: white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: TabBarView(
                                  controller: _tabController,
                                  children: [
                                    EpisodePage(
                                      data: data,
                                      seasonLength: seasons.length,
                                    ),
                                    DetailsPage(
                                      id: result.id,
                                      movie: null,
                                      series: result,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              );
            }
            return Column(
              children: [
                SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: NetworkImageViewer(
                    url: "${widget.data.data[0].attributes['tvg-logo']}",
                    width: 85,
                    height: 60,
                    fit: BoxFit.cover,
                    color: highlight,
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              widget.data.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 22,
                                height: 1.1,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            width: size.width * .30,
                            height: 40,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.white.withOpacity(.7)),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: MaterialButton(
                              padding: EdgeInsets.zero,
                              onPressed: () async {
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
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        child: Container(
                                          height: 50,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 15, horizontal: 20),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "Added_to_Favorites".tr(),
                                                style: const TextStyle(
                                                    fontSize: 16),
                                              ),
                                              IconButton(
                                                padding:
                                                    const EdgeInsets.all(0),
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
                                child: !isFavorite
                                    ? Text(
                                        "Add_to_favorites".tr(),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.white.withOpacity(.7),
                                        ),
                                      )
                                    : Text(
                                        "Favorites".tr(),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white.withOpacity(.7),
                                        ),
                                      ),
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        height: 550,
                        child: Column(
                          children: [
                            Container(
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: Colors.grey),
                                ),
                              ),
                              child: DefaultTabController(
                                length: 2,
                                child: TabBar(
                                  controller: _tabController,
                                  indicatorColor: orange,
                                  indicatorWeight: 2,
                                  tabs: [
                                    Text(
                                      "Episodes".tr(),
                                      style: TextStyle(
                                        color: white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      "Info".tr(),
                                      style: TextStyle(
                                        color: white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: TabBarView(
                                controller: _tabController,
                                children: [
                                  EpisodePage(
                                    data: widget.data,
                                    seasonLength: seasons.length,
                                  ),
                                  Center(
                                    child: Text(
                                      "No_data_available".tr(),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}
