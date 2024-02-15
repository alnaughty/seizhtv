// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class Videoplayer extends StatefulWidget {
  const Videoplayer({
    Key? key,
    required this.url,
  }) : super(key: key);
  final String url;

  @override
  State<Videoplayer> createState() => _VideoplayerState();
}

class _VideoplayerState extends State<Videoplayer> {
  late YoutubePlayerController _controller;
  bool _isPlayerReady = false;
  late PlayerState _playerState;

  @override
  void initState() {
    _controller = YoutubePlayerController(
      initialVideoId: widget.url,
      flags: const YoutubePlayerFlags(
        mute: false,
        autoPlay: false,
        disableDragSeek: true,
        loop: false,
        isLive: false,
        forceHD: false,
        enableCaption: true,
        showLiveFullscreenButton: false,
      ),
    )..addListener(_videoPlayerListner);
    super.initState();
  }

  void _videoPlayerListner() {
    if (_isPlayerReady) {
      setState(() {
        _playerState = _controller.value.playerState;
      });
    }
  }

  @override
  void deactivate() {
    _controller.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayer(
      controller: _controller,
      showVideoProgressIndicator: true,
      progressIndicatorColor: Colors.blueAccent,
      topActions: <Widget>[
        Expanded(
          child: Text(
            _controller.metadata.title,
            style: const TextStyle(
              color: Colors.white,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
      bottomActions: [
        CurrentPosition(),
        ProgressBar(isExpanded: true),
        // FullScreenButton(),
      ],
      onReady: () {
        _isPlayerReady = true;
      },
      onEnded: (data) {},
    );
  }
}
