import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tv/tv_image.dart';
import 'package:flutter_tv/tv_video.dart';
import 'package:flutter_tv/video_view.dart';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';

import 'package:video_player_win/video_player_win_plugin.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ///强制竖屏
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);

  /// Android状态栏透明
  if (!kIsWeb && Platform.isAndroid) {
    SystemUiOverlayStyle systemUiOverlayStyle =
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }
  if (!kIsWeb && Platform.isWindows) WindowsVideoPlayer.registerWith();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TV',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            MaterialButton(onPressed: () {
              Navigator.of(context)
                  .push(CupertinoPageRoute(builder: (BuildContext context) {
                return const TVImage();
              }));
            },
            child: Text('打开图片显示',
              style: Theme.of(context).textTheme.headline4,),),



//'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4'
            MaterialButton(onPressed: () {
              Navigator.of(context)
                  .push(CupertinoPageRoute(builder: (BuildContext context) {
                return  const TVVideo('http://vfx.mtime.cn/Video/2019/02/04/mp4/190204084208765161.mp4');
              }));
            },
              child: Text('打开视频播放WIN',
                style: Theme.of(context).textTheme.headline4,),),

          ],
        ),
      ),
    );
  }
}
