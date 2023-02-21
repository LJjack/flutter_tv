import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tv/config.dart';
import 'package:flutter_tv/payload.dart';
import 'package:flutter_tv/video_view.dart';
import 'package:video_player/video_player.dart';

import '../client_server_sockets/client_server_sockets.dart';
import '../widgets/dropdown_button.dart';

class PadClientPage extends StatefulWidget {
  const PadClientPage({super.key});

  @override
  State<PadClientPage> createState() => _PadClientPageState();
}

class _PadClientPageState extends State<PadClientPage> {
  late Client client;
  bool opening = false;
  double sliderValue = 0.0;
  int selectedIndex = 0;

  bool autoplay = true;
  bool showImage = true;

  late SwiperController swiperController;
  late VideoPlayerController? videoController;
  String videoUrl =
      "http://vfx.mtime.cn/Video/2019/02/04/mp4/190204084208765161.mp4";

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
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
            child: topView(),
          ),
          Expanded(
              child: Container(
            color: Colors.blueGrey,
            child: Row(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Visibility(visible: showImage, child: centerImageView()),
                      Visibility(visible: !showImage, child: centerVideoView()),
                    ],
                  ),
                ),
                SizedBox(
                  width: 140,
                  child: MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    child: rightView(),
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
    return Row(
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
              onChanged: (value) async {
                if (value == DropdownCMD.auto) {
                  swiperController.startAutoplay();
                  final model = PlayModel(name: ImageCMD.play.value);
                  toServerSend(model: model, type: PlayType.image.value);
                } else if (value == DropdownCMD.hand) {
                  await swiperController.move(0);
                  swiperController.stopAutoplay();

                  final model = PlayModel(name: ImageCMD.stop.value);
                  toServerSend(model: model, type: PlayType.image.value);
                }
              },
            ))
      ],
    );
  }

  Widget rightView() {
    return ListView(
      children: [
        for (int index = 0; index < images.length; index++)
          InkWell(
            onTap: () {
              if (!showImage) {
                setState(() {
                  showImage = true;
                });
              }

              swiperController.move(index);
            },
            child: Image.asset(
              images[index],
              fit: BoxFit.fill,
            ),
          ),
        for (int index = 0; index < videos.length; index++)
          InkWell(
            onTap: () {
              if (showImage) {
                setState(() {
                  showImage = false;
                });
              }
            },
            child: Image.asset(
              videos[index],
              fit: BoxFit.fill,
            ),
          ),
      ],
    );
  }

  Widget centerImageView() {
    return Swiper(
      itemBuilder: (context, index) {
        final image = images[index];

        return Image.asset(
          image,
          fit: BoxFit.fill,
        );
      },
      autoplay: autoplay,
      itemCount: images.length,
      controller: swiperController,
      onIndexChanged: (v) {
        final model = PlayModel(name: ImageCMD.number.value, index: v);
        toServerSend(model: model, type: PlayType.image.value);
      },
    );
  }

  Widget centerVideoView() {
    return VideoView(videoUrl,onChanged: (vv) {
      print("=----==vv=---===  $vv");
      Payload payload = Payload(
          port: client.port,
          message: "pad发送消息",
          type: PlayType.video.index,
          data: PlayModel(name: VideoCMD.slider.value, progress: vv));

      client.send(payload.toJson());
    },onPlay: (flag) {
      print("=----==flag=---===  $flag");
      Payload payload = Payload(
          port: client.port,
          message: "pad发送消息",
          type: PlayType.video.index,
          data: PlayModel(name: flag?VideoCMD.play.value:VideoCMD.pause.value));

      client.send(payload.toJson());
    },);
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

}

const images = <String>[
  'images/bg0.jpeg',
  'images/bg1.jpeg',
  'images/bg2.jpeg',
  'images/bg0.jpeg',
  'images/bg1.jpeg',
  'images/bg2.jpeg',
];

const videos = <String>[
  'images/1.png',
  'images/2.png',
  'images/3.png',
];
