import 'package:flutter/material.dart';

import '../../../../globals/palette.dart';

class GeneralSettingPage extends StatefulWidget {
  const GeneralSettingPage({super.key});

  @override
  State<GeneralSettingPage> createState() => _GeneralSettingPageState();
}

class _GeneralSettingPageState extends State<GeneralSettingPage>
    with ColorPalette {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: black,
      appBar: AppBar(
        backgroundColor: card,
        elevation: 0,
        title: const Text("General Setting"),
        centerTitle: false,
      ),
      body: Column(
        children: [],
      ),
    );
  }
}
