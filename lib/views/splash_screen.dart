import 'package:flutter/material.dart';
import 'package:seizhtv/globals/data.dart';
import 'package:seizhtv/globals/data_cacher.dart';
import 'package:seizhtv/globals/logo.dart';
import 'package:seizhtv/globals/palette.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final DataCacher _cacher = DataCacher.instance;
  Future<void> check() async {
    refId = _cacher.refId;
    await Future.delayed(const Duration(milliseconds: 1500));
    if (refId == null) {
      // ignore: use_build_context_synchronously
      await Navigator.pushReplacementNamed(context, "/auth");
    } else {
      // ignore: use_build_context_synchronously
      await Navigator.pushReplacementNamed(context, "/landing-page");
    }
    return;
  }

  @override
  void initState() {
    // TODO: implement initState
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await check();
    });
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: ColorPalette().gradient),
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.1,
            ),
            const Expanded(
              child: LogoSVG(),
            ),
            Expanded(
              flex: 2,
              child: Center(
                child: Image.asset(
                  "assets/images/transsplash.gif",
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
