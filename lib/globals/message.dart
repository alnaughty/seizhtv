// ignore_for_file: must_be_immutable, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:seizhtv/globals/controls_overlay.dart'; // For `SystemChrome`

typedef OnStopRecordingCallback = void Function(String);

class VlcPlayerWithControls extends StatefulWidget {
  final VlcPlayerController controller;
  bool showControls;
  final OnStopRecordingCallback? onStopRecording;

  VlcPlayerWithControls({
    required this.controller,
    required this.showControls,
    this.onStopRecording,
    super.key,
  });

  @override
  VlcPlayerWithControlsState createState() => VlcPlayerWithControlsState();
}

class VlcPlayerWithControlsState extends State<VlcPlayerWithControls> {
  DateTime lastRecordingShowTime = DateTime.now();
  List<double> playbackSpeeds = [0.5, 1.0, 2.0];
  final double initSnapshotBottomPosition = 10;
  static const _recordingPositionOffset = 10.0;
  final double initSnapshotRightPosition = 10;
  static const _positionedBottomSpace = 7.0;
  static const _positionedRightSpace = 3.0;
  late VlcPlayerController _controller;
  static const _overlayWidth = 100.0;
  static const _aspectRatio = 16 / 9;
  double recordingTextOpacity = 0;
  static const _elevation = 4.0;
  OverlayEntry? _overlayEntry;
  int numberOfAudioTracks = 0;
  bool validPosition = false;
  int playbackSpeedIndex = 1;
  bool isRecording = false;
  int numberOfCaptions = 0;
  double sliderValue = 0.0;
  double volumeValue = 50;
  String position = '';
  String duration = '';

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    _controller.addListener(listener);
  }

  void listener() {
    if (!mounted) return;

    if (_controller.value.isInitialized) {
      final oPosition = _controller.value.position;
      final oDuration = _controller.value.duration;
      if (oDuration.inHours == 0) {
        final strPosition = oPosition.toString().split('.').first;
        final strDuration = oDuration.toString().split('.').first;
        setState(() {
          position =
              "${strPosition.split(':')[1]}:${strPosition.split(':')[2]}";
          duration =
              "${strDuration.split(':')[1]}:${strDuration.split(':')[2]}";
        });
      } else {
        setState(() {
          position = oPosition.toString().split('.').first;
          duration = oDuration.toString().split('.').first;
        });
      }
      setState(() {
        validPosition = oDuration.compareTo(oPosition) >= 0;
        sliderValue = validPosition ? oPosition.inSeconds.toDouble() : 0;
      });
      setState(() {
        numberOfCaptions = _controller.value.spuTracksCount;
        numberOfAudioTracks = _controller.value.audioTracksCount;
      });
      // update recording blink widget
      if (_controller.value.isRecording && _controller.value.isPlaying) {
        if (DateTime.now().difference(lastRecordingShowTime).inSeconds >= 1) {
          setState(() {
            lastRecordingShowTime = DateTime.now();
            recordingTextOpacity = 1 - recordingTextOpacity;
          });
        }
      } else {
        setState(() => recordingTextOpacity = 0);
      }
      // check for change in recording state
      if (isRecording != _controller.value.isRecording) {
        setState(() => isRecording = _controller.value.isRecording);
        if (!isRecording) {
          widget.onStopRecording?.call(_controller.value.recordPath);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return OrientationBuilder(
      builder: (context, orientation) {
        return Container(
          width: size.width,
          height: size.height,
          color: Colors.black,
          child: Stack(
            children: [
              Stack(
                alignment: Alignment.bottomCenter,
                children: <Widget>[
                  Center(
                    child: VlcPlayer(
                      controller: _controller,
                      aspectRatio: _aspectRatio,
                      placeholder:
                          const Center(child: CircularProgressIndicator()),
                    ),
                  ),
                  Positioned(
                    top: _recordingPositionOffset,
                    left: _recordingPositionOffset,
                    child: AnimatedOpacity(
                      opacity: recordingTextOpacity,
                      duration: const Duration(seconds: 1),
                      child: const Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Icon(Icons.circle, color: Colors.red),
                          SizedBox(width: 5),
                          Text(
                            'REC',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ControlsOverlay(controller: _controller),
                ],
              ),
              Positioned(
                top: orientation == Orientation.landscape ? 0 : 0,
                left: 0,
                child: SizedBox(
                  height: 50,
                  width: size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          if (orientation == Orientation.landscape) {
                            SystemChrome.setPreferredOrientations(
                                [DeviceOrientation.portraitUp]);
                          }
                          setState(() {
                            widget.showControls = false;
                          });
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(
                          width: orientation == Orientation.landscape
                              ? size.width * .77
                              : size.width * .6),
                      Stack(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.timer),
                            color: Colors.white,
                            onPressed: _cyclePlaybackSpeed,
                          ),
                          Positioned(
                            bottom: _positionedBottomSpace,
                            right: _positionedRightSpace,
                            child: IgnorePointer(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(1),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 1,
                                  horizontal: 2,
                                ),
                                child: Text(
                                  '${playbackSpeeds.elementAt(playbackSpeedIndex)}x',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.cast),
                        color: Colors.white,
                        onPressed: _getRendererDevices,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                left: 0,
                child: SizedBox(
                  height: 50,
                  width: size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        color: Colors.white,
                        icon: _controller.value.isPlaying
                            ? const Icon(Icons.pause_circle_outline)
                            : const Icon(Icons.play_circle_outline),
                        onPressed: _togglePlaying,
                      ),
                      Row(
                        children: [
                          Text(
                            position,
                            style: const TextStyle(color: Colors.white),
                          ),
                          SizedBox(
                            width: orientation == Orientation.landscape
                                ? size.width * .7
                                : size.width * .45,
                            child: Slider(
                              activeColor: Colors.redAccent,
                              inactiveColor: Colors.white70,
                              value: sliderValue,
                              max: !validPosition
                                  ? 1.0
                                  : _controller.value.duration.inSeconds
                                      .toDouble(),
                              onChanged: validPosition
                                  ? _onSliderPositionChanged
                                  : null,
                            ),
                          ),
                          Text(
                            duration,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: orientation == Orientation.landscape
                            ? const Icon(Icons.fullscreen_exit)
                            : const Icon(Icons.fullscreen),
                        color: Colors.white,
                        onPressed: () {
                          print("DEVICE ORIENTATION $orientation");
                          if (orientation == Orientation.landscape) {
                            SystemChrome.setPreferredOrientations(
                                [DeviceOrientation.portraitUp]);
                            setState(() {
                              widget.showControls = true;
                            });
                          } else {
                            SystemChrome.setPreferredOrientations(
                                [DeviceOrientation.landscapeLeft]);
                            SystemChrome.setEnabledSystemUIMode(
                                SystemUiMode.immersiveSticky);
                            setState(() {
                              widget.showControls = false;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.removeListener(listener);
    super.dispose();
  }

  Future<void> _cyclePlaybackSpeed() async {
    playbackSpeedIndex++;
    if (playbackSpeedIndex >= playbackSpeeds.length) {
      playbackSpeedIndex = 0;
    }

    return _controller
        .setPlaybackSpeed(playbackSpeeds.elementAt(playbackSpeedIndex));
  }

  void _setSoundVolume(double value) {
    setState(() {
      volumeValue = value;
    });
    _controller.setVolume(volumeValue.toInt());
  }

  Future<void> _togglePlaying() async {
    _controller.value.isPlaying
        ? await _controller.pause()
        : await _controller.play();
  }

  Future<void> _toggleRecording() async {
    if (!_controller.value.isRecording) {
      final saveDirectory = await getTemporaryDirectory();
      await _controller.startRecording(saveDirectory.path);
    } else {
      await _controller.stopRecording();
    }
  }

  void _onSliderPositionChanged(double progress) {
    setState(() {
      sliderValue = progress.floor().toDouble();
    });
    //convert to Milliseconds since VLC requires MS to set time
    _controller.setTime(sliderValue.toInt() * Duration.millisecondsPerSecond);
  }

  Future<void> _getSubtitleTracks() async {
    if (!_controller.value.isPlaying) return;

    final subtitleTracks = await _controller.getSpuTracks();
    //
    if (subtitleTracks.isNotEmpty) {
      if (!mounted) return;
      final selectedSubId = await showDialog<int>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Sélectionnez le sous-titre'),
            content: SizedBox(
              width: double.maxFinite,
              height: 250,
              child: ListView.builder(
                itemCount: subtitleTracks.keys.length + 1,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      index < subtitleTracks.keys.length
                          ? subtitleTracks.values.elementAt(index)
                          : 'Désactiver',
                    ),
                    onTap: () {
                      Navigator.pop(
                        context,
                        index < subtitleTracks.keys.length
                            ? subtitleTracks.keys.elementAt(index)
                            : -1,
                      );
                    },
                  );
                },
              ),
            ),
          );
        },
      );

      if (selectedSubId != null) {
        await _controller.setSpuTrack(selectedSubId);
      }
    }
  }

  Future<void> _getAudioTracks() async {
    if (!_controller.value.isPlaying) return;

    final audioTracks = await _controller.getAudioTracks();
    //
    if (audioTracks.isNotEmpty) {
      if (!mounted) return;
      final selectedAudioTrackId = await showDialog<int>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Sélectionnez Audio'),
            content: SizedBox(
              width: double.maxFinite,
              height: 250,
              child: ListView.builder(
                itemCount: audioTracks.keys.length + 1,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      index < audioTracks.keys.length
                          ? audioTracks.values.elementAt(index)
                          : 'Désactiver',
                    ),
                    onTap: () {
                      Navigator.pop(
                        context,
                        index < audioTracks.keys.length
                            ? audioTracks.keys.elementAt(index)
                            : -1,
                      );
                    },
                  );
                },
              ),
            ),
          );
        },
      );

      if (selectedAudioTrackId != null) {
        await _controller.setAudioTrack(selectedAudioTrackId);
      }
    }
  }

  Future<void> _getRendererDevices() async {
    final castDevices = await _controller.getRendererDevices();
    //
    if (castDevices.isNotEmpty) {
      if (!mounted) return;
      final selectedCastDeviceName = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Périphériques d'affichage"),
            content: SizedBox(
              width: double.maxFinite,
              height: 250,
              child: ListView.builder(
                itemCount: castDevices.keys.length + 1,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      index < castDevices.keys.length
                          ? castDevices.values.elementAt(index)
                          : 'Déconnecter',
                    ),
                    onTap: () {
                      Navigator.pop(
                        context,
                        index < castDevices.keys.length
                            ? castDevices.keys.elementAt(index)
                            : null,
                      );
                    },
                  );
                },
              ),
            ),
          );
        },
      );

      if (selectedCastDeviceName != null) {
        await _controller.castToRenderer(selectedCastDeviceName);
      }
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Aucun périphérique d'affichage trouvé!")),
      );
    }
  }

  Future<void> _createCameraImage() async {
    final snapshot = await _controller.takeSnapshot();

    _overlayEntry?.remove();
    _overlayEntry = _createSnapshotThumbnail(snapshot);

    if (!mounted) return;

    // ignore: avoid-non-null-assertion
    Overlay.of(context).insert(_overlayEntry!);
  }

  OverlayEntry _createSnapshotThumbnail(Uint8List snapshot) {
    double right = initSnapshotRightPosition;
    double bottom = initSnapshotBottomPosition;

    return OverlayEntry(
      builder: (context) => Positioned(
        right: right,
        bottom: bottom,
        width: _overlayWidth,
        child: Material(
          elevation: _elevation,
          child: GestureDetector(
            onTap: () async {
              _overlayEntry?.remove();
              _overlayEntry = null;
              await showDialog<void>(
                context: context,
                builder: (ctx) {
                  return AlertDialog(
                    contentPadding: EdgeInsets.zero,
                    content: Image.memory(snapshot),
                  );
                },
              );
            },
            onVerticalDragUpdate: (dragUpdateDetails) {
              bottom -= dragUpdateDetails.delta.dy;
              _overlayEntry?.markNeedsBuild();
            },
            onHorizontalDragUpdate: (dragUpdateDetails) {
              right -= dragUpdateDetails.delta.dx;
              _overlayEntry?.markNeedsBuild();
            },
            onHorizontalDragEnd: (dragEndDetails) {
              if ((initSnapshotRightPosition - right).abs() >= _overlayWidth) {
                _overlayEntry?.remove();
                _overlayEntry = null;
              } else {
                right = initSnapshotRightPosition;
                _overlayEntry?.markNeedsBuild();
              }
            },
            onVerticalDragEnd: (dragEndDetails) {
              if ((initSnapshotBottomPosition - bottom).abs() >=
                  _overlayWidth) {
                _overlayEntry?.remove();
                _overlayEntry = null;
              } else {
                bottom = initSnapshotBottomPosition;
                _overlayEntry?.markNeedsBuild();
              }
            },
            child: Image.memory(snapshot),
          ),
        ),
      ),
    );
  }
}
