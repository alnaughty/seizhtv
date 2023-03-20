import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:page_transition/page_transition.dart';
import 'package:seizhtv/data_containers/loaded_m3u_data.dart';
import 'package:seizhtv/extensions/color.dart';
import 'package:seizhtv/extensions/state.dart';
import 'package:seizhtv/globals/data_cacher.dart';
import 'package:seizhtv/globals/palette.dart';
import 'package:seizhtv/globals/ui_additional.dart';
import 'package:seizhtv/views/landing_page/source_management.dart';
import 'package:z_m3u_handler/extension.dart';
import 'package:z_m3u_handler/z_m3u_handler.dart';
import 'package:timeago/timeago.dart' as timeago;

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.onPagePressed});
  final ValueChanged<int> onPagePressed;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with ColorPalette, UIAdditional {
  final LoadedM3uData _vm = LoadedM3uData.instance;
  final DataCacher _cacher = DataCacher.instance;
  late final String? savedUrl = _cacher.savedUrl;
  final double space = 8;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: card,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: appbar(0),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                StreamBuilder<CategorizedM3UData>(
                  stream: _vm.stream,
                  builder: (_, snapshot) {
                    if (!snapshot.hasData || snapshot.hasError) {
                      return Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: shimmerLoading(
                              highlight,
                              170,
                              width: double.maxFinite,
                            ),
                          ),
                          SizedBox(
                            height: space,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 15,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(18),
                                    child: shimmerLoading(
                                      highlight,
                                      150,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: space + 15,
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 15,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(18),
                                    child: shimmerLoading(
                                      highlight,
                                      150,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    }
                    final CategorizedM3UData _data = snapshot.data!;
                    return Column(
                      children: [
                        Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18)),
                          color: highlight,
                          child: MaterialButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18)),
                            onPressed: () {
                              widget.onPagePressed(1);
                            },
                            padding: EdgeInsets.zero,
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20)),
                              padding: const EdgeInsets.all(18),
                              height: 170,
                              width: double.infinity,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Opacity(
                                    opacity: 0.2,
                                    child: Text(
                                      "Last update : ${timeago.format(_cacher.date!)}",
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Expanded(
                                          child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Row(
                                            children: [
                                              liveContainer(
                                                height: 40,
                                                width: 60,
                                                fontSize: 24,
                                              ),
                                              const SizedBox(
                                                width: 8,
                                              ),
                                              const Text(
                                                "Tv",
                                                style: TextStyle(
                                                    fontSize: 32,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.circle,
                                                color: ColorPalette().red,
                                                size: 10,
                                              ),
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                "${_data.live.expand((element) => element.data).length} Channels",
                                              ),
                                            ],
                                          )
                                        ],
                                      )),
                                      Expanded(
                                          child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Image.asset(
                                            "assets/images/tv.png",
                                            scale: 3,
                                            fit: BoxFit.fitWidth,
                                          ),
                                        ],
                                      ))
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: space,
                        ),
                        SizedBox(
                          height: 144,
                          width: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: smallCardHome(
                                  imagePath: "assets/images/Grouppopcorn.png",
                                  title: "Movies",
                                  index: 2,
                                  color: ColorPalette().orange,
                                  total:
                                      "${_data.movies.expand((element) => element.data.classify()).length}",
                                ),
                              ),
                              SizedBox(
                                width: space,
                              ),
                              Expanded(
                                child: smallCardHome(
                                  index: 3,
                                  color: Colors.purple,
                                  imagePath: "assets/images/Groupframe.png",
                                  title: "Series",
                                  total:
                                      "${_data.series.expand((element) => element.data.classify()).length}",
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(
                  height: space,
                ),
                MaterialButton(
                  onPressed: null,
                  color: highlight,
                  disabledColor: highlight.darken(),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18)),
                  height: 65,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            color: ColorPalette().cardButton,
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.all(8),
                        child: SvgPicture.asset(
                          "assets/icons/Widget_add.svg",
                          color: ColorPalette().white,
                        ),
                      ),
                      const Text(
                        "Multi-Screen",
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: space,
                ),
                MaterialButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      PageTransition(
                          child: const SourceManagementPage(
                            fromInit: false,
                          ),
                          type: PageTransitionType.leftToRight),
                    );
                  },
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18)),
                  color: highlight,
                  height: 65,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            color: ColorPalette().cardButton,
                            borderRadius: BorderRadius.circular(12)),
                        height: 50,
                        width: 50,
                        padding: const EdgeInsets.all(8),
                        child: SvgPicture.asset(
                          "assets/icons/epg.svg",
                          color: ColorPalette().white,
                        ),
                      ),
                      Row(
                        children: [
                          liveContainer(fontSize: 15, height: 30, width: 50),
                          const SizedBox(
                            width: 8,
                          ),
                          const Text(
                            "with EPG",
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: space,
                ),
                SizedBox(
                  height: 65,
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: MaterialButton(
                          onPressed: () async {
                            await Navigator.pushNamed(context, "/history-page");
                          },
                          color: highlight,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18)),
                          height: 65,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    color: ColorPalette().cardButton,
                                    borderRadius: BorderRadius.circular(12)),
                                height: 40,
                                width: 40,
                                padding: const EdgeInsets.all(5),
                                child: SvgPicture.asset(
                                  "assets/icons/time.svg",
                                  color: ColorPalette().white,
                                ),
                              ),
                              const Text(
                                "Catch Up",
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w600),
                              )
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: space,
                      ),
                      Expanded(
                        child: MaterialButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18)),
                          height: 65,
                          disabledColor: highlight.darken(),
                          color: highlight,
                          onPressed: null,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    color: cardButton,
                                    borderRadius: BorderRadius.circular(12)),
                                height: 40,
                                width: 40,
                                padding: const EdgeInsets.all(5),
                                child: SvgPicture.asset(
                                  "assets/icons/radio.svg",
                                  color: ColorPalette().white,
                                ),
                              ),
                              const Text(
                                "Radio",
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w600),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget smallCardHome(
          {required String imagePath,
          required String title,
          required String total,
          required int index,
          required Color color}) =>
      Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          color: ColorPalette().highlight,
          child: MaterialButton(
            onPressed: () {
              widget.onPagePressed(index);
            },
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            padding: EdgeInsets.zero,
            child: Container(
              padding: const EdgeInsets.all(15),
              height: 164,
              child: Column(
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset(
                          imagePath,
                          fit: BoxFit.fitHeight,
                        ),
                        Container(
                          height: 26,
                          width: 26,
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              color: ColorPalette().white.withOpacity(0.1),
                              shape: BoxShape.circle),
                          child: SvgPicture.asset(
                            "assets/icons/sync.svg",
                          ),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                      flex: 2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w600),
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.circle,
                                color: color,
                                size: 10,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Text(
                                "$total Channels",
                                style: const TextStyle(fontSize: 10),
                              )
                            ],
                          )
                        ],
                      ))
                ],
              ),
            ),
          ));
}

Widget liveContainer(
        {required double width,
        required double height,
        required double fontSize}) =>
    Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          gradient: ColorPalette().gradientLive),
      child: Center(
        child: Text(
          "Live",
          style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600),
        ),
      ),
    );
