import 'package:chewie/chewie.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:video_player/video_player.dart';

class VideoViewMacOS extends StatefulWidget {
  final String url;

  const VideoViewMacOS(this.url,{
    Key? key,
  }) : super(key: key);

  @override
  State<VideoViewMacOS> createState() => _VideoViewMacOSState();
}

class _VideoViewMacOSState extends State<VideoViewMacOS> {
  late VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _wasError = false;

  @override
  void initState() {
    initAsync();
    super.initState();
  }

  initAsync() async {
    try {
      _videoPlayerController = VideoPlayerController.asset(widget.url);
      await _videoPlayerController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: false,
        looping: false,
      );
      setState(() {});
    } catch (e) {
      setState(() {
        _wasError = true;
      });
      if (kDebugMode) {
        print("There was an issue loading the video player.");
        print(e);
      }
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: 400,
      ),
      child: _loadingOrPlayer(),
    );
  }

  _loadingOrPlayer() {
    if (_chewieController == null || _wasError) {
      return _loading();
    }

    return _player();
  }

  _player() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Chewie(
          controller: _chewieController!,
        ),
      ),
    );
  }

  _loading() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SpinKitCircle(
          color: Theme.of(context).highlightColor,
        ),
        SizedBox(height: 8),
      ],
    );
  }
}
