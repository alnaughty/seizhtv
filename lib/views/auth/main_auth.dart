import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:seizhtv/globals/logo.dart';
import 'package:seizhtv/globals/palette.dart';
import 'package:seizhtv/globals/ui_additional.dart';

class MainAuthPage extends StatefulWidget {
  const MainAuthPage({super.key});

  @override
  State<MainAuthPage> createState() => _MainAuthPageState();
}

class _MainAuthPageState extends State<MainAuthPage>
    with UIAdditional, ColorPalette {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    return Scaffold(
      backgroundColor: Colors.grey.shade800,
      body: Container(
        decoration: BoxDecoration(
          gradient: gradient,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(
                      height: 80,
                    ),
                    const Hero(
                      tag: "auth-logo",
                      child: LogoSVG(),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    button(
                      title: "Login with provider",
                      assetPath: "assets/icons/api.svg",
                      onPressed: () async {
                        await Navigator.pushNamed(context, "/provider-login");
                      },
                      color: cardColor,
                    ),
                    button(
                      title: "Load your playlist (File/URL)",
                      assetPath: "assets/icons/folder.svg",
                      onPressed: () async {
                        await Navigator.pushNamed(context, "/load-playlist");
                      },
                      color: cardColor,
                    ),
                    button(
                      title: "Login with your mac address",
                      assetPath: "assets/icons/mac.svg",
                      onPressed: () {},
                      color: cardColor,
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 30),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          text:
                              'By using this application, you agree to the \n',
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: 'Terms & Conditions',
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  print('Terms & Conditions');
                                },
                              style: TextStyle(
                                height: 1.3,
                                color: ColorPalette().orange,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
