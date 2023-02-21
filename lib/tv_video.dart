import 'package:flutter/material.dart';
import 'package:flutter_tv/config.dart';
import 'package:flutter_tv/payload.dart';
import 'package:flutter_tv/server_base_mixin.dart';
import 'package:flutter_tv/video_view.dart';
import 'package:video_player/video_player.dart';

class TVVideo extends StatefulWidget {
  const TVVideo(this.fileUrl, {Key? key}) : super(key: key);
  final String fileUrl;

  @override
  State<TVVideo> createState() => _TVVideoState();
}

class _TVVideoState extends State<TVVideo> with ServerBaseMixin {
  late VideoPlayerController? controller;

  @override
  void initState() {
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
          if (payload.type == PlayType.video.value) {
            final data = payload.data!;
            final cmd = VideoCMD.cmd(data.name);

            setState(() {
              switch (cmd) {
                case VideoCMD.play:
                  controller?.play();
                  break;
                case VideoCMD.pause:
                  controller?.pause();
                  break;
                case VideoCMD.slider:
                  if (controller != null) {
                    controller
                        ?.seekTo(controller!.value.duration * data.progress);
                  }

                  break;
                case VideoCMD.unknown:
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
    return VideoView(
      widget.fileUrl,
      onController: (ctr) {
        controller = ctr;
      },
    );
  }
}
