import 'package:video_player/video_player.dart';

import 'package:flutter/material.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter_tv/play_State.dart';
import 'package:flutter_tv/config.dart';
import 'package:flutter_tv/payload.dart';

const images = <String>[
  'images/bg0.jpeg',
  'images/bg1.jpeg',
  'images/Butterfly-209.mp4',
  'images/bg2.jpeg',
];

class ImageSwiper extends StatefulWidget {
  const ImageSwiper({Key? key}) : super(key: key);

  @override
  State<ImageSwiper> createState() => _ImageSwiperState();
}

class _ImageSwiperState extends PlayState<ImageSwiper> {
  late SwiperController swiperController;

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
            setState(() {
              if (payload.data?.name == kImageNextPage) {
                swiperController.next();
              } else if (payload.data?.name == kImagePreviousPage) {
                swiperController.previous();
              } else if (payload.data?.name == kImagePlay) {
                swiperController.startAutoplay();
              } else if (payload.data?.name == kImageStop) {
                swiperController.stopAutoplay();
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

          if (image.endsWith('.png') ||
              image.endsWith('.jpeg') ||
              image.endsWith('.jpg')) {
            return Image.asset(
              image,
              fit: BoxFit.fill,
            );
          } else if (image.endsWith('.mp4')) {
            print("==================");
            VideoPlayerController controller =
                VideoPlayerController.asset(image);
            controller.play();
            return VideoPlayer(controller);
          }

          return Container(color: Colors.white);
        },
        // indicatorLayout: PageIndicatorLayout.COLOR,
        autoplay: false,
        itemCount: images.length,
        // pagination: const SwiperPagination(),
        controller: swiperController,
      ),
    );
  }
}
