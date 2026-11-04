import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TripLoadingView extends StatefulWidget {
  final String destination;
  final int days;
  final bool locatingPlaces;
  const TripLoadingView({
    super.key,
    required this.destination,
    required this.days,
    required this.locatingPlaces,
  });
  @override
  State<TripLoadingView> createState() => _TripLoadingViewState();
}

class _TripLoadingViewState extends State<TripLoadingView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _orbit = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 8),
  );
  Timer? _timer;
  bool _slow = false;
  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 45), () {
      if (mounted) setState(() => _slow = true);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _orbit.stop();
    } else {
      _orbit.repeat();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _orbit.dispose();
    super.dispose();
  }

  Widget _step(
    String title,
    IconData icon, {
    bool done = false,
    bool active = false,
  }) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: active ? const Color(0xFF204A60) : AppTheme.field,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            done ? Icons.check_rounded : icon,
            size: 17,
            color: done || active ? AppTheme.accent : AppTheme.muted,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: active ? AppTheme.text : AppTheme.muted,
              fontSize: 13,
              fontWeight: active ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ),
        if (active) ...[
          const SizedBox(width: 10),
          if (!MediaQuery.disableAnimationsOf(context))
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            const Icon(Icons.more_horiz, size: 18, color: AppTheme.accent),
        ],
      ],
    ),
  );

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    height: double.infinity,
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomRight,
        colors: [AppTheme.background, Color(0xFF0C1C33), Color(0xFF112B40)],
      ),
    ),
    child: SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 30),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF173345),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: const Color(0xFF295A68)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        size: 13,
                        color: AppTheme.accent,
                      ),
                      SizedBox(width: 7),
                      Flexible(
                        child: Text(
                          'TRIPAI IS PLANNING',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppTheme.accent,
                            fontSize: 10,
                            letterSpacing: 1.7,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'ทริปใหม่ของคุณ\nกำลังเป็นรูปเป็นร่าง',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.text,
                    fontSize: 27,
                    fontWeight: FontWeight.w800,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${widget.destination}  ·  ${widget.days} วัน',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppTheme.muted, fontSize: 15),
                ),
                const SizedBox(height: 8),
                ExcludeSemantics(
                  child: SizedBox(
                    height: 195,
                    width: double.infinity,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned.fill(
                          child: RepaintBoundary(
                            child: AnimatedBuilder(
                              animation: _orbit,
                              builder: (_, child) => CustomPaint(
                                painter: _PlanningOrbit(_orbit.value),
                              ),
                            ),
                          ),
                        ),
                        Transform.rotate(
                          angle: -0.1,
                          child: Container(
                            width: 78,
                            height: 78,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF6CEAE3),
                                  Color(0xFF218EED),
                                  Color(0xFF7164E9),
                                ],
                              ),
                              border: Border.all(
                                color: const Color(0xFF9CDFFF),
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x502196F3),
                                  blurRadius: 36,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.flight_takeoff_rounded,
                              size: 37,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Semantics(
                  liveRegion: true,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(19, 19, 19, 10),
                    decoration: BoxDecoration(
                      color: const Color(0xD914243B),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.locatingPlaces
                              ? 'กำลังเตรียมแผนที่'
                              : 'กำลังออกแบบการเดินทาง',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.text,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          _slow && !widget.locatingPlaces
                              ? 'ยังรอคำตอบจาก AI อยู่ ใช้เวลานานกว่าปกติเล็กน้อย'
                              : 'จัดที่เที่ยว ที่พัก และเส้นทางให้เข้ากับทริปของคุณ',
                          style: const TextStyle(
                            fontSize: 12,
                            height: 1.6,
                            color: AppTheme.muted,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 12, bottom: 3),
                          child: Divider(height: 1),
                        ),
                        _step('รับข้อมูลทริปแล้ว', Icons.check, done: true),
                        _step(
                          'วางแผนเที่ยวและแนะนำที่พัก',
                          Icons.auto_awesome_outlined,
                          done: widget.locatingPlaces,
                          active: !widget.locatingPlaces,
                        ),
                        _step(
                          'จับคู่สถานที่บนแผนที่',
                          Icons.location_on_outlined,
                          active: widget.locatingPlaces,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.tune_rounded, size: 15, color: AppTheme.accent),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'แผนนี้ปรับแก้ได้ ก่อนบันทึกเป็นทริปของคุณ',
                        style: TextStyle(color: AppTheme.muted, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _PlanningOrbit extends CustomPainter {
  final double phase;
  const _PlanningOrbit(this.phase);
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width * 0.38, size.height * 0.44);
    final paint = Paint();
    canvas.drawCircle(
      center,
      radius * 1.3,
      paint
        ..shader = const RadialGradient(
          colors: [Color(0x302196F3), Color(0x002196F3)],
        ).createShader(Rect.fromCircle(center: center, radius: radius * 1.3)),
    );
    paint.shader = null;
    for (final scale in [0.82, 1.15]) {
      final rect = Rect.fromCenter(
        center: center,
        width: radius * 2.4 * scale,
        height: radius * 1.4 * scale,
      );
      paint
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0x443B8DB5);
      canvas.drawOval(rect, paint);
      paint
        ..strokeWidth = 2
        ..color = scale < 1 ? const Color(0xFF8C9EFF) : AppTheme.accent;
      canvas.drawArc(
        rect,
        (scale < 1 ? -phase : phase) * math.pi * 2,
        0.65,
        false,
        paint,
      );
    }
    paint.style = PaintingStyle.fill;
    for (var i = 0; i < 3; i++) {
      final angle = phase * 2 * math.pi + i * 2 * math.pi / 3;
      final point =
          center +
          Offset(
            math.cos(angle) * radius * 1.38,
            math.sin(angle) * radius * 0.805,
          );
      canvas.drawCircle(point, 5, paint..color = const Color(0x2255DFE2));
      canvas.drawCircle(point, 2.5, paint..color = AppTheme.accent);
    }
  }

  @override
  bool shouldRepaint(covariant _PlanningOrbit oldDelegate) =>
      oldDelegate.phase != phase;
}
