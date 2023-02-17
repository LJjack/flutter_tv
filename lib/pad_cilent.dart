import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tv/config.dart';
import 'package:flutter_tv/payload.dart';
import 'client_server_sockets/client_server_sockets.dart';

import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'widgets/dropdown_button.dart';

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
      title: '展厅平板',
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
  int selectedIndex = 0;

  bool autoplay = true;

  late SwiperController swiperController;

  @override
  void initState() {
    swiperController = SwiperController();
    super.initState();
    initClient();
  }

  Future initClient() async {
    client = Client();
    final connected = await client.connect("192.168.61.115", port: 8080);
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
            VideoCMD cmd = VideoCMD.cmd(payload.data?.name ?? 0);

            setState(() {
              if (cmd == VideoCMD.pause) {
                opening = false;
              } else if (cmd == VideoCMD.play) {
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
      body: Column(
        children: [
          topView(),
          Expanded(
              child: Container(
            color: Colors.blueGrey,
            child: Row(
              children: [
                Expanded(
                  child: Swiper(
                    itemBuilder: (context, index) {
                      final image = images[index];

                      return Image.asset(
                        image,
                        fit: BoxFit.fill,
                      );
                    },
                    // indicatorLayout: PageIndicatorLayout.COLOR,
                    autoplay: autoplay,
                    itemCount: images.length,
                    // pagination: const SwiperPagination(),
                    controller: swiperController,
                    onIndexChanged: (v) {
                      print("-----------------------   $v");

                      final model =
                          PlayModel(name: ImageCMD.number.value, index: v);
                      toServerSend(model: model, type: PlayType.image.value);
                    },
                  ),
                ),
                SizedBox(
                  width: 140,
                  child: MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    child: ListView(
                      children: [
                        for (int index = 0; index < images.length; index++)
                          InkWell(
                            onTap: () {
                              swiperController.move(index);
                            },
                            child: Image.asset(
                              images[index],
                              fit: BoxFit.fill,
                            ),
                          )
                      ],
                    ),
                  ),
                )
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget topView() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 80,
              child: ListView(
                scrollDirection: Axis.horizontal,
                itemExtent: 120,
                children: [
                  for (int index = 0; index < 5; index++)
                    Container(
                        decoration: BoxDecoration(
                            border: Border(
                                top: _sideColor,
                                left: _sideColor,
                                bottom: _sideColor)),
                        child: textButton(
                            text: "按钮$index",
                            selected: index == selectedIndex,
                            onTap: () {
                              if (selectedIndex == index) return;

                              setState(() {
                                selectedIndex = index;
                              });
                            })),
                  Container(
                    decoration: BoxDecoration(border: Border(left: _sideColor)),
                  )
                ],
              ),
            ),
          ),
          SizedBox(
              width: 120,
              height: 80,
              child: DropdownButton3(
                initialValue: DropdownCMD.auto,
                onChanged: (value) {
                  if (value == DropdownCMD.auto) {
                    swiperController.startAutoplay();
                    final model =
                    PlayModel(name: ImageCMD.play.value);
                    toServerSend(model: model, type: PlayType.image.value);
                  } else if (value == DropdownCMD.hand) {
                    swiperController.stopAutoplay();
                    swiperController.move(0);
                    final model =
                    PlayModel(name: ImageCMD.stop.value);
                    toServerSend(model: model, type: PlayType.image.value);
                  }
                },
              ))
        ],
      ),
    );
  }

  Widget textButton({
    required String text,
    bool selected = true,
    GestureTapCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: selected ? Colors.blue : Colors.white,
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(color: selected ? Colors.white : Colors.blue),
        ),
      ),
    );
  }

  BorderSide get _sideColor => const BorderSide(color: Colors.blue, width: 1);

  void toServerSend({int type = 1, required PlayModel model}) async {
    bool flag = client.isEmpty;
    if (flag) {
      Payload payload = Payload(
          port: client.port, message: "pad发送消息", type: type, data: model);
      client.send(payload.toJson());
    } else {
      print("没有连接服务器");
    }
  }

  Widget testView() {
    return Center(
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
                        name: opening
                            ? VideoCMD.play.value
                            : VideoCMD.pause.value));

                client.send(payload.toJson());
              },
              child: Icon(opening ? Icons.pause : Icons.play_arrow, size: 100)),
          SizedBox(
              height: 20,
              child: Slider(
                  value: sliderValue,
                  onChanged: (vv) {
                    Payload payload = Payload(
                        port: client.port,
                        message: "服务端发送消息",
                        type: PlayType.video.index,
                        data: PlayModel(
                            name: VideoCMD.slider.value, progress: vv));

                    client.send(payload.toJson());
                    setState(() {
                      sliderValue = vv;
                    });
                  },
                  divisions: 10)),
        ],
      ),
    );
  }
}

const images = <String>[
  'images/bg0.jpeg',
  'images/bg1.jpeg',
  'images/bg2.jpeg',
  'images/bg0.jpeg',
  'images/bg1.jpeg',
  'images/bg2.jpeg',
];
