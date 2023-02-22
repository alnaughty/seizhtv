import 'package:flutter/material.dart';

const Color colors = Colors.black;

class SeizhTvLoader extends StatelessWidget {
  const SeizhTvLoader({
    Key? key,
    this.hasBackgroundColor = true,
    this.label,
    this.opacity = .5,
    this.labelColor = Colors.white,
    this.backgroundColor = Colors.black,
  })  : assert(opacity >= 0 && opacity <= 1, "Opacity minimum is 0 and max 1"),
        super(key: key);
  final bool hasBackgroundColor;
  final Color backgroundColor;
  final double opacity;
  final String? label;
  final Color? labelColor;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: false,
      child: Material(
        color: !hasBackgroundColor
            ? Colors.transparent
            : backgroundColor.withOpacity(opacity),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/transsplash.gif",
              height: 95,
              width: double.maxFinite,
              alignment: AlignmentDirectional.centerEnd,
              isAntiAlias: true,
              fit: BoxFit.fitWidth,
            ),
            if (label != null) ...{
              Text(
                label!,
                style: TextStyle(
                  color: labelColor,
                  fontSize: 16,
                ),
              ),
            },
          ],
        ),
      ),
    );
  }
}
