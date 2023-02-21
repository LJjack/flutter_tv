import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_tv/capacity_indicators.dart';
import 'package:video_player/video_player.dart';

class VideoView extends StatefulWidget {
  final String fileUrl;

  final ValueChanged<double>? onChanged;
  final ValueChanged<VideoPlayerController>? onController;

  const VideoView(
    this.fileUrl, {
    Key? key,
        this.onChanged,
        this.onController,
  }) : super(key: key);

  @override
  State<VideoView> createState() => _VideoViewState();
}

class _VideoViewState extends State<VideoView> {
  late VideoPlayerController? controller;

  @override
  void initState() {
    if (widget.fileUrl.startsWith("http://") ||
        widget.fileUrl.startsWith("https://")) {
      controller = VideoPlayerController.network(widget.fileUrl);
    } else if (widget.fileUrl.startsWith('assets/')) {
      controller = VideoPlayerController.asset(widget.fileUrl);
    } else {
      controller = VideoPlayerController.file(File(widget.fileUrl));
    }
    controller?.setLooping(true);

    controller?.initialize().then((value) {
      controller?.play();
      mySetState(() {});
    });

    widget.onController != null?(controller) : null;

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
          Center(
            child: GestureDetector(
              child: controller!.value.isPlaying
                  ? null
                  : const Icon(Icons.play_arrow, color: Colors.white70, size: 100),
              onTap: () {
                if (controller!.value.isPlaying) {
                  controller?.pause();
                } else {
                  controller?.play();
                }
                setState(() {});
              },
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: CapacityIndicator(controller: controller!, onChanged: widget.onChanged,),
          ),
        ],
      );
    }
  }
}
