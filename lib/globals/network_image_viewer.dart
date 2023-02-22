import 'package:flutter/material.dart';
import 'package:seizhtv/extensions/color.dart';
import 'package:seizhtv/globals/ui_additional.dart';

class NetworkImageViewer extends StatelessWidget with UIAdditional {
  const NetworkImageViewer(
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
    // Image.network("");
    return Image(
      fit: fit,
      width: width,
      height: height,
      excludeFromSemantics: true,
      image: NetworkImage(
        url,
        scale: 1,
      ),
      loadingBuilder: (context, x, loadingProgress) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: loadingProgress == null
              ? x
              : shimmerLoading(
                  color,
                  height,
                  width: width,
                ),
        );
      },
      errorBuilder: (context, x, errorProgress) => Container(
        color: color.darken(),
        child: Center(
          // child: Text(
          //   url,
          //   style: TextStyle(fontSize: 10),
          // ),
          child: Icon(
            Icons.error,
            color: Colors.white.withOpacity(.5),
          ),
        ),
      ),
    );
  }
}
