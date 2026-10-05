import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../theme/app_theme.dart';
import 'app_loader.dart';

/// Full-screen QR scanner. Pops with the scanned text, or `null` if the user
/// closes it.
class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key});

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage>
    with SingleTickerProviderStateMixin {
  final MobileScannerController _controller = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  late final AnimationController _line = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat(reverse: true);

  bool _handled = false;

  @override
  void dispose() {
    _line.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue?.trim();
      if (value != null && value.isNotEmpty) {
        _handled = true;
        HapticFeedback.mediumImpact();
        Navigator.of(context).pop(value);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final side = math.min(constraints.maxWidth * 0.72, 290.0);
            final window = Rect.fromCenter(
              center: Offset(
                constraints.maxWidth / 2,
                constraints.maxHeight * 0.44,
              ),
              width: side,
              height: side,
            );

            return Stack(
              children: [
                Positioned.fill(
                  child: MobileScanner(
                    controller: _controller,
                    onDetect: _onDetect,
                    placeholderBuilder: (_) => const ColoredBox(
                      color: Colors.black,
                      child: Center(
                        child: AppLoader(color: Colors.white),
                      ),
                    ),
                    errorBuilder: (_, error) => _ScannerError(
                      error: error,
                      onRetry: () => _controller.start(),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(painter: _FramePainter(window)),
                  ),
                ),
                AnimatedBuilder(
                  animation: _line,
                  builder: (context, _) {
                    final t = Curves.easeInOut.transform(_line.value);
                    return Positioned(
                      left: window.left + 14,
                      width: window.width - 28,
                      top: window.top + 12 + t * (window.height - 24),
                      child: const IgnorePointer(child: _ScanLine()),
                    );
                  },
                ),
                Positioned(
                  left: 24,
                  right: 24,
                  top: window.bottom + 28,
                  child: const Text(
                    "Point the camera at the customer's QR code",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.5,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                    child: Row(
                      children: [
                        _RoundButton(
                          icon: Icons.close_rounded,
                          tooltip: "Close",
                          onTap: () => Navigator.of(context).pop(),
                        ),
                        const Expanded(
                          child: Text(
                            "Scan QR code",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        ValueListenableBuilder<MobileScannerState>(
                          valueListenable: _controller,
                          builder: (context, state, _) {
                            final torch = state.torchState;
                            if (!state.isRunning ||
                                torch == TorchState.unavailable) {
                              return const SizedBox(width: 44);
                            }
                            final on = torch == TorchState.on;
                            return _RoundButton(
                              icon: on
                                  ? Icons.flash_on_rounded
                                  : Icons.flash_off_rounded,
                              tooltip: on ? "Turn off light" : "Turn on light",
                              active: on,
                              onTap: () => _controller.toggleTorch(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: active ? Colors.white : Colors.white.withValues(alpha: 0.16),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(
              icon,
              color: active ? AppColors.textDark : Colors.white,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}

class _ScanLine extends StatelessWidget {
  const _ScanLine();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 3,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        gradient: LinearGradient(
          colors: [
            AppColors.primaryLight.withValues(alpha: 0),
            AppColors.primaryLight,
            AppColors.primaryLight.withValues(alpha: 0),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryLight.withValues(alpha: 0.6),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}

class _FramePainter extends CustomPainter {
  _FramePainter(this.window);

  final Rect window;

  static const _radius = 24.0;
  static const _corner = 34.0;

  @override
  void paint(Canvas canvas, Size size) {
    final frame = RRect.fromRectAndRadius(window, const Radius.circular(_radius));

    canvas.drawPath(
      Path()
        ..fillType = PathFillType.evenOdd
        ..addRect(Offset.zero & size)
        ..addRRect(frame),
      Paint()..color = Colors.black.withValues(alpha: 0.58),
    );

    final stroke = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final l = window.left, t = window.top, r = window.right, b = window.bottom;
    const c = _corner, rad = _radius;

    canvas.drawPath(
      Path()
        ..moveTo(l, t + c)
        ..lineTo(l, t + rad)
        ..arcToPoint(Offset(l + rad, t), radius: const Radius.circular(rad))
        ..lineTo(l + c, t)
        ..moveTo(r - c, t)
        ..lineTo(r - rad, t)
        ..arcToPoint(Offset(r, t + rad), radius: const Radius.circular(rad))
        ..lineTo(r, t + c)
        ..moveTo(r, b - c)
        ..lineTo(r, b - rad)
        ..arcToPoint(Offset(r - rad, b), radius: const Radius.circular(rad))
        ..lineTo(r - c, b)
        ..moveTo(l + c, b)
        ..lineTo(l + rad, b)
        ..arcToPoint(Offset(l, b - rad), radius: const Radius.circular(rad))
        ..lineTo(l, b - c),
      stroke,
    );
  }

  @override
  bool shouldRepaint(_FramePainter oldDelegate) => oldDelegate.window != window;
}

class _ScannerError extends StatelessWidget {
  const _ScannerError({required this.error, required this.onRetry});

  final MobileScannerException error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final denied = error.errorCode == MobileScannerErrorCode.permissionDenied;
    final unsupported = error.errorCode == MobileScannerErrorCode.unsupported;

    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                denied
                    ? Icons.no_photography_outlined
                    : Icons.videocam_off_outlined,
                color: Colors.white,
                size: 56,
              ),
              const SizedBox(height: 18),
              Text(
                denied
                    ? "Camera access is off"
                    : unsupported
                        ? "Scanning isn't supported on this device"
                        : "The camera couldn't start",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                denied
                    ? "Allow camera access for Nav POS in your phone's settings, then try again."
                    : "Close any other app using the camera, then try again.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
              if (!unsupported) ...[
                const SizedBox(height: 22),
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text("Try again"),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
