import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:seizhtv/data_containers/loaded_m3u_data.dart';
import 'package:seizhtv/extensions/state.dart';
import 'package:seizhtv/globals/component.dart';
import 'package:seizhtv/globals/loader.dart';
import 'package:seizhtv/globals/network_image_viewer.dart';
import 'package:seizhtv/globals/palette.dart';
import 'package:seizhtv/globals/ui_additional.dart';
import 'package:z_m3u_handler/extension.dart';
import 'package:z_m3u_handler/z_m3u_handler.dart';

class LivePage extends StatefulWidget {
  const LivePage({super.key});

  @override
  State<LivePage> createState() => _LivePageState();
}

class _LivePageState extends State<LivePage> with ColorPalette, UIAdditional {
  final LoadedM3uData _vm = LoadedM3uData.instance;

  late final ScrollController _scrollController;
  @override
  void initState() {
    _scrollController = ScrollController();
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    return Scaffold(
      backgroundColor: card,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: appbar(1),
      ),
      body: StreamBuilder<CategorizedM3UData>(
          stream: _vm.stream,
          builder: (context, snapshot) {
            if (snapshot.hasError || !snapshot.hasData) {
              if (snapshot.hasError) {
                return Container();
              }
              return const SeizhTvLoader(
                label: "Retrieving Data",
              );
            }
            // final List<M3uEntry> _entries = ;
            if (snapshot.data!.live.isEmpty) {
              return Center(
                child: Text(
                  "No Live M3U Found!",
                  style: TextStyle(
                    color: Colors.white.withOpacity(.5),
                  ),
                ),
              );
            }
            final List<ClassifiedData> _cat = snapshot.data!.live.classify();
            // final Map<String, List<M3uEntry>> _cat =
            //     snapshot.data!.live.categorize(needle: "title-clean");
            return Scrollbar(
              controller: _scrollController,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    SliverAppBar(
                      elevation: 0,
                      floating: true,
                      pinned: false,
                      centerTitle: false,
                      backgroundColor: card,
                      flexibleSpace: FlexibleSpaceBar(
                        background: filterChip([
                          "All",
                          "Favourites",
                          "Channels History",
                          "France FHD | UHD",
                          "France FHD HEVC"
                        ]),
                      ),
                    ),
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
                          final ClassifiedData _dat = _cat[index];
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: GestureDetector(
                              onTap: () async {
                                print(_dat);
                                if (_dat.data.length > 1) {
                                  ///show page
                                } else {
                                  await loadVideo(context, _dat.data[0]);
                                }
                                // await loadVideo(context, _entries[index]);
                              },
                              child: Column(
                                children: [
                                  Expanded(
                                    child: LayoutBuilder(
                                      builder: (_, c) {
                                        final double w = c.maxWidth;
                                        final double h = c.maxHeight;
                                        return NetworkImageViewer(
                                          url: _dat
                                              .data[0].attributes['tvg-logo']!,
                                          height: h,
                                          width: w,
                                          color: card,
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
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      width: double.infinity,
                                      height: 45,
                                      child: Align(
                                        alignment:
                                            AlignmentDirectional.centerStart,
                                        child: Text(
                                          _dat.name.isEmpty
                                              ? "Unnamed"
                                              : _dat.name,
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
                        childCount: _cat.length,
                      ),
                    )
                  ],
                ),
              ),
            );
          }),
    );
  }
}
