import 'package:flutter/material.dart';

/// Displays an animated, crisp weather icon mapped from OpenWeatherMap icon codes.
class WeatherIconWidget extends StatefulWidget {
  final String iconCode;
  final double size;
  final bool animate;

  const WeatherIconWidget({
    super.key,
    required this.iconCode,
    this.size = 64,
    this.animate = true,
  });

  @override
  State<WeatherIconWidget> createState() => _WeatherIconWidgetState();
}

class _WeatherIconWidgetState extends State<WeatherIconWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _floatAnimation = Tween<double>(begin: -3.0, end: 3.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.animate) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visual = _resolveIconVisual(widget.iconCode);

    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, widget.animate ? _floatAnimation.value : 0),
          child: child,
        );
      },
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              visual.glowColor,
              const Color.fromRGBO(255, 255, 255, 0.0),
            ],
          ),
        ),
        child: Icon(
          visual.icon,
          size: widget.size * 0.72,
          color: visual.color,
        ),
      ),
    );
  }

  _IconVisual _resolveIconVisual(String code) {
    final prefix = code.length >= 2 ? code.substring(0, 2) : '01';
    final isNight = code.endsWith('n');

    switch (prefix) {
      case '01':
        return isNight
            ? const _IconVisual(
                icon: Icons.nightlight_round,
                color: Color(0xFFE0E7FF),
                glowColor: Color.fromRGBO(165, 180, 252, 0.25),
              )
            : const _IconVisual(
                icon: Icons.wb_sunny_rounded,
                color: Color(0xFFFCD34D),
                glowColor: Color.fromRGBO(251, 191, 36, 0.28),
              );
      case '02':
        return const _IconVisual(
          icon: Icons.wb_cloudy_rounded,
          color: Color(0xFFFDE68A),
          glowColor: Color.fromRGBO(253, 230, 138, 0.22),
        );
      case '03':
      case '04':
        return const _IconVisual(
          icon: Icons.cloud_rounded,
          color: Color(0xFFDBEAFE),
          glowColor: Color.fromRGBO(147, 197, 253, 0.22),
        );
      case '09':
      case '10':
        return const _IconVisual(
          icon: Icons.grain_rounded,
          color: Color(0xFF60A5FA),
          glowColor: Color.fromRGBO(96, 165, 250, 0.26),
        );
      case '11':
        return const _IconVisual(
          icon: Icons.thunderstorm_rounded,
          color: Color(0xFFC084FC),
          glowColor: Color.fromRGBO(192, 132, 252, 0.26),
        );
      case '13':
        return const _IconVisual(
          icon: Icons.ac_unit_rounded,
          color: Color(0xFFE0F2FE),
          glowColor: Color.fromRGBO(186, 230, 253, 0.28),
        );
      case '50':
        return const _IconVisual(
          icon: Icons.foggy,
          color: Color(0xFFCBD5E1),
          glowColor: Color.fromRGBO(203, 213, 225, 0.20),
        );
      default:
        return const _IconVisual(
          icon: Icons.wb_sunny_rounded,
          color: Color(0xFFFCD34D),
          glowColor: Color.fromRGBO(251, 191, 36, 0.25),
        );
    }
  }
}

class _IconVisual {
  final IconData icon;
  final Color color;
  final Color glowColor;

  const _IconVisual({
    required this.icon,
    required this.color,
    required this.glowColor,
  });
}
