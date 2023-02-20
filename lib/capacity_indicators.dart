import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class CapacityIndicator extends StatefulWidget {
  /// Creates a capacity indicator.
  ///
  /// [initialValue] must be in range of min to max.
  ///

  static const Color yellowAccent = Color(0x66FFF176);
  static const Color yellow = Color(0xFFFDD835);

  const CapacityIndicator({
    Key? key,
    required this.controller,
    this.min = 0.0,
    this.max = 1.0,
    this.color = Colors.yellow,
    this.bufferedColor = yellowAccent,
    this.onChanged,
  }) : super(key: key);

  final double min;
  final double max;

  /// Called when the current value of the indicator changes.
  final ValueChanged<double>? onChanged;

  final Color color;
  final Color bufferedColor;

  final VideoPlayerController controller;

  @override
  State<CapacityIndicator> createState() => _CapacityIndicatorState();
}

class _CapacityIndicatorState extends State<CapacityIndicator> {
  double initialValue = 0.0;
  double bufferedValue = 0.0;

  String textTime = "00:00/00:00";

  _CapacityIndicatorState() {
    listener = () {
      if (!mounted) {
        return;
      }

      if (controller.value.isInitialized) {
        final double duration = controller.value.duration.inMilliseconds.toDouble();
        final double position = controller.value.position.inMilliseconds.toDouble();

        double maxBuffering = 0;
        for (final DurationRange range in controller.value.buffered) {
          final double end = range.end.inMilliseconds.toDouble();
          if (end > maxBuffering) {
            maxBuffering = end;
          }
        }
        initialValue = position / duration;
        bufferedValue = maxBuffering / duration;

        textTime = "${handleTime(
            controller.value.position)} / ${handleTime(controller.value.duration)}";

        setState(() {});
      }
    };
  }

  late VoidCallback listener;

  VideoPlayerController get controller => widget.controller;

  // Returns a number between min and max, proportional to value, which must
  // be between 0.0 and 1.0.
  double _lerp(double value) {
    assert(value >= 0.0);
    assert(value <= 1.0);
    return value * (widget.max - widget.min) + widget.min;
  }

  void _handleUpdate(Offset lp, double width) {
    double value = (lp.dx / width);
    value = value.clamp(0.0, 1.0);
    double relative = _lerp(value);

    seekToRelativePosition(relative);

    widget.onChanged?.call(relative);
  }

  void seekToRelativePosition(double relative) {
    final Duration position = controller.value.duration * relative;
    controller.seekTo(position);
  }

  String handleTime(Duration? duration) {
    if (duration == null) return '';

    return RegExp(r'((^0*[1-9]\d*:)?\d{2}:\d{2})\.\d+$')
        .firstMatch("$duration")
        ?.group(1) ??
        '$duration';
  }

  @override
  void initState() {
    super.initState();
    controller.addListener(listener);
  }

  @override
  void deactivate() {
    controller.removeListener(listener);
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(textTime,
              style: const TextStyle(
                  fontSize: 10,
                  color: Colors.black54)),
        ),

        Expanded(
          child: LayoutBuilder(builder: (context, constraints) {
            final width = constraints.maxWidth;
            return SizedBox(
              width: width,
              height: 30,
              child: GestureDetector(
                onPanStart: (event) => _handleUpdate(event.localPosition, width),
                onPanUpdate: (event) => _handleUpdate(event.localPosition, width),
                onPanDown: (event) => _handleUpdate(event.localPosition, width),
                child: CustomPaint(
                  painter: _CapacityCellPainter(
                    color: widget.color,
                    bufferedColor: widget.bufferedColor,
                    value: initialValue / widget.max,
                    bufferedValue: bufferedValue / widget.max,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _CapacityCellPainter extends CustomPainter {
  const _CapacityCellPainter({
    required this.color,
    required this.value,
    required this.bufferedColor,
    required this.bufferedValue,
  });

  final Color color;
  final Color bufferedColor;
  final double value;
  final double bufferedValue;

  @override
  void paint(Canvas canvas, Size size) {
    const radius = 2.0;

    /// Draw default
    canvas.drawRRect(
      const BorderRadius.horizontal(
          left: Radius.circular(radius),
          right:  Radius.circular(radius)
              )
          .toRRect(Offset(0, (size.height - 4) * 0.5) &
      Size(size.width , 4)),
      Paint()..color = Colors.black26,
    );

    canvas.drawRRect(
      BorderRadius.horizontal(
          left: const Radius.circular(radius),
          right: bufferedValue == 1
              ? const Radius.circular(radius)
              : Radius.zero)
          .toRRect(Offset(0, (size.height - 4) * 0.5) &
      Size(size.width * bufferedValue.clamp(0.0, 1.0), 4)),
      Paint()..color = bufferedColor,
    );

    /// Draw buffered
    canvas.drawRRect(
      BorderRadius.horizontal(
              left: const Radius.circular(radius),
              right: bufferedValue == 1
                  ? const Radius.circular(radius)
                  : Radius.zero)
          .toRRect(Offset(0, (size.height - 4) * 0.5) &
              Size(size.width * bufferedValue.clamp(0.0, 1.0), 4)),
      Paint()..color = bufferedColor,
    );

    /// Draw inside
    canvas.drawRRect(
      BorderRadius.horizontal(
        left: const Radius.circular(radius),
        right: value == 1 ? const Radius.circular(radius) : Radius.zero,
      ).toRRect(
        Offset(0, (size.height - 4) * 0.5) &
            Size(size.width * value.clamp(0.0, 1.0), 4),
      ),
      Paint()..color = color,
    );

    /// Draw ball
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: Offset(
                    size.width * value.clamp(0.0, 1.0), size.height * 0.5),
                width: 20,
                height: 20),
            const Radius.circular(10)),
        Paint()..color = color);
  }

  @override
  bool shouldRepaint(_CapacityCellPainter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(_CapacityCellPainter oldDelegate) => false;
}
