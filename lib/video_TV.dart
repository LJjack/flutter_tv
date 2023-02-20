import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player_win/video_player_win.dart';

class VideoTV extends StatefulWidget {
  final String fileUrl;

  const VideoTV(
    this.fileUrl, {
    Key? key,
  }) : super(key: key);

  @override
  State<VideoTV> createState() => _VideoTVState();
}

class _VideoTVState extends State<VideoTV> {
  late WinVideoPlayerController? controller;

  @override
  void initState() {
    if (widget.fileUrl.startsWith("http://") ||
        widget.fileUrl.startsWith("https://")) {
      controller = WinVideoPlayerController.network( widget.fileUrl);
    } else if (widget.fileUrl.startsWith('assets/')) {
      controller = WinVideoPlayerController.asset(widget.fileUrl);
    } else {
      controller = WinVideoPlayerController.file(File(widget.fileUrl));
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WinVideoPlayer(controller!),
    );
  }
}
