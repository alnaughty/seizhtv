import 'package:flutter/material.dart';

import '../../../../globals/palette.dart';

class ParentalControlPage extends StatefulWidget {
  const ParentalControlPage({super.key});

  @override
  State<ParentalControlPage> createState() => _ParentalControlPageState();
}

class _ParentalControlPageState extends State<ParentalControlPage>
    with ColorPalette {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: black,
      appBar: AppBar(
        backgroundColor: card,
        elevation: 0,
        title: const Text("Parental Control"),
        centerTitle: false,
      ),
      body: Column(
        children: [],
      ),
    );
  }
}
