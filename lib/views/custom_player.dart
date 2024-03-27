// ignore_for_file: must_be_immutable, use_build_context_synchronously, deprecated_member_use, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:seizhtv/globals/message.dart';
import 'package:seizhtv/globals/palette.dart';

class CustomPlayer extends StatefulWidget {
  CustomPlayer(
      {super.key,
      required this.link,
      required this.id,
      required this.name,
      required this.image,
      this.isLive = false,
      required this.popOnError});
  String? id;
  bool popOnError;
  final String link;
  final String image;
  final String name;
  final bool isLive;
  @override
  State<CustomPlayer> createState() => _CustomPlayerState();
}

class _CustomPlayerState extends State<CustomPlayer> with ColorPalette {
  late VlcPlayerController _videoPlayerController;

  Future<void> initializePlayer() async {}

  @override
  void initState() {
    super.initState();

    _videoPlayerController = VlcPlayerController.network(
      widget.link,
    );
  }

  // @override
  // void dispose() async {
  //   super.dispose();
  //   await _videoPlayerController.stopRendererScanning();
  // }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: VlcPlayerWithControls(
        controller: _videoPlayerController,
        showControls: true,
      ),
    );
  }
}
