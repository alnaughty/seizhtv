import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:seizhtv/extensions/state.dart';
import 'package:seizhtv/globals/palette.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with ColorPalette {
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
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18)),
                  color: highlight,
                  child: Container(
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.all(18),
                    height: 170,
                    width: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Opacity(
                          opacity: 0.2,
                          child: Text(
                            "Last update : 1 day ago",
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                                child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    liveContainer(
                                        height: 40, width: 60, fontSize: 24),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    const Text(
                                      "Tv",
                                      style: TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.w600),
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
                                    const Text("600+ Channels")
                                  ],
                                )
                              ],
                            )),
                            Expanded(
                                child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
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
                              color: ColorPalette().orange,
                              total: "600")),
                      SizedBox(
                        width: space,
                      ),
                      Expanded(
                          child: smallCardHome(
                              color: Colors.purple,
                              imagePath: "assets/images/Groupframe.png",
                              title: "Series",
                              total: "600")),
                    ],
                  ),
                ),
                SizedBox(
                  height: space,
                ),
                Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18)),
                    color: highlight,
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      height: 65,
                      width: double.infinity,
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
                    )),
                SizedBox(
                  height: space,
                ),
                Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18)),
                    color: highlight,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      height: 65,
                      width: double.infinity,
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
                              liveContainer(
                                  fontSize: 15, height: 30, width: 50),
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
                    )),
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
                        child: Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18)),
                            color: highlight,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              height: 65,
                              width: double.infinity,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                        color: ColorPalette().cardButton,
                                        borderRadius:
                                            BorderRadius.circular(12)),
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
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600),
                                  )
                                ],
                              ),
                            )),
                      ),
                      SizedBox(
                        width: space,
                      ),
                      Expanded(
                        child: Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18)),
                            color: highlight,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              height: 65,
                              width: double.infinity,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                        color: ColorPalette().cardButton,
                                        borderRadius:
                                            BorderRadius.circular(12)),
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
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600),
                                  )
                                ],
                              ),
                            )),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
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

Widget smallCardHome(
        {required String imagePath,
        required String title,
        required String total,
        required Color color}) =>
    Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        color: ColorPalette().highlight,
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
                            "$total+ Channels",
                            style: const TextStyle(fontSize: 10),
                          )
                        ],
                      )
                    ],
                  ))
            ],
          ),
        ));
