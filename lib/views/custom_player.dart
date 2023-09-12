// ignore_for_file: must_be_immutable, use_build_context_synchronously, deprecated_member_use, avoid_print

import 'dart:ui';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:seizhtv/extensions/color.dart';
import 'package:seizhtv/globals/loader.dart';
import 'package:seizhtv/globals/palette.dart';
import 'package:video_player/video_player.dart';

import 'cast.dart';

class CustomPlayer extends StatefulWidget {
  CustomPlayer({
    Key? key,
    required this.link,
    required this.id,
    required this.name,
    required this.image,
    this.isLive = false,
    required this.popOnError,
  }) : super(key: key);
  String? id;
  bool popOnError;
  final String link;
  final String image;
  final String name;
  // final String path;
  final bool isLive;
  @override
  State<CustomPlayer> createState() => _CustomPlayerState();
}

class _CustomPlayerState extends State<CustomPlayer> with ColorPalette {
  late VideoPlayerController _videoController;
  late ChewieController _chewieController;

  Widget? _chewieWidget;
  init() async {
    print("URL : ${widget.link}");
    print("URL : ${widget.link.substring(6).replaceAll("http", "https")}");
    try {
      unableToPlay = false;
      _chewieWidget = null;
      _videoController = VideoPlayerController.network(
        widget.link,
      );

      await _videoController.initialize().whenComplete(() {
        print("VIDEO LINK: ${widget.link}");
        print("DURATION ${_videoController.value.duration}");
        _chewieController = ChewieController(
            videoPlayerController: _videoController,
            autoPlay: true,
            looping: true,
            fullScreenByDefault: true,
            // videoPlayerController: _videoController,
            // autoPlay: true,
            // looping: false,
            isLive: widget.isLive,
            // allowPlaybackSpeedChanging: true,
            // allowedScreenSleep: false,
            // showOptions: true,
            additionalOptions: (_) => [
                  OptionItem(
                    onTap: () async {
                      showModalBottomSheet(
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        context: context,
                        builder: (_) => BackdropFilter(
                          filter: ImageFilter.blur(
                            sigmaX: 0,
                            sigmaY: 0,
                          ),
                          child: const CastPage(),
                        ),
                      );
                    },
                    iconData: Icons.cast,
                    title: "Cast",
                  ),
                  OptionItem(
                    onTap: () async {
                      SystemChrome.setPreferredOrientations([
                        DeviceOrientation.portraitUp,
                      ]);
                      Navigator.of(context).pop(null);
                      await Future.delayed(const Duration(milliseconds: 200));
                      Navigator.of(context).pop(null);
                    },
                    iconData: Icons.cancel_presentation_rounded,
                    title: "Close",
                  ),
                ],
            // customControls: GestureDetector(
            //   onTap: () {
            //     print("CLOSE PLAYER");
            //     Navigator.of(context).pop(null);
            //   },
            //   child: const SizedBox(
            //     height: 50,
            //     width: 50,
            //     child: Icon(Icons.exit_to_app_rounded),
            //   ),
            // ),
            materialProgressColors: ChewieProgressColors(
              bufferedColor: orange.darken(),
              playedColor: orange,
            ),
            // cupertinoProgressColors: ChewieProgressColors(
            //   bufferedColor: orange.darken(),
            //   playedColor: orange,
            // ),
            deviceOrientationsAfterFullScreen: [
              DeviceOrientation.portraitUp,
            ],
            deviceOrientationsOnEnterFullScreen: [
              DeviceOrientation.landscapeLeft,
            ]);
        _chewieWidget = Chewie(
          controller: _chewieController,
        );
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
        ]);
        if (mounted) setState(() {});
      });
      // _videoController.

      if (mounted) setState(() {});
    } catch (e, s) {
      Fluttertoast.showToast(msg: "No video to stream");
      print("NO VIDEO ON STREAM : $e");
      print("STACK : $s");
      print("VIDEO NOT AVAILABLE : ${widget.link}");
      if (widget.popOnError) {
        // SystemChrome.setPreferredOrientations([
        //   DeviceOrientation.portraitUp,
        // ]);
        Navigator.of(context).pop();
      } else {
        setState(() {
          _chewieWidget = null;
          unableToPlay = true;
        });
      }
      return;
    }
  }

  bool unableToPlay = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await init();
    });

    super.initState();
  }

  @override
  void dispose() {
    _videoController.dispose();
    if (_chewieWidget != null) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
      _chewieController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    try {
      return LayoutBuilder(builder: (context, c) {
        final double w = c.maxWidth;
        return _chewieWidget != null
            ? Stack(
                children: [
                  Container(
                    width: w,
                    height: c.maxHeight,
                    color: Colors.black,
                    child: AspectRatio(
                      aspectRatio: _videoController.value.aspectRatio,
                      child: _chewieWidget,
                    ),
                  ),
                  Positioned(
                      top: 20,
                      left: 10,
                      child: GestureDetector(
                        onTap: () {
                          // SystemChrome.setPreferredOrientations([
                          //   DeviceOrientation.portraitUp,
                          // ]);
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          // color: Colors.green,
                          height: 50,
                          width: 30,
                          child: const Icon(Icons.cancel_presentation_rounded),
                        ),
                      ))
                ],
              )
            : unableToPlay
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      color: Colors.grey.shade900,
                      height: 160,
                      width: w,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () async {
                              await init();
                            },
                            padding: const EdgeInsets.all(0),
                            icon: const Icon(
                              Icons.refresh,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                          const Text(
                            "Refresh",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      height: 160,
                      width: w,
                      child: const Center(
                        child: SeizhTvLoader(
                          hasBackgroundColor: false,
                          label: Text(
                            "Verifying Network",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        // child: LoadingAnimationWidget.halfTriangleDot(
                        //   color: Colors.white,
                        //   size: 50,
                        // ),
                      ),
                    ),
                  );
      });
    } catch (e) {
      return Center(
        child: Text(
          "ERROR : $e",
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      );
    }
  }
}
