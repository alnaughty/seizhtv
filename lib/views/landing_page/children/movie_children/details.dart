// ignore_for_file: avoid_print, deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:seizhtv/extensions/m3u_entry.dart';
import 'package:seizhtv/extensions/state.dart';
import 'package:seizhtv/globals/ui_additional.dart';
import 'package:seizhtv/models/movie_details.dart';
import 'package:z_m3u_handler/z_m3u_handler.dart';
import '../../../../data_containers/favorites.dart';
import '../../../../globals/data.dart';
import '../../../../globals/favorite_button.dart';
import '../../../../globals/network.dart';
import '../../../../globals/network_image_viewer.dart';
import '../../../../globals/palette.dart';
import '../../../../globals/video_loader.dart';
import '../../../../services/movie_api.dart';
import '../../../../viewmodel/moviedetails.dart';
import '../details.dart';

class MovieDetailsPage extends StatefulWidget {
  const MovieDetailsPage({super.key, required this.data, required this.title});
  // final ClassifiedData data;
  final M3uEntry data;
  final String title;

  @override
  State<MovieDetailsPage> createState() => _MovieDetailsPageState();
}

class _MovieDetailsPageState extends State<MovieDetailsPage>
    with UIAdditional, MovieAPI, ColorPalette, VideoLoader {
  static final MovieDetailsViewModel _viewModel =
      MovieDetailsViewModel.instance;
  static final Favorites _vm = Favorites.instance;
  static final ZM3UHandler _handler = ZM3UHandler.instance;
  late int? chosenIndex = 0;
  //  widget.data.data.length == 1 ? 0 : null;
  late bool value = widget.data.existsInFavorites("movie");
  // .data[chosenIndex!].existsInFavorites("movie");

  @override
  void initState() {
    fetchFav();
    print("MOVIE TITLE: ${widget.title}");
    searchMovie(title: widget.title).then((value) {
      if (value != null) {
        print("MOVIE DETAILS: $value");
        movieDetails(value);
      }
    });
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
          child: StreamBuilder<MovieDetails>(
        stream: _viewModel.stream,
        builder: (context, snapshot) {
          if (snapshot.hasData && !snapshot.hasError) {
            final MovieDetails result = snapshot.data!;

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
                      "${widget.data.attributes['tvg-logo']}",
                      // "assets/images/logo.png",
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
                      Text(
                        widget.data.title,
                        // result.title,
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
                            padding: const EdgeInsets.symmetric(horizontal: 10),
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
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          button3(
                            title: "Watch_Now".tr(),
                            icon: "assets/icons/watchNow.svg",
                            onpress: () async {
                              // Navigator.of(context).pop(null);
                              widget.data.addToHistory(refId!);
                              await loadVideo(context, widget.data);
                            },
                          ),
                          Column(
                            children: [
                              FavoriteIconButton(
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
                                            borderRadius: BorderRadius.circular(
                                              10.0,
                                            ),
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 20,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  "Added_to_Favorites".tr(),
                                                  style: const TextStyle(
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
                                    await widget.data.addToFavorites(refId!);
                                  } else {
                                    await widget.data
                                        .removeFromFavorites(refId!);
                                  }
                                  await fetchFav();
                                },
                                initValue:
                                    widget.data.existsInFavorites("movie"),
                                iconSize: 35,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "Add_to_favorites".tr(),
                                style: const TextStyle(fontSize: 12),
                              )
                            ],
                          )

                          // Column(
                          //   children: [
                          //     SvgPicture.asset(
                          //       "assets/icons/subtitle.svg",
                          //       color: ColorPalette().white,
                          //     ),
                          //     const Text(
                          //       "Subtitle",
                          //       style: TextStyle(fontSize: 12),
                          //     )
                          //   ],
                          // ),
                          // Column(
                          //   children: [
                          //     SvgPicture.asset(
                          //       "assets/icons/record.svg",
                          //       color: ColorPalette().white,
                          //     ),
                          //     const Text(
                          //       "Record",
                          //       style: TextStyle(fontSize: 12),
                          //     )
                          //   ],
                          // ),
                        ],
                      ),
                      const SizedBox(height: 25),
                      Text(
                        "Storyline".tr(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text("${result.overview}"),
                      // StreamBuilder<MovieDetails>(
                      //   stream: _viewModel.stream,
                      //   builder: (context, snapshot) {
                      //     if (snapshot.hasData && !snapshot.hasError) {
                      //       final MovieDetails result = snapshot.data!;
                      //       return DetailsPage(
                      //         id: result.id,
                      //         movie: result,
                      //       );
                      //     }
                      //     return const CircularProgressIndicator(
                      //         color: Colors.grey);
                      //   },
                      // ),
                      DetailsPage(
                        id: result.id,
                        series: null,
                        movie: result,
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
          return Column(
            children: [
              SizedBox(
                height: 200,
                width: double.infinity,
                child: NetworkImageViewer(
                  url: "${widget.data.attributes['tvg-logo']}",
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
                    Text(
                      widget.data.title,
                      // widget.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 22,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        button3(
                          title: "Watch_Now".tr(),
                          icon: "assets/icons/watchNow.svg",
                          onpress: () async {
                            Navigator.of(context).pop(null);
                            widget.data.addToHistory(refId!);
                            await loadVideo(
                              context,
                              widget.data,
                            );
                          },
                        ),
                        Column(
                          children: [
                            FavoriteIconButton(
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
                                          borderRadius: BorderRadius.circular(
                                            10.0,
                                          ),
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                          ),
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
                                  await widget.data.addToFavorites(refId!);
                                } else {
                                  await widget.data.removeFromFavorites(refId!);
                                }
                                await fetchFav();
                              },
                              initValue: widget.data.existsInFavorites("movie"),
                              iconSize: 35,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Add_to_favorites".tr(),
                              style: const TextStyle(fontSize: 12),
                            )
                          ],
                        )
                      ],
                    ),
                    const SizedBox(height: 25),
                    Text(
                      "Storyline".tr(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text("No_data_available".tr()),
                    const SizedBox(height: 40),
                    Row(
                      children: [
                        RichText(
                          text: TextSpan(
                            text: "Directors".tr(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              fontFamily: "Poppins",
                            ),
                            children: const [
                              TextSpan(text: " :"),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        const Expanded(
                            child: SizedBox(
                                width: double.infinity, child: Text(""))),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        RichText(
                          text: TextSpan(
                            text: "Release_Date".tr(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              fontFamily: "Poppins",
                            ),
                            children: const [
                              TextSpan(text: " :"),
                            ],
                          ),
                        ),
                        const SizedBox(width: 15),
                        const Expanded(
                          child: Text(
                            "",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    RichText(
                      text: TextSpan(
                        text: "Genre".tr(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          fontFamily: "Poppins",
                        ),
                        children: const [
                          TextSpan(text: " :"),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Cast".tr(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 70,
                      child: Center(
                        child: Text(
                          "No_data_available".tr(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          );
        },
      )),
    );
  }
}
