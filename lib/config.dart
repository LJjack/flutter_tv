enum PlayType {
  video(0),
  image(1),
  unknown(-1);

  final int value;

  const PlayType(this.value);

  static PlayType type(int number) => PlayType.values.firstWhere((e) => e.value == number, orElse: () => PlayType.unknown);
}

//图片指令
enum ImageCMD {
  next(0),
  previous(1),
  play(2),
  stop(3),
  number(4),//第几个
  unknown(-1);

  final int value;

  const ImageCMD(this.value);

  static ImageCMD cmd(int number) => ImageCMD.values.firstWhere((e) => e.value == number, orElse: () => ImageCMD.unknown);

}

//视频指令
enum VideoCMD {
  play(0),
  pause(1),
  slider(2),
  unknown(-1);

  final int value;

  const VideoCMD(this.value);

  static VideoCMD cmd(int number) => VideoCMD.values.firstWhere((e) => e.value == number, orElse: () => VideoCMD.unknown);
}

//下拉指令
enum DropdownCMD {
  hand(0,"手动"),
  auto(1,"自动"),
  refresh(2,"刷新");

  final int value;
  final String name;

  const DropdownCMD(this.value, this.name);

  static DropdownCMD cmd(int number) => DropdownCMD.values.firstWhere((e) => e.value == number, orElse: () => DropdownCMD.auto);
}