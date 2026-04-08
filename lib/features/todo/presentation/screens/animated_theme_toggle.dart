import 'package:flutter/material.dart';

/// Animated moon ↔ sun theme toggle.
/// Drop-in replacement for Flutter's Switch on the settings screen.
class AnimatedThemeToggle extends StatefulWidget {
  final bool isDark;
  final ValueChanged<bool> onChanged;

  const AnimatedThemeToggle({
    super.key,
    required this.isDark,
    required this.onChanged,
  });

  @override
  State<AnimatedThemeToggle> createState() => _AnimatedThemeToggleState();
}

class _AnimatedThemeToggleState extends State<AnimatedThemeToggle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnim;
  late Animation<double> _rotateAnim;
  late Animation<double> _trackColorAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
      value: widget.isDark ? 0.0 : 1.0,
    );
    _slideAnim = CurvedAnimation(
        parent: _controller, curve: Curves.easeInOutCubic);
    _rotateAnim = Tween(begin: 0.0, end: 0.5).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _trackColorAnim = _slideAnim;
  }

  @override
  void didUpdateWidget(AnimatedThemeToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isDark != oldWidget.isDark) {
      if (widget.isDark) {
        _controller.reverse();
      } else {
        _controller.forward();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const width = 64.0;
    const height = 34.0;
    const thumbSize = 26.0;
    const padding = 4.0;
    const travel = width - thumbSize - padding * 2;

    const darkTrack = Color(0xFF2D3561);   // deep indigo — night
    const lightTrack = Color(0xFFFFB347);  // warm amber — day

    return GestureDetector(
      onTap: () => widget.onChanged(!widget.isDark),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final trackColor =
          Color.lerp(darkTrack, lightTrack, _trackColorAnim.value)!;
          final thumbX = padding + _slideAnim.value * travel;

          return SizedBox(
            width: width,
            height: height,
            child: Stack(
              children: [
                Container(
                  width: width,
                  height: height,
                  decoration: BoxDecoration(
                    color: trackColor,
                    borderRadius: BorderRadius.circular(height / 2),
                    boxShadow: [
                      BoxShadow(
                        color: trackColor.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Opacity(
                    opacity: (1 - _trackColorAnim.value).clamp(0.0, 1.0),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _star(3),
                            const SizedBox(height: 2),
                            _star(5),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                Opacity(
                  opacity: _trackColorAnim.value.clamp(0.0, 1.0),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(3, (i) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          width: 2,
                          height: i == 1 ? 10 : 6,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        )),
                      ),
                    ),
                  ),
                ),

                Positioned(
                  left: thumbX,
                  top: padding,
                  child: RotationTransition(
                    turns: _rotateAnim,
                    child: Container(
                      width: thumbSize,
                      height: thumbSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: _controller.value > 0.5
                              ? const Icon(Icons.wb_sunny_rounded,
                              key: ValueKey('sun'),
                              size: 16,
                              color: Color(0xFFFFB347))
                              : const Icon(Icons.nightlight_round,
                              key: ValueKey('moon'),
                              size: 14,
                              color: Color(0xFF3B4A8A)),
                        ),
                      ),
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

  Widget _star(double size) => Container(
    width: size,
    height: size,
    decoration: const BoxDecoration(
      color: Colors.white,
      shape: BoxShape.circle,
    ),
  );
}