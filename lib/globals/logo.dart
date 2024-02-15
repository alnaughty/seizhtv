// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class LogoSVG extends StatelessWidget {
  final String bottomText;
  const LogoSVG({
    Key? key,
    this.bottomText = "",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      elevation: 0,
      child: SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                "assets/images/logo.svg",
                height: 50,
                // color: ColorPalette().orange,
              ),
              if (bottomText.isNotEmpty) ...{
                const SizedBox(
                  height: 10,
                ),
                Text(
                  bottomText,
                  style: const TextStyle(fontSize: 16),
                )
              }
            ],
          ),
        ),
      ),
    );
  }
}
