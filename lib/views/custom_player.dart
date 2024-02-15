// ignore_for_file: must_be_immutable, use_build_context_synchronously, deprecated_member_use, avoid_print

import 'dart:io';
import 'dart:ui';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_to_airplay/flutter_to_airplay.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:seizhtv/extensions/color.dart';
import 'package:seizhtv/globals/loader.dart';
import 'package:seizhtv/globals/palette.dart';
import 'package:video_player/video_player.dart';

import 'cast.dart';

class CustomPlayer extends StatefulWidget {
  CustomPlayer({
    super.key,
    required this.link,
    required this.id,
    required this.name,
    required this.image,
    this.isLive = false,
    required this.popOnError
  });
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
  late VideoPlayerController _videoController;
  late ChewieController _chewieController;
  

  Widget? _chewieWidget;
  init() async {
    print("URL : ${widget.link}");
    print("URL : ${widget.link.substring(6).replaceAll("http", "https")}");
    print("URL : ${widget.link.replaceAll("http", "https")}");

    try {
      unableToPlay = false;
      _chewieWidget = null;
      _videoController =   VideoPlayerController.network( 
        // widget.link
        // "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4"
      Platform.isAndroid ?  widget.link : widget.link.replaceAll("http", "https"),
      );

      await _videoController.initialize().whenComplete(() {
        print("VIDEO LINK: ${Platform.isAndroid ?  widget.link : widget.link.replaceAll("http", "https")}");
        print("DURATION ${_videoController.value.duration}");
        
        _chewieController = ChewieController(
          videoPlayerController: _videoController,
          autoPlay: true,
          looping: true,
          fullScreenByDefault: true,
          isLive: widget.isLive,
          autoInitialize: true,
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
                Navigator.of(context).pop();
                SystemChrome.setPreferredOrientations([
                  DeviceOrientation.portraitUp,
                ]);
              },
              iconData: Icons.cancel_presentation_rounded,
              title: "Close",
            ),
          ],
          materialProgressColors: ChewieProgressColors(
            bufferedColor: orange.darken(),
            playedColor: orange,
          ),
        );
        _chewieController.addListener(() {
          print("FULL SCREEN: ${_chewieController.isFullScreen}");
          print("ASPECT RATIO: ${_videoController.value.aspectRatio}");
          if (_chewieController.isFullScreen) {
            print('full screen enabled');
            SystemChrome.setPreferredOrientations([
              DeviceOrientation.landscapeRight,
              DeviceOrientation.landscapeLeft
            ]);
          } else {
            print('fullscreen disabled');
            SystemChrome.setPreferredOrientations([
              DeviceOrientation.portraitUp,
            ]);
          }
        });
        _chewieWidget = Chewie(
          controller: _chewieController,
        );
      });

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
    }
    _chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    try {
      return
       _chewieWidget != null
          ? Stack(
              children: [
                Container(
                  color: card,
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: _videoController.value.aspectRatio,
                      child: _chewieWidget,
                    ),
                  ),
                ),
                Positioned(
                    top: 10,
                    left: 10,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: const SizedBox(
                        height: 50,
                        width: 30,
                        child: Icon(Icons.cancel_presentation_rounded),
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
                    width: double.infinity,
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
              : Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: const SizedBox(
                      height: 160,
                      width: double.infinity,
                      child: Center(
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
                      ),
                    ),
                  ),
                );
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
