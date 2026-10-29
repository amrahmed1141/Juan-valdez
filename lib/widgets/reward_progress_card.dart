import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants/app_assets.dart';
import '../core/constants/app_colors.dart';
import '../core/theme/app_theme.dart';

/// Compact gamified rewards card — milestone track + reactive earn motions.
class RewardProgressCard extends StatefulWidget {
  const RewardProgressCard({
    super.key,
    required this.points,
    required this.goal,
    required this.onViewRewards,
  });

  final int points;
  final int goal;
  final VoidCallback onViewRewards;

  /// Croissant → cookie → coffee.
  static const int milestoneCount = 3;

  static const List<String> milestoneImages = [
    AppAssets.butterCroissant,
    AppAssets.chocolateChipCookie,
    AppAssets.juanValdezCoffee,
  ];

  @override
  State<RewardProgressCard> createState() => _RewardProgressCardState();
}

class _RewardProgressCardState extends State<RewardProgressCard>
    with TickerProviderStateMixin {
  static const double _milestoneSize = 32;

  late AnimationController _progressController;
  late Animation<double> _progress;

  late final AnimationController _wobbleController;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseScale;
  late final AnimationController _chipController;
  late final AnimationController _arrowController;
  late final AnimationController _celebrateController;
  late final List<AnimationController> _popControllers;

  final Set<int> _unlockedSeen = {};

  bool _pressed = false;
  int _chipDelta = 0;
  bool _didCelebrate = false;
  bool _pulseOnComplete = true;

  double get _target {
    if (widget.goal == 0) return 0;
    return (widget.points / widget.goal).clamp(0.0, 1.0);
  }

  bool get _nearGoal => _target >= 0.8 && _target < 1.0;
  bool get _goalReached => widget.points >= widget.goal && widget.goal > 0;

  List<double> get _stops {
    const n = RewardProgressCard.milestoneCount;
    return List.generate(n, (i) => i / (n - 1));
  }

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _progress = Tween<double>(begin: 0, end: _target).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOutCubic),
    );

    _wobbleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4200),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _pulseScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.22)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 45,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.22, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 55,
      ),
    ]).animate(_pulseController);

    _chipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _arrowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );

    _celebrateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _popControllers = List.generate(
      RewardProgressCard.milestoneCount,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 350),
      ),
    );

    _progressController.addListener(_onProgressTick);
    _progressController.addStatusListener(_onProgressStatus);
    _syncWobbleSpeed();

    Future<void>.delayed(const Duration(milliseconds: 280), () {
      if (!mounted) return;
      _progressController.forward();
      if (_goalReached) {
        _didCelebrate = true;
        _celebrateController.forward(from: 0);
      }
    });
  }

  void _onProgressStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && mounted && _pulseOnComplete) {
      _pulseOnComplete = false;
      _pulseController.forward(from: 0);
    }
  }

  void _syncWobbleSpeed() {
    _wobbleController.duration = Duration(
      milliseconds: _nearGoal ? 1800 : 4200,
    );
    if (_wobbleController.isAnimating) {
      _wobbleController.repeat();
    }
  }

  void _onProgressTick() {
    final value = _progress.value;
    for (var i = 0; i < _stops.length; i++) {
      if (value + 0.001 >= _stops[i] && !_unlockedSeen.contains(i)) {
        _unlockedSeen.add(i);
        _popControllers[i].forward(from: 0);
      }
    }
  }

  void _animateTo(double begin, double end, {required Duration duration}) {
    _progressController
      ..removeListener(_onProgressTick)
      ..removeStatusListener(_onProgressStatus)
      ..dispose();
    _progressController = AnimationController(vsync: this, duration: duration);
    _progress = Tween<double>(begin: begin, end: end).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOutCubic),
    );
    _progressController.addListener(_onProgressTick);
    _progressController.addStatusListener(_onProgressStatus);
    setState(() {});
    _progressController.forward();
  }

  @override
  void didUpdateWidget(covariant RewardProgressCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.points == widget.points && oldWidget.goal == widget.goal) {
      return;
    }

    final delta = widget.points - oldWidget.points;
    if (delta > 0) {
      _chipDelta = delta;
    }
    _animateTo(
      _progress.value,
      _target,
      duration: const Duration(milliseconds: 720),
    );
    _syncWobbleSpeed();

    if (delta > 0) {
      _pulseOnComplete = false;
      _pulseController.forward(from: 0);
      _chipController.forward(from: 0);
      HapticFeedback.lightImpact();
    } else {
      _pulseOnComplete = true;
    }

    if (!_didCelebrate && _goalReached) {
      _didCelebrate = true;
      _celebrateController.forward(from: 0);
      HapticFeedback.mediumImpact();
    }
  }

  @override
  void dispose() {
    _progressController.removeListener(_onProgressTick);
    _progressController.removeStatusListener(_onProgressStatus);
    _progressController.dispose();
    _wobbleController.dispose();
    _pulseController.dispose();
    _chipController.dispose();
    _arrowController.dispose();
    _celebrateController.dispose();
    for (final c in _popControllers) {
      c.dispose();
    }
    super.dispose();
  }

  int _currentTargetIndex(double progress) {
    for (var i = 0; i < _stops.length; i++) {
      if (progress < _stops[i] - 0.001) return i;
    }
    return _stops.length - 1;
  }

  @override
  Widget build(BuildContext context) {
    final remaining = (widget.goal - widget.points).clamp(0, widget.goal);

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _pressed = true);
        _arrowController.forward();
      },
      onTapUp: (_) {
        setState(() => _pressed = false);
        _arrowController.reverse();
        widget.onViewRewards();
      },
      onTapCancel: () {
        setState(() => _pressed = false);
        _arrowController.reverse();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            color: _goalReached
                ? const Color(0xFFFFF5EC)
                : (_nearGoal
                    ? const Color(0xFFFFE8F2)
                    : AppColors.rewardsSection),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _nearGoal || _goalReached
                  ? AppColors.primaryPink.withOpacity(0.22)
                  : Colors.transparent,
            ),
            boxShadow: AppTheme.softShadowLight,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'REWARDS',
                        style: GoogleFonts.nunito(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.9,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      AnimatedBuilder(
                        animation: Listenable.merge([
                          _progress,
                          _pulseController,
                        ]),
                        builder: (context, _) {
                          final shown = (_progress.value * widget.goal)
                              .round()
                              .clamp(0, widget.goal);
                          final glow = _pulseController.value;
                          final glowAlpha =
                              (math.sin(glow * math.pi) * 0.55).clamp(0.0, 0.55);
                          return Transform.scale(
                            scale: _pulseScale.value,
                            alignment: Alignment.centerRight,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryPink
                                    .withOpacity(0.08 + glowAlpha * 0.35),
                                borderRadius: BorderRadius.circular(99),
                                boxShadow: glowAlpha > 0.05
                                    ? [
                                        BoxShadow(
                                          color: AppColors.primaryPink
                                              .withOpacity(glowAlpha),
                                          blurRadius: 14,
                                          spreadRadius: 1,
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Text(
                                '$shown pts',
                                style: GoogleFonts.nunito(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primaryPink,
                                  height: 1,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      _ClaimOrArrow(
                        goalReached: _goalReached,
                        arrow: _arrowController,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AnimatedBuilder(
                    animation: Listenable.merge([
                      _progress,
                      _wobbleController,
                      ..._popControllers,
                    ]),
                    builder: (context, _) {
                      return _MilestoneTrack(
                        progress: _progress.value,
                        milestoneSize: _milestoneSize,
                        stops: _stops,
                        images: RewardProgressCard.milestoneImages,
                        currentIndex: _currentTargetIndex(_progress.value),
                        wobble: _wobbleController.value,
                        nearGoal: _nearGoal,
                        chip: _chipController,
                        chipDelta: _chipDelta,
                        popValues: [
                          for (final c in _popControllers)
                            Curves.easeOut.transform(c.value.clamp(0.0, 1.0)),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _goalReached
                              ? 'FREE COFFEE READY'
                              : '$remaining to FREE COFFEE',
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _goalReached || _nearGoal
                                ? AppColors.primaryPink
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                      AnimatedBuilder(
                        animation: _progress,
                        builder: (context, _) {
                          var unlocked = 0;
                          for (final s in _stops) {
                            if (_progress.value + 0.001 >= s) unlocked++;
                          }
                          return Text(
                            '$unlocked/${RewardProgressCard.milestoneCount}',
                            style: GoogleFonts.nunito(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryPink.withOpacity(0.8),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedBuilder(
                    animation: _celebrateController,
                    builder: (context, _) {
                      if (_celebrateController.value <= 0) {
                        return const SizedBox.shrink();
                      }
                      return CustomPaint(
                        painter: _SprinklePainter(
                          progress: _celebrateController.value,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClaimOrArrow extends StatelessWidget {
  const _ClaimOrArrow({
    required this.goalReached,
    required this.arrow,
  });

  final bool goalReached;
  final AnimationController arrow;

  @override
  Widget build(BuildContext context) {
    if (goalReached) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.primaryPink,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Text(
          'CLAIM',
          style: GoogleFonts.nunito(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: AppColors.white,
            letterSpacing: 0.4,
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: arrow,
      builder: (context, _) {
        return Transform.translate(
          offset: Offset(arrow.value * 4, 0),
          child: Text(
            '→',
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryPink,
              height: 1,
            ),
          ),
        );
      },
    );
  }
}

class _MilestoneTrack extends StatelessWidget {
  const _MilestoneTrack({
    required this.progress,
    required this.milestoneSize,
    required this.stops,
    required this.images,
    required this.currentIndex,
    required this.wobble,
    required this.nearGoal,
    required this.popValues,
    required this.chip,
    required this.chipDelta,
  });

  final double progress;
  final double milestoneSize;
  final List<double> stops;
  final List<String> images;
  final int currentIndex;
  final double wobble;
  final bool nearGoal;
  final List<double> popValues;
  final AnimationController chip;
  final int chipDelta;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: milestoneSize + 8,
      width: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final trackLeft = milestoneSize / 2;
          final trackRight = width - milestoneSize / 2;
          final trackWidth = trackRight - trackLeft;
          final fillWidth = trackWidth * progress.clamp(0.0, 1.0);
          final centerY = (milestoneSize + 8) / 2;
          final tipX = trackLeft + fillWidth;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: trackLeft,
                top: centerY - 3,
                width: trackWidth,
                height: 6,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.progressTrack,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              Positioned(
                left: trackLeft,
                top: centerY - 3,
                width: math.max(0, fillWidth),
                height: 6,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: AppColors.brandGradient,
                    borderRadius: BorderRadius.circular(99),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.orange.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
              if (progress > 0.02 && progress < 1)
                Positioned(
                  left: tipX - 5,
                  top: centerY - 5,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.orange,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.orange.withOpacity(
                            nearGoal ? 0.7 : 0.5,
                          ),
                          blurRadius: nearGoal ? 12 : 8,
                          spreadRadius: nearGoal ? 1.5 : 0.5,
                        ),
                      ],
                    ),
                  ),
                ),
              if (chipDelta > 0)
                AnimatedBuilder(
                  animation: chip,
                  builder: (context, _) {
                    final t = chip.value;
                    if (t <= 0 || t >= 1) return const SizedBox.shrink();
                    final dy = -22.0 * Curves.easeOut.transform(t);
                    final opacity = (1.0 - t).clamp(0.0, 1.0);
                    return Positioned(
                      left: tipX - 16,
                      top: centerY - 20 + dy,
                      child: Opacity(
                        opacity: opacity,
                        child: Text(
                          '+$chipDelta',
                          style: GoogleFonts.nunito(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.orange,
                            height: 1,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              for (var i = 0; i < stops.length; i++)
                Positioned(
                  left: trackLeft + trackWidth * stops[i] - milestoneSize / 2,
                  top: 4,
                  child: _MilestoneItem(
                    size: milestoneSize,
                    imagePath: images[i],
                    unlocked: progress + 0.001 >= stops[i],
                    isCurrent: i == currentIndex && progress < 1,
                    isGoal: i == stops.length - 1,
                    nearGoal: nearGoal,
                    pop: popValues[i],
                    wobblePhase: wobble,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _MilestoneItem extends StatelessWidget {
  const _MilestoneItem({
    required this.size,
    required this.imagePath,
    required this.unlocked,
    required this.isCurrent,
    required this.isGoal,
    required this.nearGoal,
    required this.pop,
    required this.wobblePhase,
  });

  final double size;
  final String imagePath;
  final bool unlocked;
  final bool isCurrent;
  final bool isGoal;
  final bool nearGoal;
  final double pop;
  final double wobblePhase;

  @override
  Widget build(BuildContext context) {
    final popScale = unlocked
        ? (1.0 + 0.15 * math.sin(pop * math.pi)).clamp(1.0, 1.15)
        : 1.0;

    final amp = nearGoal && isCurrent ? 0.16 : 0.08;
    final wobbleAngle =
        isCurrent ? math.sin(wobblePhase * math.pi * 2) * amp : 0.0;
    final wobbleScale = isCurrent
        ? 1.0 + (nearGoal ? 0.08 : 0.04) * math.sin(wobblePhase * math.pi * 2)
        : 1.0;

    final scale = popScale * wobbleScale * (isCurrent ? 1.08 : 1.0);

    return Transform.rotate(
      angle: wobbleAngle,
      child: Transform.scale(
        scale: scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: size,
          height: size,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: unlocked ? AppColors.white : const Color(0xFFF5F0EA),
            border: Border.all(
              color: unlocked
                  ? (isGoal ? AppColors.primaryPink : AppColors.orange)
                  : AppColors.progressTrack,
              width: unlocked ? 2 : 1.3,
            ),
            boxShadow: unlocked
                ? [
                    BoxShadow(
                      color: (isGoal ? AppColors.primaryPink : AppColors.orange)
                          .withOpacity(isCurrent ? 0.4 : 0.22),
                      blurRadius: isCurrent ? 8 : 5,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Opacity(
            opacity: unlocked ? 1 : 0.35,
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ),
        ),
      ),
    );
  }
}

class _SprinklePainter extends CustomPainter {
  _SprinklePainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final colors = [
      AppColors.primaryPink,
      AppColors.orange,
      const Color(0xFFFFC107),
      const Color(0xFF7C4DFF),
    ];

    for (var i = 0; i < 18; i++) {
      final seedX = 0.18 + ((i * 37) % 100) / 100 * 0.64;
      final seedY = 0.25 + ((i * 53) % 100) / 100 * 0.45;
      final angle = (i * 0.73) % (math.pi * 2);
      final dist = 14.0 + (i % 5) * 8.0;
      final t = Curves.easeOut.transform(progress.clamp(0.0, 1.0));
      final x = size.width * seedX + math.cos(angle) * dist * t;
      final y = size.height * seedY + math.sin(angle) * dist * t - 18 * t;
      final opacity = (1.0 - progress).clamp(0.0, 1.0);
      paint.color = colors[i % colors.length].withOpacity(opacity * 0.85);
      final w = 3.0 + (i % 3);
      const h = 1.5;
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: w, height: h),
          const Radius.circular(1),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _SprinklePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
