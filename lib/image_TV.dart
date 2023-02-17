import 'package:flutter/material.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter_tv/play_State.dart';
import 'package:flutter_tv/config.dart';
import 'package:flutter_tv/payload.dart';

const images = <String>[
  'images/bg0.jpeg',
  'images/bg1.jpeg',
  'images/bg2.jpeg',
  'images/bg0.jpeg',
  'images/bg1.jpeg',
  'images/bg2.jpeg',
];

class ImageTV extends StatefulWidget {
  const ImageTV({Key? key}) : super(key: key);

  @override
  State<ImageTV> createState() => _ImageTVState();
}

class _ImageTVState extends PlayState<ImageTV> {
  late SwiperController swiperController;
  bool autoplay = true;

  @override
  void initState() {
    swiperController = SwiperController();
    super.initState();
  }

  @override
  Future initServer() async {
    await super.initServer();
    server.stream.listen((event) {
      print(event);

      try {
        Payload payload = Payload.fromJson(event);
        clientPort = payload.port;
        if (payload.port != server.port) {


          if (payload.type == PlayType.image.index) {
            PlayModel data = payload.data!;

            setState(() {
              ImageCMD cmd = ImageCMD.cmd(data.name ?? 0);

              switch(cmd) {

                case ImageCMD.next:
                  swiperController.next();
                  break;
                case ImageCMD.previous:
                  swiperController.previous();
                  break;
                case ImageCMD.play:
                  swiperController.startAutoplay();
                  break;
                case ImageCMD.stop:
                  swiperController.stopAutoplay();
                  break;
                case ImageCMD.number:
                  swiperController.stopAutoplay();
                  swiperController.move(data.index);
                  break;
                case ImageCMD.unknown:
                  // TODO: Handle this case.
                  break;
              }

            });
          }
        } else {
          print(payload.data);
        }
      } catch (e) {
        print("出错： $e");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Swiper(
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
      ),
    );
  }
}
