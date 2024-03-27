import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:seizhtv/data_containers/loaded_m3u_data.dart';
import 'package:seizhtv/extensions/color.dart';
import 'package:seizhtv/globals/data.dart';
import 'package:seizhtv/globals/loader.dart';
import 'package:seizhtv/globals/network_image_viewer.dart';
import 'package:seizhtv/globals/palette.dart';
import 'package:seizhtv/globals/ui_additional.dart';
import 'package:seizhtv/globals/video_loader.dart';
import 'package:seizhtv/views/landing_page/children/live_children/live_details.dart';
import 'package:z_m3u_handler/z_m3u_handler.dart';

class SearchLive extends StatefulWidget {
  const SearchLive({super.key});

  @override
  State<SearchLive> createState() => _SearchLiveState();
}

class _SearchLiveState extends State<SearchLive>
    with ColorPalette, VideoLoader, UIAdditional {
  final LoadedM3uData _vm = LoadedM3uData.instance;
  late final ScrollController _scrollController;
  late final TextEditingController _search;
  List<M3uEntry>? allData;
  List<M3uEntry>? _displayData;
  initPlatform() {
    _vm.stream.listen((event) {
      allData = List.from(event.live);
      _displayData = List.from(event.live);
      _displayData!.sort((a, b) => a.title.compareTo(b.title));
      if (mounted) setState(() {});
      print(_displayData?.length);
    });
  }

  @override
  void initState() {
    _search = TextEditingController();
    _scrollController = ScrollController();
    // TODO: implement initState
    initPlatform();
    super.initState();
  }

  @override
  void dispose() {
    _search.dispose();
    _scrollController.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: card,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: Row(
            children: [
              SvgPicture.asset(
                "assets/images/logo-full.svg",
                height: 25,
                color: orange,
              ),
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 10,
                ),
                height: 25,
                width: 1.5,
                color: Colors.white.withOpacity(.5),
              ),
              Text(
                "Live Search".toUpperCase(),
                style: TextStyle(
                  color: white,
                  fontSize: 15,
                  height: 1,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        body: _displayData == null
            ? const Center(
                child: SeizhTvLoader(
                  hasBackgroundColor: false,
                ),
              )
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
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
                            child: TextField(
                              onChanged: (text) {
                                if (text.isEmpty) {
                                  _displayData = allData;
                                } else {
                                  _displayData = List.from(
                                    allData!.where(
                                      (element) =>
                                          element.title.toLowerCase().contains(
                                                text.toLowerCase(),
                                              ),
                                    ),
                                  );
                                  _displayData!.sort(
                                      (a, b) => a.title.compareTo(b.title));
                                }
                                if (mounted) setState(() {});
                              },
                              cursorColor: orange,
                              controller: _search,
                              decoration: const InputDecoration(
                                hintText: "Search",
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: _displayData!.isEmpty
                        ? Center(
                            child:
                                Text("No Result found for `${_search.text}`"),
                          )
                        : Scrollbar(
                            controller: _scrollController,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              child: CustomScrollView(
                                controller: _scrollController,
                                slivers: [
                                  // SliverAppBar(
                                  //   elevation: 0,
                                  //   floating: true,
                                  //   pinned: false,
                                  //   centerTitle: false,
                                  //   backgroundColor: card,
                                  //   flexibleSpace: FlexibleSpaceBar(
                                  //     background: filterChip([
                                  //       "All",
                                  //       "favorites",
                                  //       "Channels History",
                                  //       "France FHD | UHD",
                                  //       "France FHD HEVC"
                                  //     ]),
                                  //   ),
                                  // ),
                                  SliverGrid(
                                    gridDelegate:
                                        const SliverGridDelegateWithMaxCrossAxisExtent(
                                      maxCrossAxisExtent: 150.0,
                                      mainAxisSpacing: 10.0,
                                      crossAxisSpacing: 10.0,
                                      childAspectRatio: .8,
                                    ),
                                    delegate: SliverChildBuilderDelegate(
                                      (BuildContext context, int index) {
                                        final M3uEntry _dat =
                                            _displayData![index];
                                        return ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: GestureDetector(
                                            onTap: () async {
                                              // await loadVideo(context, _dat);
                                              await showModalBottomSheet(
                                                  context: context,
                                                  isDismissible: true,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  constraints:
                                                      const BoxConstraints(
                                                    maxHeight: 230,
                                                  ),
                                                  builder: (_) {
                                                    return LiveDetails(
                                                      onLoadVideo: () async {
                                                        Navigator.of(context)
                                                            .pop(null);
                                                        await loadVideo(
                                                            context, _dat);
                                                        await _dat.addToHistory(
                                                            refId!);
                                                      },
                                                      entry: _dat,
                                                    );
                                                  });
                                            },
                                            child: Column(
                                              children: [
                                                Expanded(
                                                  child: LayoutBuilder(
                                                    builder: (_, c) {
                                                      final double w =
                                                          c.maxWidth;
                                                      final double h =
                                                          c.maxHeight;
                                                      return NetworkImageViewer(
                                                        url: _dat.attributes[
                                                            'tvg-logo']!,
                                                        title: _dat.title,
                                                        height: h,
                                                        width: w,
                                                        fit: BoxFit.cover,
                                                        color: card,
                                                      );
                                                    },
                                                  ),
                                                ),
                                                Align(
                                                  alignment:
                                                      Alignment.bottomCenter,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: ColorPalette()
                                                          .highlight,
                                                      borderRadius:
                                                          const BorderRadius
                                                              .only(
                                                        bottomLeft:
                                                            Radius.circular(12),
                                                        bottomRight:
                                                            Radius.circular(12),
                                                      ),
                                                    ),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 10),
                                                    width: double.infinity,
                                                    height: 45,
                                                    child: Align(
                                                      alignment:
                                                          AlignmentDirectional
                                                              .centerStart,
                                                      child: Text(
                                                        _dat.title.isEmpty
                                                            ? "Unnamed"
                                                            : _dat.title,
                                                        maxLines: 2,
                                                        style: const TextStyle(
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
                                      childCount: _displayData!.length,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                  )
                ],
              ),
      ),
    );
  }
}
