import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

typedef OnTap<T> = void Function(double progress);

class WaveformProgressbar extends StatefulWidget {
  WaveformProgressbar({required this.color, required this.progressColor, this.progress = 0, this.onTap, Key? key}) : super(key: key);
  Color color;
  Color progressColor;
  OnTap? onTap;

  /// must be between 0 and 1.0
  double progress;

  @override
  State<WaveformProgressbar> createState() => _WaveformProgressbarState();
}

class _WaveformProgressbarState extends State<WaveformProgressbar> {
  GlobalKey stickyKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) {
        var xpos = details.localPosition.dx;
        var keyContext = stickyKey.currentContext;
        final box = keyContext?.findRenderObject() as RenderBox;
        var width = box.size.width;
        widget.progress = xpos / width;
        setState(() {});
        if (widget.onTap != null) {
          widget.onTap!(widget.progress);
        }
      },
      child: Stack(
        children: [
          ShaderMask(
            blendMode: BlendMode.modulate,
            shaderCallback: (rect) {
              return LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                stops: [widget.progress, widget.progress],
                colors: [widget.progressColor, widget.color],
              ).createShader(rect);
            },
            child: SvgPicture.asset(
              key: stickyKey,
              fit: BoxFit.fill,
              width: double.infinity,
              //height: MediaQuery.of(context).size.width / 13,
              height: double.infinity,
              "assets/icons/wave_form_w.svg",
              // package: "simple_waveform_progressbar",
              colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            ),
          ),
          // SvgPicture.asset(
          //   "assets/wave-form2.svg",
          //   colorFilter: const ColorFilter.mode(Colors.red,BlendMode.srcIn),
          // ),
        ],
      ),
    );
  }
}


// width: double.infinity,
// height: MediaQuery.of(context).size.width / 13,
