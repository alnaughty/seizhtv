import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:seizhtv/data_containers/loaded_m3u_data.dart';
import 'package:seizhtv/extensions/color.dart';
import 'package:seizhtv/extensions/state.dart';
import 'package:seizhtv/globals/loader.dart';
import 'package:seizhtv/globals/network_image_viewer.dart';
import 'package:seizhtv/globals/palette.dart';
import 'package:seizhtv/globals/ui_additional.dart';
import 'package:z_m3u_handler/extension.dart';
import 'package:z_m3u_handler/z_m3u_handler.dart';

class SeriesPage extends StatefulWidget {
  const SeriesPage({super.key});

  @override
  State<SeriesPage> createState() => _SeriesPageState();
}

class _SeriesPageState extends State<SeriesPage>
    with ColorPalette, UIAdditional {
  // late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  late final ScrollController _scrollController;
  // final PopularMovieViewModel _popularMovieViewModel =
  //     PopularMovieViewModel.instance;
  // final UpcomingMovieViewModel _upcomingMovieViewModel =
  //     UpcomingMovieViewModel.instance;
  // final LatestMovieViewModel _latestMovieViewModel =
  //     LatestMovieViewModel.instance;

  @override
  void initState() {
    _scrollController = ScrollController();
    // _controller = VideoPlayerController.network(
    //   'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
    // );
    // _initializeVideoPlayerFuture = _controller.initialize();
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    // _controller.dispose();
    super.dispose();
  }

  final LoadedM3uData _vm = LoadedM3uData.instance;
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    return Scaffold(
      backgroundColor: card,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: appbar(3),
      ),
      body: StreamBuilder<CategorizedM3UData>(
        stream: _vm.stream,
        builder: (_, snapshot) {
          if (snapshot.hasError || !snapshot.hasData) {
            if (snapshot.hasError) {
              return Container();
            }
            return const SeizhTvLoader(
              label: "Retrieving Data",
            );
          }
          // final List<M3uEntry> _entries = ;
          final List<ClassifiedData> _cats = snapshot.data!.series;
          // _entries.categorize(needle: "title-clean");
          if (_cats.isEmpty) {
            return Center(
              child: Text(
                "No Live M3U Found!",
                style: TextStyle(
                  color: Colors.white.withOpacity(.5),
                ),
              ),
            );
          }
          return Scrollbar(
            controller: _scrollController,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: .75,
                children: List.generate(
                  _cats.length,
                  (index) {
                    final ClassifiedData _data = _cats[index];
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: GestureDetector(
                        onTap: () async {
                          await Navigator.pushNamed(
                            context,
                            "/series-details",
                            arguments: _data,
                          );
                        },
                        child: Column(
                          children: [
                            Expanded(
                              child: LayoutBuilder(
                                builder: (context, c) {
                                  final double h = c.maxHeight;
                                  final double w = c.maxWidth;
                                  return NetworkImageViewer(
                                    url: _data.data[0].attributes['tvg-logo']!,
                                    height: h,
                                    width: w,
                                    color: card.darken(),
                                    fit: BoxFit.cover,
                                  );
                                },
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: ColorPalette().highlight,
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(12),
                                    bottomRight: Radius.circular(12),
                                  ),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                width: double.infinity,
                                height: 45,
                                child: Align(
                                  alignment: AlignmentDirectional.centerStart,
                                  child: Text(
                                    _data.name.isEmpty ? "Unnamed" : _data.name,
                                    maxLines: 2,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      height: 1,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
          // return Scrollbar(
          //   controller: _scrollController,
          //   child: Padding(
          //     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          //     child: GridView.count(
          //       mainAxisSpacing: 10,
          //       crossAxisSpacing: 10,
          //       crossAxisCount: 2,
          //       childAspectRatio: .6,
          //       children: List.generate(
          //         _entries.length,
          //         (index) => ClipRRect(
          //           borderRadius: BorderRadius.circular(5),
          //           child: Column(
          //             children: [
          //               Expanded(
          //                 child: LayoutBuilder(builder: (context, c) {
          //                   final double h = c.maxHeight;
          //                   return NetworkImageViewer(
          //                     url: _cats.values.toList()[index].attributes['tvg-logo']!,
          //                     height: h,
          //                     color: card,
          //                     fit: BoxFit.cover,
          //                   );
          //                 }),
          //               ),
          //               Align(
          //                 alignment: Alignment.bottomCenter,
          //                 child: Container(
          //                   decoration: BoxDecoration(
          //                     color: ColorPalette().highlight,
          //                     borderRadius: const BorderRadius.only(
          //                       bottomLeft: Radius.circular(12),
          //                       bottomRight: Radius.circular(12),
          //                     ),
          //                   ),
          //                   padding: const EdgeInsets.symmetric(horizontal: 10),
          //                   width: double.infinity,
          //                   height: 50,
          //                   child: Align(
          //                     alignment: AlignmentDirectional.centerStart,
          //                     child: Text(
          //                       _entries[index].title.isEmpty
          //                           ? "Unnamed"
          //                           : _entries[index].title,
          //                       maxLines: 2,
          //                     ),
          //                   ),
          //                 ),
          //               ),
          //             ],
          //           ),
          //         ),
          //       ),
          //     ),
          //   ),
          // );
        },
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     // Wrap the play or pause in a call to `setState`. This ensures the
      //     // correct icon is shown.
      //     setState(() {
      //       // If the video is playing, pause it.
      //       if (_controller.value.isPlaying) {
      //         _controller.pause();
      //       } else {
      //         // If the video is paused, play it.
      //         _controller.play();
      //       }
      //     });
      //   },
      //   // Display the correct icon depending on the state of the player.
      //   child: Icon(
      //     _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
      //   ),
      // ),
      // body: SingleChildScrollView(
      //   child: Stack(
      //     children: [
      //       SizedBox(
      //         height: 600,
      //         child: Column(
      //           children: [
      //             // Expanded(
      //             //     child: FutureBuilder(
      //             //   future: _initializeVideoPlayerFuture,
      //             //   builder: (context, snapshot) {
      //             //     if (snapshot.connectionState == ConnectionState.done) {
      //             //       // If the VideoPlayerController has finished initialization, use
      //             //       // the data it provides to limit the aspect ratio of the video.
      //             //       return AspectRatio(
      //             //         aspectRatio: _controller.value.aspectRatio,
      //             //         // Use the VideoPlayer widget to display the video.
      //             //         child: VideoPlayer(_controller),
      //             //       );
      //             //     } else {
      //             //       // If the VideoPlayerController is still initializing, show a
      //             //       // loading spinner.
      //             //       return const Center(
      //             //         child: CircularProgressIndicator(),
      //             //       );
      //             //     }
      //             //   },
      //             // )),
      //             const Spacer()
      //           ],
      //         ),
      //       ),
      //       Container(
      //         padding: const EdgeInsets.symmetric(horizontal: 15),
      //         height: 600,
      //         child: Column(
      //           mainAxisAlignment: MainAxisAlignment.center,
      //           children: [
      //             Container(
      //               decoration: BoxDecoration(boxShadow: [
      //                 BoxShadow(
      //                     color: ColorPalette().card,
      //                     blurRadius: 30,
      //                     spreadRadius: 45)
      //               ], color: ColorPalette().card),
      //               height: 5,
      //             ),
      //           ],
      //         ),
      //       ),
      //       SizedBox(
      //         height: 1150,
      //         width: double.infinity,
      //         child: Column(
      //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //           children: [
      //             Padding(
      //               padding: const EdgeInsets.symmetric(horizontal: 15),
      //               child: filterChip([]),
      //             ),
      //             Column(
      //               crossAxisAlignment: CrossAxisAlignment.start,
      //               children: [
      //                 Padding(
      //                   padding: const EdgeInsets.symmetric(horizontal: 15),
      //                   child: Row(
      //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //                     children: [
      //                       MaterialButton(
      //                         padding:
      //                             const EdgeInsets.symmetric(horizontal: 15),
      //                         height: 35,
      //                         minWidth: 25,
      //                         elevation: 0,
      //                         color: const Color(0xff101010).withOpacity(0.2),
      //                         onPressed: () {},
      //                         child: const Text(
      //                           "Preview",
      //                           style: TextStyle(
      //                               fontSize: 12,
      //                               letterSpacing: 1.1,
      //                               fontWeight: FontWeight.w600),
      //                         ),
      //                       ),
      //                       SvgPicture.asset(
      //                         "assets/icons/audio.svg",
      //                         color: ColorPalette().white,
      //                       )
      //                     ],
      //                   ),
      //                 ),
      //                 const Padding(
      //                   padding: EdgeInsets.symmetric(horizontal: 15),
      //                   child: Text(
      //                     "BOB L'EPONGE - LE FILM : ÉPONGE EN EAUX TROUBLES Bande Annonce VF (Animation, 2020)",
      //                     maxLines: 2,
      //                     overflow: TextOverflow.ellipsis,
      //                     style: TextStyle(
      //                         fontWeight: FontWeight.w500,
      //                         fontSize: 24,
      //                         height: 1.1),
      //                   ),
      //                 ),
      //                 const SizedBox(
      //                   height: 8,
      //                 ),
      //                 Padding(
      //                   padding: const EdgeInsets.symmetric(horizontal: 15),
      //                   child: Row(
      //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //                     children: [
      //                       const Text("2022"),
      //                       SizedBox(
      //                         height: 25,
      //                         width: 40,
      //                         child: OutlinedButton(
      //                           style: ButtonStyle(
      //                             padding: MaterialStateProperty.all(
      //                                 const EdgeInsets.all(0)),
      //                             foregroundColor:
      //                                 MaterialStateProperty.all(Colors.white),
      //                             side: MaterialStateProperty.all(
      //                                 const BorderSide(
      //                               color: Colors.white,
      //                               style: BorderStyle.solid,
      //                               width: 2,
      //                             )),
      //                           ),
      //                           onPressed: () {},
      //                           child: const Center(child: Text("7+")),
      //                         ),
      //                       ),
      //                       const Text("Animation"),
      //                       const Text(
      //                         "1h 32m",
      //                       ),
      //                       SizedBox(
      //                         height: 25,
      //                         width: 40,
      //                         child: OutlinedButton(
      //                           style: ButtonStyle(
      //                             padding: MaterialStateProperty.all(
      //                                 const EdgeInsets.all(0)),
      //                             foregroundColor:
      //                                 MaterialStateProperty.all(Colors.white),
      //                             side: MaterialStateProperty.all(
      //                                 const BorderSide(
      //                               color: Colors.white,
      //                               style: BorderStyle.solid,
      //                               width: 2,
      //                             )),
      //                           ),
      //                           onPressed: () {},
      //                           child: const Center(child: Text("7.6")),
      //                         ),
      //                       ),
      //                       SizedBox(
      //                         height: 25,
      //                         width: 30,
      //                         child: MaterialButton(
      //                           color: Colors.grey,
      //                           padding: const EdgeInsets.all(0),
      //                           onPressed: () {},
      //                           child: const Text(
      //                             "HD",
      //                             style: TextStyle(fontWeight: FontWeight.w600),
      //                           ),
      //                         ),
      //                       ),
      //                     ],
      //                   ),
      //                 ),
      //                 const SizedBox(
      //                   height: 18,
      //                 ),
      //                 Padding(
      //                   padding: const EdgeInsets.symmetric(horizontal: 15),
      //                   child: Row(
      //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //                     children: [
      //                       MaterialButton(
      //                           minWidth: 150,
      //                           height: 48,
      //                           color: ColorPalette().white,
      //                           onPressed: () {},
      //                           child: Text(
      //                             "Watch now",
      //                             style: TextStyle(color: ColorPalette().black),
      //                           )),
      //                       Column(
      //                         children: [
      //                           SvgPicture.asset(
      //                             "assets/icons/favourites.svg",
      //                             color: ColorPalette().white,
      //                           ),
      //                           const Text(
      //                             "Add to Favorites",
      //                             style: TextStyle(
      //                               fontSize: 12,
      //                             ),
      //                           )
      //                         ],
      //                       ),
      //                       Column(
      //                         children: [
      //                           SvgPicture.asset(
      //                             "assets/icons/info.svg",
      //                             color: ColorPalette().white,
      //                           ),
      //                           const Text(
      //                             "More Info",
      //                             style: TextStyle(fontSize: 12),
      //                           )
      //                         ],
      //                       )
      //                     ],
      //                   ),
      //                 ),
      //                 const SizedBox(height: 20),
      //                 const Padding(
      //                   padding: EdgeInsets.symmetric(horizontal: 15),
      //                   child: Text(
      //                     "Popular",
      //                     style: TextStyle(
      //                         fontSize: 18, fontWeight: FontWeight.w500),
      //                   ),
      //                 ),
      //                 // moviesListWidgets(
      //                 //     onPressed: (id) {
      //                 //       Navigator.push(
      //                 //         context,
      //                 //         MaterialPageRoute(
      //                 //           builder: (context) => MovieDetailsPage(id: id),
      //                 //         ),
      //                 //       );
      //                 //     },
      //                 //     viewModel: _popularMovieViewModel),
      //                 // const Padding(
      //                 //   padding: EdgeInsets.symmetric(horizontal: 15),
      //                 //   child: Text(
      //                 //     "Upcoming",
      //                 //     style: TextStyle(
      //                 //         fontSize: 18, fontWeight: FontWeight.w500),
      //                 //   ),
      //                 // ),
      //                 // moviesListWidgets(
      //                 //     onPressed: (id) {
      //                 //       Navigator.push(
      //                 //         context,
      //                 //         MaterialPageRoute(
      //                 //           builder: (context) => MovieDetailsPage(id: id),
      //                 //         ),
      //                 //       );
      //                 //     },
      //                 //     viewModel: _upcomingMovieViewModel),
      //                 // const Padding(
      //                 //   padding: EdgeInsets.symmetric(horizontal: 15),
      //                 //   child: Text(
      //                 //     "Recently Added",
      //                 //     style: TextStyle(
      //                 //         fontSize: 18, fontWeight: FontWeight.w500),
      //                 //   ),
      //                 // ),
      //                 // moviesListWidgets(
      //                 //   onPressed: (id) {
      //                 //     Navigator.push(
      //                 //       context,
      //                 //       MaterialPageRoute(
      //                 //         builder: (context) => MovieDetailsPage(id: id),
      //                 //       ),
      //                 //     );
      //                 //   },
      //                 //   viewModel: _upcomingMovieViewModel,
      //                 // ),
      //               ],
      //             )
      //           ],
      //         ),
      //       )
      //     ],
      //   ),
      // ),
    );
  }
}
