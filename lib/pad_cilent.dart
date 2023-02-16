import 'package:flutter/material.dart';
import 'package:flutter_tv/config.dart';
import 'package:flutter_tv/payload.dart';
import 'client_server_sockets/client_server_sockets.dart';

import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';

void main() {
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

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
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
  late Client client;
  bool opening = false;
  double sliderValue = 0.0;

  @override
  void initState() {
    super.initState();
    initClient();
  }


  Future initClient() async {
    client = Client();
    final connected = await client.connect("192.168.20.23", port: 8080);
    if (!connected) {
      print("initClient  出错");
      return;
    }


    client.stream.listen((event) {
      print(event);
      try {
        Payload payload = Payload.fromJson(event);
        if (payload.port == client.port) {
          if (payload.type == PlayType.video.index) {
            setState(() {
              if (payload.data?.name == kVideoNextPause) {
                opening = false;
              } else if (payload.data?.name == kVideoNextPlay) {
                opening = true;
              }
            });
          }
        }
      } catch (e) {
        print("出错： $e");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '测试平板',
              style: Theme.of(context).textTheme.headline4,
            ),
            MaterialButton(
                onPressed: () {
                  setState(() {
                    opening = !opening;
                  });
                  Payload payload = Payload(
                      port: client.port,
                      message: "服务端发送消息",
                      type: PlayType.video.index,
                      data: PlayModel(
                          name: opening ? kVideoNextPlay : kVideoNextPause));

                  client.send(payload.toJson());
                },
                child:
                    Icon(opening ? Icons.pause : Icons.play_arrow, size: 100)),
            SizedBox(
                height: 20,
                child: Slider(
                    value: sliderValue,
                    onChanged: (vv) {
                      Payload payload = Payload(
                          port: client.port,
                          message: "服务端发送消息",
                          type: PlayType.video.index,
                          data: PlayModel(name: kVideoSlider, progress: vv));

                      client.send(payload.toJson());
                      setState(() {
                        sliderValue = vv;
                      });
                    },
                    divisions: 10)),
          ],
        ),
      ),
    );
  }
}
