// ignore_for_file: must_be_immutable

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:seizhtv/globals/loader.dart';
import 'package:seizhtv/globals/palette.dart';
import 'package:video_player/video_player.dart';

class CustomPlayer extends StatefulWidget {
  CustomPlayer({
    Key? key,
    required this.link,
    required this.id,
    required this.name,
    required this.image,
    required this.popOnError,
  }) : super(key: key);
  String? id;
  bool popOnError;
  final String link;
  final String image;
  final String name;
  // final String path;
  @override
  State<CustomPlayer> createState() => _CustomPlayerState();
}

class _CustomPlayerState extends State<CustomPlayer> with ColorPalette {
  late final VideoPlayerController _videoController;
  late final ChewieController _chewieController;

  Widget? _chewieWidget;
  init() async {
    print("URL : ${widget.link.substring(6).replaceAll("http", "https")}");
    try {
      unableToPlay = false;
      _chewieWidget = null;
      _videoController = VideoPlayerController.network(
        widget.link,
      );

      await _videoController.initialize().whenComplete(() {
        print("DURATION ${_videoController.value.duration}");
        _chewieController = ChewieController(
          videoPlayerController: _videoController,
          autoPlay: true,
          looping: false,
          showControls: true,
          // isLive: true,
          allowFullScreen: true,
          // allowMuting: true,
          allowPlaybackSpeedChanging: true,
          allowedScreenSleep: false,
          showOptions: true,
          deviceOrientationsAfterFullScreen: [
            DeviceOrientation.portraitUp,
          ],
        );
        _chewieWidget = Chewie(
          controller: _chewieController,
        );
      });
      // _videoController.

      if (mounted) setState(() {});
    } catch (e, s) {
      Fluttertoast.showToast(msg: "No video to stream");
      print("NO VIDEO ON STREAM : $e");
      print("STACK : $s");
      print("VIDEO NOT AVAILABLE : ${widget.link}");
      if (widget.popOnError) {
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
    // TODO: implement initState

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await init();
    });

    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    if (_chewieWidget != null) {
      _videoController.dispose();
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
            ? AspectRatio(
                aspectRatio: _videoController.value.aspectRatio,
                child: _chewieWidget,
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
                          label: "Verifying Network",
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
