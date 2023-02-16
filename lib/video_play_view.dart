import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tv/capacity_indicators.dart';
import 'package:video_player/video_player.dart';

class VideoPlayView extends StatefulWidget {
  String fileUrl = '';

  VideoPlayView(this.fileUrl, {super.key});

  @override
  State<StatefulWidget> createState() => VideoPlayViewState();
}

class VideoPlayViewState extends State<VideoPlayView> {
  VideoPlayerController? _controller;

  //获取当前视频播放的信息
  late VideoPlayerValue videoPlayerValue;

  //当前播放视频的总时长
  late Duration totalDuration;

  //当前播放视频的位置
  late Duration currentDuration;

  //当前视频是否缓存
  bool isBuffer = false;

  bool isPlay = false;

  bool isPress = false;

  late Timer? isPressTimer;

  String tDuration = "0:00:00";
  String cDuration = "0:00:00";

  late Offset startPosition; // 起始位置
  late double movePan; // 偏移量累计总和
  late double layoutWidth; // 组件宽度
  late double layoutHeight; // 组件高度
  String volumePercentage = ''; // 组件位移描述
  bool allowHorizontal = false; // 是否允许快进
  Duration position = const Duration(seconds: 0); // 当前时间

  @override
  void initState() {
    isPressTimer = Timer(const Duration(), () {});
    if (widget.fileUrl.startsWith("http://") ||
        widget.fileUrl.startsWith("https://")) {
      _controller = VideoPlayerController.network(widget.fileUrl)
        ..initialize().then((_) {
          _controller!.play();
          mySetState(() {});
        });
    } else if (widget.fileUrl.startsWith('assets/')) {
      _controller = VideoPlayerController.asset(widget.fileUrl)
        ..initialize().then((_) {
          _controller!.play();
          mySetState(() {});
        });
    } else {
      _controller = VideoPlayerController.file(File(widget.fileUrl))
        ..initialize().then((_) {
          _controller!.play();
          mySetState(() {});
        });
    }
    if (_controller != null) {
      _controller!.removeListener(() {});
      _controller!.addListener(() {
        mySetState(() {
          isPlay = _controller!.value.isPlaying;
          videoPlayerValue = _controller!.value;
          totalDuration = videoPlayerValue.duration;
          currentDuration = videoPlayerValue.position;
          tDuration = totalDuration.toString().substring(0, 7);
          cDuration = currentDuration.toString().substring(0, 7);
          isBuffer = videoPlayerValue.isBuffering;
        });
      });
    }
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
    _controller?.removeListener(() {});
    _controller?.dispose();
    if (isPressTimer != null) {
      isPressTimer?.cancel();
      isPressTimer = null;
    }

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
    if (!_controller!.value.isInitialized) {
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
                  aspectRatio: _controller!.value.aspectRatio,
                  child: VideoPlayer(_controller!))),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: CapacityIndicator(controller: _controller!),
          ),
        ],
      );
    }

  }
}
