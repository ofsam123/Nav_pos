import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Animated brand spinner: a sweeping gradient arc with a glowing head and a
/// slimmer counter-rotating inner arc (inner arc only when there is room).
class AppLoader extends StatefulWidget {
  const AppLoader({
    super.key,
    this.size = 44,
    this.strokeWidth,
    this.color,
  });

  final double size;
  final double? strokeWidth;

  /// Single colour override, e.g. white inside a filled button.
  final Color? color;

  @override
  State<AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<AppLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: widget.size,
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => CustomPaint(
            painter: _LoaderPainter(
              progress: _controller.value,
              head: widget.color ?? AppColors.primary,
              tail: widget.color ?? AppColors.primaryLight,
              strokeWidth: widget.strokeWidth,
            ),
          ),
        ),
      ),
    );
  }
}

class _LoaderPainter extends CustomPainter {
  _LoaderPainter({
    required this.progress,
    required this.head,
    required this.tail,
    this.strokeWidth,
  });

  final double progress;
  final Color head;
  final Color tail;
  final double? strokeWidth;

  static const _twoPi = math.pi * 2;

  @override
  void paint(Canvas canvas, Size size) {
    final side = size.shortestSide;
    final stroke = strokeWidth ?? math.max(2.0, side / 11);
    final center = size.center(Offset.zero);
    final radius = (side - stroke) / 2;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = head.withValues(alpha: 0.10),
    );

    final breathe = 0.5 - 0.5 * math.cos(_twoPi * progress);
    final sweep = (0.22 + 0.58 * breathe) * _twoPi;
    final start = _twoPi * progress * 1.5 - math.pi / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawArc(
      rect,
      start,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          colors: [tail.withValues(alpha: 0), tail, head],
          stops: const [0, 0.55, 1],
          endAngle: sweep,
          transform: GradientRotation(start),
        ).createShader(rect),
    );

    final headAngle = start + sweep;
    final headPoint =
        center + Offset(math.cos(headAngle), math.sin(headAngle)) * radius;
    canvas.drawCircle(
      headPoint,
      stroke * 1.1,
      Paint()
        ..color = head.withValues(alpha: 0.25)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, stroke),
    );
    canvas.drawCircle(headPoint, stroke / 2, Paint()..color = head);

    if (side >= 30) {
      final innerRadius = radius * 0.56;
      final innerStroke = stroke * 0.6;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: innerRadius),
        -_twoPi * progress * 2,
        math.pi * 0.7,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = innerStroke
          ..strokeCap = StrokeCap.round
          ..color = tail.withValues(alpha: 0.45),
      );
    }
  }

  @override
  bool shouldRepaint(_LoaderPainter old) =>
      old.progress != progress ||
      old.head != head ||
      old.tail != tail ||
      old.strokeWidth != strokeWidth;
}

/// Full-area loading placeholder with an optional caption.
class AppLoadingView extends StatelessWidget {
  const AppLoadingView({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppLoader(),
          if (message != null) ...[
            const SizedBox(height: 14),
            Text(
              message!,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Blocking progress dialog: `show(message:)` opens it, `hide()` closes it.
class AppLoadingDialog {
  AppLoadingDialog({required this.context, this.barrierDimisable = false});

  final BuildContext context;
  final bool barrierDimisable;

  bool _isOpen = false;
  int _showId = 0;
  final ValueNotifier<String> _message = ValueNotifier<String>('');

  void show({required String message}) {
    _message.value = message;
    _isOpen = true;
    final id = ++_showId;
    showDialog<void>(
      context: context,
      barrierDismissible: barrierDimisable,
      barrierColor: AppColors.textDark.withValues(alpha: 0.35),
      useSafeArea: true,
      builder: (_) => PopScope(
        canPop: barrierDimisable,
        child: _LoadingCard(message: _message),
      ),
    ).then((_) {
      // Dismissed by tapping outside: a later hide() must not pop the page.
      if (id == _showId) _isOpen = false;
    });
  }

  void hide() {
    if (_isOpen) {
      _isOpen = false;
      Navigator.of(context).pop();
    }
  }

  void updateMessageText(String message) => _message.value = message;
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard({required this.message});

  final ValueListenable<String> message;

  static String _clean(String raw) =>
      raw.trim().replaceAll(RegExp(r'\s*\.{2,}$'), '…');

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.92, end: 1),
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        builder: (context, scale, child) => Opacity(
          opacity: ((scale - 0.92) / 0.08).clamp(0.0, 1.0),
          child: Transform.scale(scale: scale, child: child),
        ),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          elevation: 0,
          child: Container(
            constraints: const BoxConstraints(minWidth: 180, maxWidth: 260),
            padding: const EdgeInsets.fromLTRB(28, 28, 28, 22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: AppColors.textDark.withValues(alpha: 0.12),
                  blurRadius: 30,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AppLoader(size: 54),
                const SizedBox(height: 18),
                ValueListenableBuilder<String>(
                  valueListenable: message,
                  builder: (context, value, _) => Text(
                    _clean(value),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Please wait",
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
