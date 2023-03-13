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
  Widget button2(
          {required Function()? onPressed,
          required String assetPath,
          required String title,
          required Color foregroundColor}) =>
      MaterialButton(
        onPressed: onPressed,
        height: 50,
        color: Colors.white,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                assetPath,
                height: 20,
                width: 20,
                color: foregroundColor,
              ),
              const SizedBox(
                width: 14,
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  color: foregroundColor,
                ),
              ),
            ],
          ),
        ),
      );
  Widget filterChip(List<String> labels) => SizedBox(
        height: 66,
        child: Row(
          children: [
            Expanded(
              flex: 6,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) => Chip(
                    backgroundColor: ColorPalette().highlight,
                    padding: const EdgeInsets.all(10),
                    label: Text(labels[index])),
                itemCount: labels.length,
                separatorBuilder: (BuildContext context, int index) {
                  return const SizedBox(
                    width: 10,
                  );
                },
              ),
            ),
            Expanded(child: SvgPicture.asset("assets/icons/vector.svg")),
          ],
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
  Widget options({required List<Option> childrenData}) {
    return Expanded(
        child: Padding(
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
    ));
  }
}
