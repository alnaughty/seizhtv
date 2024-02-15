import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:seizhtv/globals/ui_additional.dart';
import 'package:seizhtv/models/movie_details.dart';
import 'package:seizhtv/viewmodel/cast_vm.dart';
import '../../../globals/network.dart';
import '../../../globals/palette.dart';
import '../../../models/cast.dart';
import '../../../models/tvseries_details.dart';
import '../../../services/movie_api.dart';
import '../../../services/tv_series_api.dart';
import '../../../viewmodel/moviedetails.dart';

class DetailsPage extends StatefulWidget {
  const DetailsPage({super.key, required this.id, this.movie, this.series});
  final int id;
  final MovieDetails? movie;
  final TVSeriesDetails? series;

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage>
    with MovieAPI, UIAdditional, ColorPalette, TVSeriesAPI {
  static final MovieDetailsViewModel _viewModel =
      MovieDetailsViewModel.instance;
  static final CastViewModel _castViewModel = CastViewModel.instance;

  @override
  void initState() {
    init();
    super.initState();
  }

  init() async {
    widget.series == null
        ? await cast(widget.movie!.id)
        : await tvSeriesCast(widget.series!.id);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      elevation: 0,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Row(
              children: [
                RichText(
                  text: TextSpan(
                    text: "Directors".tr(),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      fontFamily: "Poppins",
                    ),
                    children: const [
                      TextSpan(text: " :"),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      widget.movie != null
                          ? ""
                          : widget.series!.createdby!
                              .map((it) => it.name)
                              .join(' / '),
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                RichText(
                  text: TextSpan(
                    text: "Release_Date".tr(),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      fontFamily: "Poppins",
                    ),
                    children: const [
                      TextSpan(text: " :"),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    DateFormat('MMMM dd, yyyy').format(widget.series == null
                        ? widget.movie!.date!
                        : widget.series!.date!),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                RichText(
                  text: TextSpan(
                    text: "Genre".tr(),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      fontFamily: "Poppins",
                    ),
                    children: const [
                      TextSpan(text: " :"),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      widget.movie == null
                          ? widget.series!.genres!
                              .map((it) => it.name)
                              .join(' / ')
                          : widget.movie!.genres!
                              .map((it) => it.name)
                              .join(' / '),
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              "Cast".tr(),
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 170,
              child: StreamBuilder<List<CastModel>>(
                stream: _castViewModel.stream,
                builder: (context, snapshot) {
                  if (snapshot.hasData && !snapshot.hasError) {
                    if (snapshot.data!.isEmpty) {
                      return Center(
                        child: Text(
                          "No_data_available".tr(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }
                    if (snapshot.data!.isNotEmpty) {
                      final List<CastModel> result = snapshot.data!;

                      return ListView.separated(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: result.length,
                        itemBuilder: (_, i) {
                          final CastModel cast = result[i];

                          return SizedBox(
                            width: 80,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: SizedBox(
                                    height: 80,
                                    width: 75,
                                    child: CachedNetworkImage(
                                      fit: BoxFit.cover,
                                      imageUrl:
                                          "${Network.imageUrl}${cast.profilePath}",
                                      placeholder: (context, url) =>
                                          shimmerLoading(
                                        highlight,
                                        80,
                                        width: double.infinity,
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Image.asset(
                                        "assets/images/logo.png",
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  cast.name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                                Text(
                                  cast.character,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color:
                                        ColorPalette().white.withOpacity(0.5),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                )
                              ],
                            ),
                          );
                        },
                        separatorBuilder: (c, i) => const SizedBox(width: 10),
                      );
                    }
                  }
                  return const CircularProgressIndicator(color: Colors.grey);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
