import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:seizhtv/globals/palette.dart';

extension EXT on State {
  static ColorPalette palette = ColorPalette();
  static final TextStyle titleStyle = TextStyle(
    fontSize: 25,
    color: palette.white,
  );
  static final List<Widget> _titles = [
    SvgPicture.asset(
      "assets/images/logo-full.svg",
      height: 25,
      color: palette.orange,
    ),
    Text(
      "Live TV",
      style: titleStyle,
    ),
    Text(
      "Movies",
      style: titleStyle,
    ),
    Text(
      "Series",
      style: titleStyle,
    ),
    Text(
      "Favorites",
      style: titleStyle,
    ),
  ];
  Widget defaultTitle(int index) {
    final DateTime now = DateTime.now();
    return Row(
      children: [
        _titles[index],
        Container(
          margin: const EdgeInsets.symmetric(
            horizontal: 10,
          ),
          height: 25,
          width: 1.5,
          color: palette.white.withOpacity(.5),
        ),
        SizedBox(
          height: 25,
          width: 70,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                DateFormat("hh:mm a").format(now),
                style: TextStyle(
                  color: palette.white,
                  fontSize: 12,
                  height: 1,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                DateFormat("MMM. dd yyyy").format(now),
                style: TextStyle(
                  color: palette.white,
                  fontSize: 10,
                  height: 1,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget appbar(int index, {bool showLeading = false, Widget? title}) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: palette.white,
      automaticallyImplyLeading: showLeading,
      actions: [
        IconButton(
          onPressed: () {},
          icon: SvgPicture.asset(
            "assets/icons/search.svg",
            height: 25,
            width: 25,
            color: palette.white,
          ),
        ),
        Center(
          child: ClipRRect(
            child: Container(
              width: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: palette.white,
              ),
              child: MaterialButton(
                height: 40,
                onPressed: () {
                  Navigator.pushNamed(context, "/profile-page"
                      // MaterialPageRoute(
                      //   builder: (context) => const ProfilePage(),
                      // ),
                      );
                },
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: Icon(
            CupertinoIcons.ellipsis_vertical,
            color: palette.white,
          ),
        ),
      ],
      title: title ?? defaultTitle(index),
    );
  }

  Widget appbar1() {
    final DateTime now = DateTime.now();
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: palette.white,
      actions: [
        IconButton(
          onPressed: () {},
          icon: SvgPicture.asset(
            "assets/icons/search.svg",
            height: 25,
            width: 25,
            color: palette.white,
          ),
        ),
        Center(
          child: ClipRRect(
            child: Container(
              width: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: palette.white,
              ),
              child: MaterialButton(
                height: 40,
                onPressed: () {
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (context) => const ProfilePage()));
                },
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: Icon(
            CupertinoIcons.ellipsis_vertical,
            color: palette.white,
          ),
        ),
      ],
    );
  }
}
