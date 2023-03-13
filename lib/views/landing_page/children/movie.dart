import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:page_transition/page_transition.dart';
import 'package:seizhtv/data_containers/loaded_m3u_data.dart';
import 'package:seizhtv/extensions/color.dart';
import 'package:seizhtv/extensions/state.dart';
import 'package:seizhtv/globals/loader.dart';
import 'package:seizhtv/globals/palette.dart';
import 'package:seizhtv/globals/ui_additional.dart';
import 'package:seizhtv/globals/video_loader.dart';
import 'package:seizhtv/views/landing_page/children/movie_children/classified_movie_data.dart';
import 'package:z_m3u_handler/extension.dart';
import 'package:z_m3u_handler/z_m3u_handler.dart';

class MoviePage extends StatefulWidget {
  const MoviePage({super.key});

  @override
  State<MoviePage> createState() => _MoviePageState();
}

class _MoviePageState extends State<MoviePage>
    with ColorPalette, UIAdditional, VideoLoader {
  late final ScrollController _scrollController;
  late final TextEditingController _search;
  late final List<ClassifiedData> _data;
  List<ClassifiedData>? displayData;
  initStream() {
    _vm.stream.listen((event) {
      _data = List.from(event.movies);
      _data.sort((a, b) => a.name.compareTo(b.name));
      displayData = List.from(_data);
      if (mounted) setState(() {});
    });
  }

  @override
  void initState() {
    _scrollController = ScrollController();
    _search = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initStream();
    });
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _search.dispose();
    super.dispose();
  }

  bool showSearchField = false;
  final LoadedM3uData _vm = LoadedM3uData.instance;
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: card,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: appbar(2, onSearchPressed: () {
            showSearchField = !showSearchField;
            if (mounted) setState(() {});
          }),
        ),
        body: Column(
          children: [
            AnimatedPadding(
              duration: const Duration(milliseconds: 400),
              padding:
                  EdgeInsets.symmetric(horizontal: showSearchField ? 20 : 0),
              child: AnimatedContainer(
                duration: const Duration(
                  milliseconds: 500,
                ),
                padding:
                    EdgeInsets.symmetric(horizontal: showSearchField ? 10 : 0),
                height: showSearchField ? 50 : 0,
                width: double.maxFinite,
                decoration: BoxDecoration(
                    color: highlight,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: highlight.darken().withOpacity(1),
                        offset: const Offset(2, 2),
                        blurRadius: 2,
                      )
                    ]),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      "assets/icons/search.svg",
                      height: 20,
                      width: 20,
                      color: white,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: showSearchField
                            ? TextField(
                                onChanged: (text) {
                                  if (text.isEmpty) {
                                    displayData = List.from(_data);
                                  } else {
                                    displayData = List.from(
                                      _data.where(
                                        (element) =>
                                            element.name.toLowerCase().contains(
                                                  text.toLowerCase(),
                                                ),
                                      ),
                                    );
                                  }
                                  displayData!
                                      .sort((a, b) => a.name.compareTo(b.name));
                                  if (mounted) setState(() {});
                                  // if (text.isEmpty) {
                                  //   _displyData = List.from(data);
                                  // } else {
                                  // _displyData = List.from(
                                  //   data.where(
                                  //     (element) =>
                                  //         element.title.toLowerCase().contains(
                                  //               text.toLowerCase(),
                                  //             ),
                                  //   ),
                                  // );
                                  // }
                                },
                                cursorColor: orange,
                                controller: _search,
                                decoration: const InputDecoration(
                                  hintText: "Search",
                                ),
                              )
                            : Container(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (showSearchField) ...{
              const SizedBox(
                height: 10,
              ),
            },
            Expanded(
              child: displayData == null
                  ? const SeizhTvLoader(
                      label: "Retrieving Data",
                    )
                  : displayData!.isEmpty
                      ? Center(
                          child: Text(
                            "No Result Found for `${_search.text}`",
                            style: TextStyle(
                              color: Colors.white.withOpacity(.5),
                            ),
                          ),
                        )
                      : Scrollbar(
                          controller: _scrollController,
                          child: ListView.separated(
                            controller: _scrollController,
                            itemBuilder: (_, i) {
                              final ClassifiedData data = displayData![i];
                              return ListTile(
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    PageTransition(
                                        child: ClassifiedMovieData(data: data),
                                        type: PageTransitionType.leftToRight),
                                  );
                                },
                                trailing: const Icon(Icons.chevron_right),
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 15),
                                subtitle: Text(
                                    "${data.data.classify().length} Entries"),
                                leading: SvgPicture.asset(
                                  "assets/icons/logo-ico.svg",
                                  width: 50,
                                  color: orange,
                                  fit: BoxFit.contain,
                                ),
                                title: Hero(
                                  tag: data.name.toUpperCase(),
                                  child: Material(
                                    color: Colors.transparent,
                                    elevation: 0,
                                    child: Text(data.name),
                                  ),
                                ),
                              );
                            },
                            separatorBuilder: (_, i) => Divider(
                              color: Colors.white.withOpacity(.3),
                            ),
                            itemCount: displayData!.length,
                          ),
                        ),
            ),
          ],
        ),
        // body: StreamBuilder<CategorizedM3UData>(
        //   stream: _vm.stream,
        //   builder: (_, snapshot) {
        //     if (snapshot.hasError || !snapshot.hasData) {
        //       if (snapshot.hasError) {
        //         return Container();
        //       }
        // return const SeizhTvLoader(
        //   label: "Retrieving Data",
        // );
        //     }
        //     final List<ClassifiedData> displayData = snapshot.data!.movies;
        //     displayData.sort((a, b) => a.name.compareTo(b.name));
        //     if (displayData.isEmpty) {
        //       return Center(
        //         child: Text(
        //           "No Live M3U Found!",
        //           style: TextStyle(
        //             color: Colors.white.withOpacity(.5),
        //           ),
        //         ),
        //       );
        //     }
        // return Scrollbar(
        //   controller: _scrollController,
        //   child: ListView.separated(
        //     controller: _scrollController,
        //     itemBuilder: (_, i) {
        //       final ClassifiedData data = displayData[i];
        //       return ListTile(
        //         onTap: () async {
        //           await Navigator.push(
        //             context,
        //             PageTransition(
        //                 child: ClassifiedMovieData(data: data),
        //                 type: PageTransitionType.leftToRight),
        //           );
        //         },
        //         trailing: const Icon(Icons.chevron_right),
        //         contentPadding: const EdgeInsets.symmetric(horizontal: 15),
        //         subtitle: Text("${data.data.classify().length} Entries"),
        //         leading: SvgPicture.asset(
        //           "assets/icons/logo-ico.svg",
        //           width: 50,
        //           color: orange,
        //           fit: BoxFit.contain,
        //         ),
        //         title: Hero(
        //           tag: data.name.toUpperCase(),
        //           child: Material(
        //             color: Colors.transparent,
        //             elevation: 0,
        //             child: Text(data.name),
        //           ),
        //         ),
        //       );
        //     },
        //     separatorBuilder: (_, i) => Divider(
        //       color: Colors.white.withOpacity(.3),
        //     ),
        //     itemCount: displayData.length,
        //   ),
        // );
        //   },
        // ),
      ),
    );
  }
}
