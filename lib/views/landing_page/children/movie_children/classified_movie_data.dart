import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:seizhtv/extensions/color.dart';
import 'package:seizhtv/globals/data.dart';
import 'package:seizhtv/globals/network_image_viewer.dart';
import 'package:seizhtv/globals/palette.dart';
import 'package:seizhtv/globals/video_loader.dart';
import 'package:seizhtv/views/landing_page/children/movie_children/movie_details.dart';
import 'package:z_m3u_handler/extension.dart';
import 'package:z_m3u_handler/z_m3u_handler.dart';

class ClassifiedMovieData extends StatefulWidget {
  const ClassifiedMovieData({
    super.key,
    required this.data,
  });
  final ClassifiedData data;
  @override
  State<ClassifiedMovieData> createState() => _ClassifiedMovieDataState();
}

class _ClassifiedMovieDataState extends State<ClassifiedMovieData>
    with ColorPalette, VideoLoader {
  late final List<ClassifiedData> _data = widget.data.data.classify().toList()
    ..sort((a, b) => a.name.compareTo(b.name));
  late List<ClassifiedData> _displayData = List.from(_data);
  late final ScrollController _scrollController;
  late final TextEditingController _search;
  @override
  void initState() {
    _search = TextEditingController();
    _scrollController = ScrollController();
    // TODO: implement initState
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
          // actions: [
          //   IconButton(
          //     onPressed: () {},
          //     icon: Icon(Icons.search),
          //   ),
          // ],
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Hero(
                      tag: widget.data.name.toUpperCase(),
                      child: Material(
                        color: Colors.transparent,
                        elevation: 0,
                        child: Text(
                          widget.data.name.toUpperCase(),
                          maxLines: 1,
                          style: TextStyle(
                            color: white,
                            fontSize: 15,
                            height: 1,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      "${_data.length} Entries",
                      style: TextStyle(
                        color: white.withOpacity(.5),
                        fontSize: 11,
                        height: 1,
                        fontWeight: FontWeight.w300,
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
        body: Column(
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
                            _displayData = List.from(_data);
                          } else {
                            _displayData = List.from(
                              _data.where(
                                (element) =>
                                    element.name.toLowerCase().contains(
                                          text.toLowerCase(),
                                        ),
                              ),
                            );
                          }
                          _displayData.sort((a, b) => a.name.compareTo(b.name));
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
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: _displayData.isEmpty
                  ? Center(
                      child: Text("NO RESULT FOUND FOR ${_search.text}"),
                    )
                  : Scrollbar(
                      controller: _scrollController,
                      child: GridView.count(
                        controller: _scrollController,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        crossAxisCount: 3,
                        childAspectRatio: .6,
                        children: List.generate(_displayData.length, (index) {
                          final ClassifiedData _entry = _displayData[index];
                          return LayoutBuilder(builder: (context, c) {
                            final double w = c.maxWidth;
                            final double h = c.maxHeight;
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: Tooltip(
                                message: _entry.name,
                                child: GestureDetector(
                                  onTap: () async {
                                    await showModalBottomSheet(
                                        context: context,
                                        isDismissible: true,
                                        backgroundColor: Colors.transparent,
                                        constraints: const BoxConstraints(
                                          maxHeight: 230,
                                        ),
                                        builder: (_) {
                                          return MovieDetails(
                                            data: _entry,
                                            onLoadVideo:
                                                (M3uEntry entry) async {
                                              Navigator.of(context).pop(null);
                                              entry.addToHistory(refId!);
                                              await loadVideo(context, entry);
                                            },
                                          );
                                        });
                                  },
                                  child: NetworkImageViewer(
                                    url: _entry.data[0].attributes['tvg-logo'],
                                    width: w,
                                    height: h,
                                    fit: BoxFit.cover,
                                    color: highlight,
                                  ),
                                ),
                              ),
                            );
                          });
                        }),
                      ),
                    ),
            )
          ],
        ),
      ),
    );
  }
}
