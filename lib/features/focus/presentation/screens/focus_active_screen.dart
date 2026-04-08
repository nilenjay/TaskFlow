import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/features/focus/data/models/focus_model.dart';
import 'package:todo_app/features/focus/presentation/bloc/focus_bloc/focus_bloc.dart';
import 'package:todo_app/features/focus/presentation/bloc/focus_bloc/focus_event.dart';
import 'package:todo_app/features/focus/presentation/bloc/focus_bloc/focus_state.dart';


const _studyQuotes = [
  '"The more that you read, the more things you will know." — Dr. Seuss',
  '"Live as if you were to die tomorrow. Learn as if you were to live forever." — Gandhi',
  '"An investment in knowledge pays the best interest." — Benjamin Franklin',
  '"Education is not the filling of a pail, but the lighting of a fire." — W.B. Yeats',
  '"The beautiful thing about learning is that nobody can take it away from you." — B.B. King',
  '"Study hard what interests you the most in the most undisciplined, irreverent and original manner possible." — Richard Feynman',
  '"Develop a passion for learning. If you do, you will never cease to grow." — Anthony J. D\'Angelo',
  '"Success is no accident. It is hard work, perseverance, learning, studying, sacrifice." — Pelé',
];

const _deepWorkQuotes = [
  '"Deep work is the ability to focus without distraction on a cognitively demanding task." — Cal Newport',
  '"The key is not to prioritize what\'s on your schedule, but to schedule your priorities." — Stephen Covey',
  '"Focus is more valuable than intelligence." — Robert Greene',
  '"Concentrate all your thoughts upon the work at hand." — Alexander Graham Bell',
  '"It is not enough to be busy. The question is: what are we busy about?" — Thoreau',
  '"You have to fight to reach your dream. You have to sacrifice and work hard for it." — Lionel Messi',
  '"The successful warrior is the average man, with laser-like focus." — Bruce Lee',
  '"Your work is going to fill a large part of your life. Do great work." — Steve Jobs',
];

const _creativeQuotes = [
  '"Creativity is intelligence having fun." — Albert Einstein',
  '"You can\'t use up creativity. The more you use, the more you have." — Maya Angelou',
  '"Every artist was first an amateur." — Ralph Waldo Emerson',
  '"Creativity takes courage." — Henri Matisse',
  '"The worst enemy to creativity is self-doubt." — Sylvia Plath',
  '"Imagination is everything. It is the preview of life\'s coming attractions." — Einstein',
  '"Art enables us to find ourselves and lose ourselves at the same time." — Thomas Merton',
  '"Create with the heart; build with the mind." — Criss Jami',
];

List<String> _quotesForType(FocusType type) {
  switch (type) {
    case FocusType.study:
      return _studyQuotes;
    case FocusType.deepWork:
      return _deepWorkQuotes;
    case FocusType.creative:
      return _creativeQuotes;
  }
}


const _focusGradientColors = [Color(0xFF4F46E5), Color(0xFF7C3AED)]; // indigo→violet
const _breakGradientColors = [Color(0xFF059669), Color(0xFF0D9488)]; // emerald→teal


class FocusActiveScreen extends StatefulWidget {
  final FocusRunning state;
  const FocusActiveScreen({super.key, required this.state});

  @override
  State<FocusActiveScreen> createState() => _FocusActiveScreenState();
}

