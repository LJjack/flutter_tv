import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_tv/capacity_indicators.dart';
import 'package:video_player/video_player.dart';

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
  late VideoPlayerController? controller;

  @override
  void initState() {
    if (widget.fileUrl.startsWith("http://") ||
        widget.fileUrl.startsWith("https://")) {
      controller = VideoPlayerController.network( widget.fileUrl);
    } else if (widget.fileUrl.startsWith('assets/')) {
      controller = VideoPlayerController.asset(widget.fileUrl);
    } else {
      controller = VideoPlayerController.file(File(widget.fileUrl));
    }
    controller?.initialize().then((value) {
      controller?.play();
      mySetState(() {

      });
    });

    super.initState();
  }

  mySetState(callBack) {
    if (mounted) {
      setState(() {
        callBack();
      });
    }
  }

  @override
  void dispose() {
    controller?.removeListener(() {});
    controller?.dispose();


    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: Colors.grey,
        child: initPlayView(),
      ),
    );
  }

  Widget initPlayView() {
    if (!controller!.value.isInitialized) {
      return Stack(
        alignment: Alignment.center,
        children: [
          Container(
            color: Colors.black,
          ),
          const SizedBox(
            height: 30,
            width: 30,
            child: CircularProgressIndicator(
              backgroundColor: Colors.red,
            ),
          ),
        ],
      );
    } else {
      return Stack(
        children: [
          Container(
              color: Colors.black,
              width: MediaQuery.of(context).size.width,
              alignment: Alignment.center,
              child: AspectRatio(
                  aspectRatio: controller!.value.aspectRatio,
                  child: VideoPlayer(controller!))),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: CapacityIndicator(controller: controller!),
          ),
        ],
      );
    }

  }
}
