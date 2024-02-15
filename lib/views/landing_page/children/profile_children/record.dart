import 'package:flutter/material.dart';

import '../../../../globals/palette.dart';

class RecordPage extends StatefulWidget {
  const RecordPage({super.key});

  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> with ColorPalette {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: black,
      appBar: AppBar(
        backgroundColor: card,
        elevation: 0,
        title: const Text("Record"),
        centerTitle: false,
      ),
      body: Column(
        children: [],
      ),
    );
  }
}
