import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class Videoplayer extends StatefulWidget {
  const Videoplayer({
    Key? key,
    required this.url,
  }) : super(key: key);
  final String url;
  // final Function() onPressed;

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
        autoPlay: true,
        disableDragSeek: true,
        loop: false,
        isLive: false,
        // forceHideAnnotation: true,
        forceHD: false,
        enableCaption: true,
      ),
    )..addListener(_videoPlayerListner);
    super.initState();
  }

  void _videoPlayerListner() {
    if (_isPlayerReady) {
      setState(() {
        // print(_controller.value.playerState.toString());
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
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: GestureDetector(
        onTap: () {
          print("press");
        },
        child: YoutubePlayer(
          controller: _controller,
          showVideoProgressIndicator: true,
          progressIndicatorColor: Colors.blueAccent,
          topActions: <Widget>[
            SizedBox(width: 8.0),
            Text(
              _controller.metadata.title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
          bottomActions: [
            CurrentPosition(),
            ProgressBar(isExpanded: true),
            FullScreenButton(),
          ],
          onReady: () {
            _isPlayerReady = true;
          },
          onEnded: (data) {},
        ),
      ),
    );
  }
}


  // // late VideoPlayerController _controller;
  // late YoutubePlayerController _controller;

  // late PlayerState _playerState;
  // late YoutubeMetaData _videoMetaData;
  // double _volume = 100;
  // bool _muted = false;
  // bool _isPlayerReady = true;

  // @override
  // void initState() {
  //   super.initState();
  //   // _controller = VideoPlayerController.network(widget.url)
  //   //   // 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4')
  //   //   ..initialize().then((_) {
  //   //     setState(() {});
  //   //   });

  //   _controller = YoutubePlayerController(
  //     initialVideoId: widget.url,
  //     flags: const YoutubePlayerFlags(
  //       mute: false,
  //       autoPlay: true,
  //       disableDragSeek: false,
  //       loop: false,
  //       isLive: false,
  //       forceHD: false,
  //       enableCaption: true,
  //     ),
  //   )..addListener(listener);
  //   _videoMetaData = const YoutubeMetaData();
  //   _playerState = PlayerState.unknown;
  // }

  // @override
  // void dispose() {
  //   super.dispose();
  //   _controller.dispose();
  // }

  // @override
  // void deactivate() {
  //   // Pauses video while navigating to next page.
  //   _controller.pause();
  //   super.deactivate();
  // }

  // void listener() {
  //   if (_isPlayerReady && mounted && !_controller.value.isFullScreen) {
  //     setState(() {
  //       _playerState = _controller.value.playerState;
  //       _videoMetaData = _controller.metadata;
  //     });
  //   }
  // }

  // @override
  // Widget build(BuildContext context) {
  //   return
  //       // YoutubePlayerBuilder(
  //       //     player: YoutubePlayer(
  //       //       controller: _controller,
  //       //       showVideoProgressIndicator: true,
  //       //       progressIndicatorColor: Colors.blueAccent,
  //       //       onReady: () {
  //       //         _isPlayerReady = true;
  //       //         // _controller.addListener(listener);
  //       //       },
  //       //       topActions: <Widget>[
  //       //         const SizedBox(width: 8.0),
  //       //         Expanded(
  //       //           child: Text(
  //       //             _controller.metadata.title,
  //       //             style: const TextStyle(
  //       //               color: Colors.white,
  //       //               fontSize: 18.0,
  //       //             ),
  //       //             overflow: TextOverflow.ellipsis,
  //       //             maxLines: 1,
  //       //           ),
  //       //         ),
  //       //         IconButton(
  //       //           icon: const Icon(
  //       //             Icons.settings,
  //       //             color: Colors.white,
  //       //             size: 25.0,
  //       //           ),
  //       //           onPressed: () {
  //       //             print('Settings Tapped!');
  //       //           },
  //       //         ),
  //       //       ],
  //       //       // onEnded: (data) {
  //       //       //   _controller
  //       //       //       .load(_ids[(_ids.indexOf(data.videoId) + 1) % _ids.length]);
  //       //       //   _showSnackBar('Next Video Started!');
  //       //       // },
  //       //     ),
  //       //     builder: (context, player) => Container(
  //       //           color: Colors.red,
  //       //         ));
  //       GestureDetector(
  //           onTap: () {
  //             print('press');
  //             // widget.onPressed;
  //           },
  //           child: Center(
  //             child: AspectRatio(
  //               aspectRatio: 16 / 9,
  //               child: _controller != null
  //                   ? YoutubePlayer(controller: _controller)
  //                   : Center(child: CircularProgressIndicator()),
  //             ),
  //           ));
  //   //  YoutubePlayer(
  //   //   controller: _controller,
  //   //   showVideoProgressIndicator: true,
  //   //   progressIndicatorColor: Colors.blueAccent,
  //   //   onReady: () {
  //   //     _controller.addListener(listener);
  //   //   },
  //   // ),
  //   // _controller.value.isInitialized
  //   //     ? AspectRatio(
  //   //         aspectRatio: _controller.value.aspectRatio,
  //   //         child: VideoPlayer(_controller),
  //   //       )
  //   //     : Container(),
  //   //   ),
  //   // );
  // }
// }
