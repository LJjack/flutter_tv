import 'dart:io';

import 'package:flutter/material.dart';
import 'package:play/play.dart';

class VideoTV extends StatefulWidget {
  final String fileUrl;

  const VideoTV(this.fileUrl,{
    Key? key,
  }) : super(key: key);

  @override
  State<VideoTV> createState() => _VideoTVState();
}

class _VideoTVState extends State<VideoTV> {

  late VideoData videoData;

  @override
  void initState() {
    if (widget.fileUrl.startsWith("http://") ||
        widget.fileUrl.startsWith("https://")) {
      videoData = VideoData.network(url: widget.fileUrl);
    } else if (widget.fileUrl.startsWith('assets/')) {
      videoData = VideoData.asset( path: widget.fileUrl) ;
    } else {
      videoData = VideoData.file(file: File(widget.fileUrl)) ;
    }
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Video(
        videoData: videoData,
        builder: (BuildContext context, Widget child, Video video,
            VideoState videoState, VideoController videoController) {
         

          return Container(
            color: Colors.black,
            child: Stack(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  // height: 300,
                  child: AspectRatio(aspectRatio:  videoController.aspectRatio,child: child,),
                ),
                // child,
                Positioned(
                  bottom: 5,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () {
                            videoState.videoController.playOrPause();
                            videoState.setState(() {});
                          },
                          child: const Icon(
                            Icons.pause,
                            color: Colors.white,
                          ),
                        ),
                        InkWell(
                          onTap: () {},
                          child: const Icon(
                            Icons.skip_next,
                            color: Colors.white,
                          ),
                        ),
                        Expanded(
                          child: StreamBuilder(
                            stream: videoState.videoController
                                .streamDurationPosition(),
                            builder: (BuildContext context,
                                AsyncSnapshot snapshot) {
                              return Slider(
                                min: 0,
                                max: videoState.videoController
                                    .getDurationMax()
                                    .inMilliseconds
                                    .toDouble(),
                                value: videoState.videoController
                                    .getDurationPosition()
                                    .inMilliseconds
                                    .toDouble(),
                                onChanged: (double value) {
                                  setState(() {
                                    videoState.videoController.seek(
                                        Duration(
                                            milliseconds:
                                            value.toInt()));
                                  });
                                },
                              );
                            },
                          ),
                        ),

                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }


}
