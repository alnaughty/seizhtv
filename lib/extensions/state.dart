// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:seizhtv/globals/data.dart';
import 'package:seizhtv/globals/palette.dart';
import '../views/landing_page/source_management.dart';

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

  Widget appbar(int index,
      {bool showLeading = false,
      Widget? title,
      Function()? onSearchPressed,
      Function()? onUpdateChannel}) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: palette.white,
      automaticallyImplyLeading: showLeading,
      actions: [
        // if (index > 0) ...{
        IconButton(
          // onPressed: () async {
          //   if (index == 1) {
          //     await Navigator.pushNamed(context, "/search-live-page");
          //   } else if (index == 2) {
          //     await Navigator.pushNamed(context, "/search-movies-page");
          //   } else {
          //     await Navigator.pushNamed(context, "/search-series-page");
          //   }
          // },
          onPressed: onSearchPressed,
          icon: SvgPicture.asset(
            "assets/icons/search.svg",
            height: 25,
            width: 25,
            color: palette.white,
          ),
        ),
        // },
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Container(
              width: 40,
              height: 40,
              color: Colors.white,
              // decoration: BoxDecoration(
              //   shape: BoxShape.circle,
              //   color: palette.white,
              //   image: DecorationImage(image: user!.photoUrl == null ? AssetImage("assetName") : )
              // ),
              child: MaterialButton(
                height: 40,
                padding: EdgeInsets.zero,
                onPressed: () {
                  Navigator.pushNamed(context, "/profile-page");
                },
                child: user?.photoUrl == null
                    ? Image.asset(
                        "assets/icons/default-picture.jpeg",
                        height: 40,
                        width: 40,
                        fit: BoxFit.cover,
                      )
                    : CachedNetworkImage(
                        imageUrl: user!.photoUrl!,
                        height: 40,
                        width: 40,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
          ),
        ),
        PopupMenuButton(
          elevation: 0,
          color: Colors.white,
          icon: Icon(
            CupertinoIcons.ellipsis_vertical,
            color: palette.white,
          ),
          onSelected: (value) {
            if (value == "Change Source") {
              Navigator.push(
                context,
                PageTransition(
                  child: const SourceManagementPage(),
                  type: PageTransitionType.leftToRight,
                ),
              );
            } else {
              onUpdateChannel;
            }
          },
          itemBuilder: (BuildContext bc) {
            return [
              PopupMenuItem(
                value: 'Change Source',
                child: Row(
                  children: [
                    SvgPicture.asset("assets/icons/change.svg"),
                    const SizedBox(width: 10),
                    const Text(
                      "Change Source",
                      style: TextStyle(color: Colors.black),
                    )
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'Update Channels',
                onTap: onUpdateChannel,
                child: Row(
                  children: [
                    SvgPicture.asset("assets/icons/update.svg"),
                    const SizedBox(width: 10),
                    const Text(
                      "Update Channels",
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
            ];
          },
        )
      ],
      title: title ?? defaultTitle(index),
    );
  }

  Widget appbar1({Function()? onUpdateChannel}) {
    final DateTime now = DateTime.now();
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: palette.white,
      actions: [
        // IconButton(
        //   onPressed: () {},
        //   icon: SvgPicture.asset(
        //     "assets/icons/search.svg",
        //     height: 25,
        //     width: 25,
        //     color: palette.white,
        //   ),
        // ),
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
                  Navigator.pushNamed(context, "/profile-page");
                },
              ),
            ),
          ),
        ),
        const SizedBox(width: 20),
        // PopupMenuButton(
        //   elevation: 0,
        //   color: Colors.white,
        //   icon: Icon(
        //     CupertinoIcons.ellipsis_vertical,
        //     color: palette.white,
        //   ),
        //   onSelected: (value) {
        //     if (value == "Change Source") {
        //       Navigator.push(
        //         context,
        //         PageTransition(
        //           child: const SourceManagementPage(),
        //           type: PageTransitionType.leftToRight,
        //         ),
        //       );
        //     } else {
        //       onUpdateChannel;
        //     }
        //   },
        //   itemBuilder: (BuildContext bc) {
        //     return [
        //       PopupMenuItem(
        //         value: 'Change Source',
        //         child: Row(
        //           children: [
        //             SvgPicture.asset(
        //               "assets/icons/change.svg",
        //             ),
        //             const SizedBox(width: 10),
        //             const Text(
        //               "Change Source",
        //               style: TextStyle(color: Colors.black),
        //             )
        //           ],
        //         ),
        //       ),
        //       PopupMenuItem(
        //         value: 'Update Channels',
        //         onTap: onUpdateChannel,
        //         child: Row(
        //           children: [
        //             SvgPicture.asset(
        //               "assets/icons/update.svg",
        //             ),
        //             const SizedBox(width: 10),
        //             const Text(
        //               "Update Channels",
        //               style: TextStyle(color: Colors.black),
        //             ),
        //           ],
        //         ),
        //       ),
        //     ];
        //   },
        // )
      ],
    );
  }
}
