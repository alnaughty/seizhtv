// ignore_for_file: deprecated_member_use, unnecessary_string_interpolations

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:seizhtv/extensions/color.dart';
import 'package:seizhtv/globals/palette.dart';
import 'package:seizhtv/models/option.dart';
import 'package:shimmer/shimmer.dart';

class UIAdditional {
  Widget button({
    required String title,
    required String assetPath,
    required Function() onPressed,
    required Color color,
  }) =>
      Card(
        color: color,
        child: MaterialButton(
          height: 60,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          onPressed: onPressed,
          child: Center(
            child: Row(
              children: [
                SvgPicture.asset(
                  assetPath,
                  height: 20,
                  width: 20,
                  color: ColorPalette().white,
                ),
                const SizedBox(
                  width: 14,
                ),
                Text(
                  title,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      );

  Widget filterChip({
    required List<String> chipsLabel,
    required Function(int index, String? name) onPressed,
    int? si,
    required Widget filterButton,
    required bool selected,
  }) =>
      SizedBox(
        height: 50,
        width: double.infinity,
        child: ListView(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          children: [
            ChoiceChip(
              padding: const EdgeInsets.all(0),
              showCheckmark: false,
              label: filterButton,
              selected: selected,
              selectedColor: ColorPalette().topColor,
              disabledColor: ColorPalette().highlight,
            ),
            const SizedBox(width: 10),
            ListView.separated(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return GestureDetector(
                    onTap: () {
                      onPressed(index, chipsLabel[index]);
                    },
                    child: ChoiceChip(
                      showCheckmark: false,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      label: SizedBox(
                        height: 45,
                        child: Center(
                          child: Text(
                            chipsLabel[index],
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      selected: si == null ? false : index == si - 1,
                      selectedColor: ColorPalette().topColor,
                      disabledColor: ColorPalette().highlight,
                    ));
              },
              itemCount: chipsLabel.length,
              separatorBuilder: (BuildContext context, int index) {
                return const SizedBox(width: 10);
              },
            )
          ],
        ),
      );

  Widget button2(
          {required Function()? onPressed,
          required String assetPath,
          required String title,
          required Color foregroundColor}) =>
      MaterialButton(
        onPressed: onPressed,
        color: ColorPalette().card,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              SvgPicture.asset(
                assetPath,
                height: 20,
                width: 20,
                color: Colors.white,
              ),
              const SizedBox(
                width: 14,
              ),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      );

  Widget shimmerLoading(
    Color base,
    double height, {
    double width = double.maxFinite,
  }) =>
      Center(
        child: Shimmer.fromColors(
          enabled: true,
          baseColor: base,
          highlightColor: base.lighten(),
          child: Container(
            width: width,
            height: height,
            color: base.withOpacity(.5),
          ),
        ),
      );

  Widget button3(
      {required String title,
      required String icon,
      required Function() onpress}) {
    return Column(
      children: [
        IconButton(
          onPressed: () {
            onpress();
          },
          icon: SvgPicture.asset(
            icon,
            height: 30,
            color: ColorPalette().white,
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
          ),
        )
      ],
    );
  }

  Widget options({required List<Option> childrenData}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...childrenData.map(
            (e) => ListTile(
              onTap: e.onPressed,
              leading: SvgPicture.asset(
                e.icon,
                color: ColorPalette().white,
                width: 20,
                height: 20,
              ),
              title: Text(e.title),
              textColor: Colors.white,
              trailing: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 15,
              ),
            ),
            // (e) => MaterialButton(
            //   onPressed: e.onPressed,
            //   padding: const EdgeInsets.symmetric(vertical: 10),
            //   child: Center(
            //     child: Row(
            //       mainAxisAlignment: MainAxisAlignment.start,
            //       children: [
            // SvgPicture.asset(
            //   e.icon,
            //   color: ColorPalette().white,
            //   width: 25,
            //   height: 25,
            // ),
            //         const SizedBox(width: 15),
            //         Expanded(
            //           child: Text(
            //             e.title,
            //             style: const TextStyle(
            //               fontSize: 16,
            //               fontWeight: FontWeight.w500,
            //             ),
            //           ),
            //         ),
            // const Icon(
            //   Icons.arrow_forward_ios_rounded,
            //   size: 15,
            // )
            //       ],
            //     ),
            //   ),
            // ),
          )
        ],
      ),
    );
  }

  loader() {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            "assets/images/update.gif",
            fit: BoxFit.fitWidth,
            height: 95,
            width: double.maxFinite,
            alignment: AlignmentDirectional.centerEnd,
            isAntiAlias: true,
          ),
          Text(
            "Updating_please_wait".tr(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
