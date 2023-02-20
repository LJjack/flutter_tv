import 'package:flutter/material.dart';
import 'package:flutter_tv/config.dart';
import 'package:flutter_tv/payload.dart';
import 'package:flutter_tv/server_base_mixin.dart';
import 'package:flutter_tv/video_view.dart';

class TVVideo extends StatefulWidget {
  const TVVideo(this.fileUrl, {Key? key}) : super(key: key);
  final String fileUrl;

  @override
  State<TVVideo> createState() => _TVVideoState();
}

class _TVVideoState extends State<TVVideo> with ServerBaseMixin{


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


          if (payload.type == PlayType.image.index) {
            PlayModel data = payload.data!;

            setState(() async{
              ImageCMD cmd = ImageCMD.cmd(data.name ?? 0);


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
    return VideoView(widget.fileUrl);
  }
}
