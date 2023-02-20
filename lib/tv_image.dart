import 'package:flutter/material.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter_tv/config.dart';
import 'package:flutter_tv/payload.dart';
import 'package:flutter_tv/server_base_mixin.dart';

class TVImage extends StatefulWidget {
  const TVImage({Key? key}) : super(key: key);

  @override
  State<TVImage> createState() => _TVImageState();
}

class _TVImageState extends  State<TVImage> with ServerBaseMixin{
  late SwiperController swiperController;
  bool autoplay = true;

  @override
  void initState() {
    swiperController = SwiperController();
    super.initState();

    initServer();
  }

    initServer() async {
    await setupServer();

    server.stream.listen((event) {
      print(event);

      try {
        Payload payload = Payload.fromJson(event);
        clientPort = payload.port;
        if (payload.port != server.port) {


          if (payload.type == PlayType.image.index) {
            PlayModel data = payload.data!;

            setState(() async{
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
                  await swiperController.move(0);
                  swiperController.stopAutoplay();

                  break;
                case ImageCMD.number:
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


const images = <String>[
  'images/bg0.jpeg',
  'images/bg1.jpeg',
  'images/bg2.jpeg',
  'images/bg0.jpeg',
  'images/bg1.jpeg',
  'images/bg2.jpeg',
];