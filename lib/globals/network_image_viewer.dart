import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:seizhtv/extensions/color.dart';
import 'package:seizhtv/globals/palette.dart';
import 'package:seizhtv/globals/ui_additional.dart';

class NetworkImageViewer extends StatelessWidget
    with UIAdditional, ColorPalette {
  NetworkImageViewer(
      {super.key,
      required this.url,
      required this.width,
      this.fit = BoxFit.contain,
      required this.height,
      required this.color});
  final String url;
  final double height;
  final double width;
  final Color color;
  final BoxFit fit;
  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      placeholder: (_, url) => Container(
        color: color.darken(),
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              shimmerLoading(
                color,
                height,
                width: width,
              ),
              SvgPicture.asset(
                "assets/icons/logo-ico.svg",
                width: width * .7,
                color: cardColor.withOpacity(.7),
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),
      ),
      fit: fit,
      placeholderFadeInDuration: const Duration(milliseconds: 500),
      errorWidget: (_, url, error) => Container(
        color: cardColor.darken().withOpacity(.5),
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // shimmerLoading(
              //   color,
              //   height,
              //   width: width,
              // ),
              SvgPicture.asset(
                "assets/icons/logo-ico.svg",
                width: width * .7,
                color: Colors.red.withOpacity(.5),
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),
      ),
    );
    // Image.network("");
    // return Image(
    //   fit: fit,
    //   width: width,
    //   height: height,
    //   excludeFromSemantics: true,
    //   image: NetworkImage(url, scale: 1, headers: {
    //     "Access-Control-Allow-Headers": "Access-Control-Allow-Origin, Accept",
    //   }),
    //   loadingBuilder: (context, x, loadingProgress) {
    //     // if (loadingProgress == null) return child;
    //     //   return Center(
    //     //     child: CircularProgressIndicator(
    //     //       value: loadingProgress.expectedTotalBytes != null
    //     //           ? loadingProgress.cumulativeBytesLoaded /
    //     //               loadingProgress.expectedTotalBytes!
    //     //           : null,
    //     //     ),
    //     //   );
    //     return AnimatedSwitcher(
    //       duration: const Duration(milliseconds: 500),
    //       child: loadingProgress == null
    //           ? x
    //           : Center(
    //               child: Stack(
    //                 alignment: Alignment.center,
    //                 children: [
    // shimmerLoading(
    //   color,
    //   height,
    //   width: width,
    // ),
    //                   if (loadingProgress.expectedTotalBytes != null) ...{
    //                     Text(
    //                       "${((loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!) * 100).ceil()}%",
    //                     ),
    //                   },
    //                 ],
    //               ),
    //             ),
    //     );
    //   },
    //   errorBuilder: (context, x, errorProgress) => Container(
    //     color: color.darken(),
    // child: Center(
    //   child: Stack(
    //     alignment: Alignment.center,
    //     children: [
    //       shimmerLoading(
    //         color,
    //         height,
    //         width: width,
    //       ),
    //       SvgPicture.asset(
    //         "assets/icons/logo-ico.svg",
    //         width: width * .7,
    //         color: cardColor.withOpacity(.7),
    //         fit: BoxFit.contain,
    //       ),
    //     ],
    //   ),
    // ),
    //   ),
    // );
  }
}
