import 'dart:async';

import 'package:flutter/material.dart';

import 'package:video_player/video_player.dart';

///视频和图片轮播组件
///
class VideoImageShufflingWidget extends StatefulWidget {
  const VideoImageShufflingWidget({Key? key}) : super(key: key);

  @override
  _VideoImageShufflingWidgetState createState() =>
      _VideoImageShufflingWidgetState();
}

class _VideoImageShufflingWidgetState extends State<VideoImageShufflingWidget> {
  late VideoPlayerController _controller;


  //视频或者资源，读者需要更换自己项目中的图片或者视频资源
  List<String> imageList = [
    'images/bg0.jpeg',
    'images/Butterfly-209.mp4',
    "images/bg1.jpeg",
    'images/bg2.jpeg'
  ];
  //当前展示的图片地址
  String currentUrl ='';

  ///播放视频
  void playVideo1() async {
    if (_timer != null && _timer!.isActive) {
      _timer?.cancel();
    }
    _controller = VideoPlayerController.asset(currentUrl);
    bool isFirst = false;
    _controller.initialize().then((value) {
      _controller.addListener(() async {
        Duration? res = await _controller.position;
        setState(() {
          if (res! >= _controller.value.duration) {
            if (!isFirst) {
              isFirst = true;
              currentIndex++;
              _controller.removeListener(() { });
              _controller.dispose();
              // printLogByFlag(true, 'currentIndex:${currentIndex}');
              // printLogByFlag(true, 'currentIndex % imageList.length:${currentIndex % imageList.length}');
              currentUrl = imageList[currentIndex % imageList.length];
              if (currentUrl.endsWith('.png') || currentUrl.endsWith('.jpeg')) {
                print( '这是一张图片');
                iShowImage = true;
                iShowVideo = false;
                // _pageController.jumpToPage(1);
                startTimer();
              } else {
                iShowImage = false;
                iShowVideo = true;
                playVideo1();
              }
            }
          }
        });
      });
      _controller.setLooping(false);
    });
    _controller.play();
  }

  ///启动Timer
  void startTimer() {
    //间隔五秒时间
    _timer = Timer.periodic(const Duration(milliseconds: 5000), (value) {
      print("定时器");
      currentIndex++;
      // printLogByFlag(true, 'currentIndex:${currentIndex}');
      // printLogByFlag(true, 'currentIndex % imageList.length:${currentIndex % imageList.length}');
      String _currentUrl = imageList[currentIndex % imageList.length];
      // printLogByFlag(true, 'currentUrl:$_currentUrl');
      //触发轮播切换
      if (!_currentUrl.endsWith('.png')|| currentUrl.endsWith('.jpeg')) {
        _timer!.cancel();
        // printLogByFlag(true, '这是视频资源');
        setState(()  {
          currentUrl = _currentUrl;
          iShowVideo =true;
          iShowImage = false;
          playVideo1();
          // _pageController.jumpToPage(0);
        });
      } else {
        iShowVideo =false;
        iShowImage = true;
        currentUrl = _currentUrl;
        setState(() {});
      }

    });

  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.network('');
    currentUrl = imageList[0];
    // printLogByFlag(true, 'currentUrl:${currentUrl}');
    if(currentUrl.endsWith('.png')|| currentUrl.endsWith('.jpeg')){
      // printLogByFlag(true, '这是图片资源');
      //如果是图片则启动定时器
      iShowImage = true;
      iShowVideo = false;
      startTimer();
      setState(() {
      });

    }else{
      // printLogByFlag(true, '这是视频资源');
      playVideo1();
      iShowImage = false;
      iShowVideo = true;
    }
  }

  //定时器自动轮播
  Timer? _timer;

  //当前显示的索引
  int currentIndex = 0;

//通过标记位来控制视频组件的显示或者隐藏
  bool iShowVideo = false;
//通过此标记位来控制图片组件的显示或者隐藏
  bool iShowImage= false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("视频图片轮播"),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        child: Stack(
          children: [
            //轮播图片
            Visibility(visible: iShowVideo,child:  VideoPlayer(_controller),),
            Visibility(visible: iShowImage,child:   Image.asset(currentUrl,// fit: BoxFit.fill,
            ),),
          ],
        ),
      ),
    );
  }
}

