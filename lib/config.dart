
enum PlayType {
  video,
  image,
  other,
}

extension PlayTypeExtension on PlayType {


 static PlayType playType(int index) {
    PlayType type = PlayType.video;
    switch (index) {

      case 0:
        type = PlayType.video;
        break;
      case 1:
        type = PlayType.image;
        break;
      default:
        type = PlayType.other;
        break;
    }
    return type;
  }



}

const kImageNextPage = "k-image-next-page";
const kImagePreviousPage = "k-image-previous-page";
const kImageStop = "k-image-stop";
const kImagePlay = "k-image-play";

const kVideoNextPlay = "k-video-next-play";
const kVideoNextPause = "k-video-next-pause";
const kVideoSlider = "k-video-slider";