class _FocusActiveScreenState extends State<FocusActiveScreen>
    with TickerProviderStateMixin {
  late AnimationController _gradientController;
  late Animation<double> _gradientAnimation;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  late AnimationController _quoteController;
  late Animation<double> _quoteOpacity;

  int _quoteIndex = 0;
  int _lastQuoteChangeSec = 0;
  static const _quoteIntervalSec = 120; // change every 2 minutes

  bool _showingOverlay = false;
  String _overlayMessage = '';
  late AnimationController _overlayController;
  late Animation<double> _overlayOpacity;

  SessionPhase? _lastPhase;

  @override
  void initState() {
    super.initState();

    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _gradientAnimation = CurvedAnimation(
      parent: _gradientController,
      curve: Curves.easeInOut,
    );
    if (widget.state.phase == SessionPhase.breakTime) {
      _gradientController.value = 1.0;
    }

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _quoteController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _quoteOpacity = CurvedAnimation(
      parent: _quoteController,
      curve: Curves.easeInOut,
    );
    _quoteController.forward();

    _overlayController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _overlayOpacity = CurvedAnimation(
      parent: _overlayController,
      curve: Curves.easeInOut,
    );

    _lastPhase = widget.state.phase;

    final quotes = _quotesForType(widget.state.focusType);
    _quoteIndex = Random().nextInt(quotes.length);
  }

  @override
  void didUpdateWidget(FocusActiveScreen old) {
    super.didUpdateWidget(old);

    if (widget.state.phase != _lastPhase) {
      _lastPhase = widget.state.phase;
      _triggerPhaseTransition(widget.state.phase);
    }

    final elapsed = widget.state.elapsedSeconds;
    if (elapsed - _lastQuoteChangeSec >= _quoteIntervalSec) {
      _lastQuoteChangeSec = elapsed;
      _rotateQuote();
    }

    if (widget.state.isPaused && _pulseController.isAnimating) {
      _pulseController.stop();
    } else if (!widget.state.isPaused && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    }
  }

  void _triggerPhaseTransition(SessionPhase phase) {
    HapticFeedback.mediumImpact();

    setState(() {
      _showingOverlay = true;
      _overlayMessage = phase == SessionPhase.breakTime
          ? '☕  Break Time!'
          : '🎯  Back to Focus!';
    });

    if (phase == SessionPhase.breakTime) {
      _gradientController.forward();
    } else {
      _gradientController.reverse();
    }

    _overlayController.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 1400), () {
        if (!mounted) return;
        _overlayController.reverse().then((_) {
          if (!mounted) return;
          setState(() => _showingOverlay = false);
        });
      });
    });
  }

  void _rotateQuote() {
    _quoteController.reverse().then((_) {
      if (!mounted) return;
      final quotes = _quotesForType(widget.state.focusType);
      setState(() {
        _quoteIndex = (_quoteIndex + 1) % quotes.length;
      });
      _quoteController.forward();
    });
  }

  @override
  void dispose() {
    _gradientController.dispose();
    _pulseController.dispose();
    _quoteController.dispose();
    _overlayController.dispose();
    super.dispose();
  }

  String _format(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  int _currentPhaseTotalSeconds() {
    final breaks =
    calculateBreaks(widget.state.totalSeconds ~/ 60, widget.state.focusType);
    if (widget.state.phase == SessionPhase.breakTime) {
      if (widget.state.currentBreakIndex < breaks.length) {
        return breaks[widget.state.currentBreakIndex].breakMinutes * 60;
      }
    }
    if (widget.state.currentBreakIndex < breaks.length) {
      final breakAt =
          breaks[widget.state.currentBreakIndex].afterMinutes * 60;
      final prevEnd = widget.state.currentBreakIndex > 0
          ? (breaks[widget.state.currentBreakIndex - 1].afterMinutes +
          breaks[widget.state.currentBreakIndex - 1].breakMinutes) *
          60
          : 0;
      return breakAt - prevEnd;
    }
    return widget.state.totalSeconds -
        widget.state.elapsedSeconds +
        widget.state.phaseSecondsLeft;
  }

  void _confirmEnd(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('End Session?'),
        content: const Text(
            'Your progress will be saved and you\'ll see a summary.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<FocusBloc>().add(const EndSession());
            },
            child: const Text('End Session'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final isFocus = state.phase == SessionPhase.focus;
    final quotes = _quotesForType(state.focusType);
    final currentQuote = quotes[_quoteIndex % quotes.length];

    final overallProgress =
    (state.elapsedSeconds / state.totalSeconds).clamp(0.0, 1.0);
    final phaseTotalSeconds = _currentPhaseTotalSeconds();
    final phaseProgress = phaseTotalSeconds > 0
        ? (1 - state.phaseSecondsLeft / phaseTotalSeconds).clamp(0.0, 1.0)
        : 0.0;

    return Stack(
      children: [
        AnimatedBuilder(
          animation: _gradientAnimation,
          builder: (context, _) {
            final t = _gradientAnimation.value;
            final colors = [
              Color.lerp(
                  _focusGradientColors[0], _breakGradientColors[0], t)!,
              Color.lerp(
                  _focusGradientColors[1], _breakGradientColors[1], t)!,
            ];
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: colors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            );
          },
        ),

        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              state.sessionName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            automaticallyImplyLeading: false,
            actions: [
              TextButton(
                onPressed: () => _confirmEnd(context),
                child: const Text('End',
                    style: TextStyle(color: Colors.white70)),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 8),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${state.elapsedSeconds ~/ 60}m / ${state.totalSeconds ~/ 60}m',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12),
                        ),
                        Text(
                          '${(overallProgress * 100).round()}%',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: overallProgress,
                        minHeight: 5,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation(Colors.white),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: Text(
                    isFocus ? '🎯  Focus Time' : '☕  Break Time',
                    key: ValueKey(state.phase),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) => Transform.scale(
                    scale: state.isPaused ? 1.0 : _pulseAnimation.value,
                    child: child,
                  ),
                  child: SizedBox(
                    width: 230,
                    height: 230,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: const Size(230, 230),
                          painter: _RingPainter(
                            progress: phaseProgress,
                            ringColor: Colors.white,
                            trackColor: Colors.white24,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _format(state.phaseSecondsLeft),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 52,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -1,
                                fontFeatures: [FontFeature.tabularFigures()],
                              ),
                            ),
                            if (state.isPaused)
                              const Text(
                                'Paused',
                                style: TextStyle(
                                    color: Colors.white60, fontSize: 14),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                if (state.totalBreaks > 0) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(state.totalBreaks, (i) {
                      final done = i < state.currentBreakIndex;
                      final active = i == state.currentBreakIndex &&
                          state.phase == SessionPhase.breakTime;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: done
                              ? Colors.white
                              : active
                              ? Colors.white54
                              : Colors.white24,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${state.currentBreakIndex} of ${state.totalBreaks} breaks taken',
                    style: const TextStyle(
                        color: Colors.white60, fontSize: 12),
                  ),
                  const SizedBox(height: 20),
                ],

                FadeTransition(
                  opacity: _quoteOpacity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      currentQuote,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!isFocus) ...[
                      OutlinedButton.icon(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          context
                              .read<FocusBloc>()
                              .add(const SkipBreak());
                        },
                        icon: const Icon(Icons.skip_next,
                            color: Colors.white),
                        label: const Text('Skip Break',
                            style: TextStyle(color: Colors.white)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white38),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],

                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        if (state.isPaused) {
                          context
                              .read<FocusBloc>()
                              .add(const ResumeSession());
                        } else {
                          context
                              .read<FocusBloc>()
                              .add(const PauseSession());
                        }
                      },
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          state.isPaused
                              ? Icons.play_arrow_rounded
                              : Icons.pause_rounded,
                          size: 38,
                          color: isFocus
                              ? _focusGradientColors[0]
                              : _breakGradientColors[0],
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(
                  height: kBottomNavigationBarHeight +
                      MediaQuery.of(context).padding.bottom +
                      24,
                ),
              ],
            ),
          ),
        ),

        if (_showingOverlay)
          FadeTransition(
            opacity: _overlayOpacity,
            child: Container(
              color: Colors.black54,
              alignment: Alignment.center,
              child: Text(
                _overlayMessage,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}


class _RingPainter extends CustomPainter {
  final double progress;
  final Color ringColor;
  final Color trackColor;

  _RingPainter({
    required this.progress,
    required this.ringColor,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 14;
    const stroke = 10.0;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      Paint()
        ..color = ringColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress;
}