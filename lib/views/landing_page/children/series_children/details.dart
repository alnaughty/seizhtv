import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:seizhtv/extensions/classified_data.dart';
import 'package:seizhtv/extensions/state.dart';
import 'package:seizhtv/globals/palette.dart';
import 'package:seizhtv/services/tv_series_api.dart';
import 'package:z_m3u_handler/z_m3u_handler.dart';
import '../../../../data_containers/favorites.dart';
import '../../../../globals/data.dart';
import '../../../../globals/favorite_button.dart';
import '../../../../globals/network.dart';
import '../../../../globals/ui_additional.dart';
import '../../../../globals/video_loader.dart';
import '../../../../models/tvseries_details.dart';
import '../../../../viewmodel/seriesdetails.dart';
import '../details.dart';
import 'episode.dart';

class SeriesDetailsPage extends StatefulWidget {
  const SeriesDetailsPage({super.key, required this.data, required this.title});
  final ClassifiedData data;
  final String title;

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
  late final BehaviorSubject<bool> _status;
  late TabController _tabController;
  late int? chosenIndex = widget.data.data.length == 1 ? 0 : null;
  // late bool value = widget.data.data[chosenIndex!].existsInFavorites("movie");

  @override
  void initState() {
    fetchFav();
    searchTV(title: widget.title).then((value) {
      if (value != null) {
        seriesDetails(value);
      }
    });
    _tabController = TabController(vsync: this, length: 2);
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
                        "assets/images/app-icon.png",
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          result.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 22,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 8),
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
                            const SizedBox(width: 15),
                            Text(
                                "${result.numOfSeason} Season${result.numOfSeason == 1 ? "" : "s"}"),
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
                        const Text(
                          "Storyline",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text("${result.overview}"),
                        const SizedBox(height: 20),
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
                                        "Episodes",
                                        style: TextStyle(
                                          color: white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        "Info",
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
            return const Center(
              child: CircularProgressIndicator(color: Colors.grey),
            );
          },
        ),
      ),
    );
  }
}
