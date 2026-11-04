import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});
  static const _ink = Color(0xFFF1F7FF);
  static const _blue = Color(0xFF2196F3);

  Widget _feature(IconData icon, String title, Color color) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 17, color: color),
      const SizedBox(width: 6),
      Flexible(
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: _ink,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
    value: SystemUiOverlayStyle.light,
    child: Scaffold(
      backgroundColor: const Color(0xFF080F22),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF101D38), Color(0xFF080F22), Color(0xFF112745)],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 20),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: (constraints.maxHeight - 40).clamp(
                    0,
                    double.infinity,
                  ),
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: _blue,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.flight_takeoff_rounded,
                                color: Colors.white,
                                size: 23,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'TripAI',
                              style: TextStyle(
                                color: _ink,
                                fontSize: 25,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.8,
                              ),
                            ),
                            const Spacer(),
                            const Flexible(
                              child: Text(
                                'AI TRAVEL PLANNER',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: Color(0xFFA3B7D1),
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        const ExcludeSemantics(child: _TravelIllustration()),
                        const SizedBox(height: 25),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 11,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF183C53),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'TRAVEL BEYOND ORDINARY',
                            style: TextStyle(
                              color: Color(0xFF70E9ED),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.8,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'โลกกว้างแค่ไหน\nก็ไปได้ในแบบคุณ',
                          style: TextStyle(
                            fontSize: 29,
                            height: 1.35,
                            fontWeight: FontWeight.w800,
                            color: _ink,
                            letterSpacing: -0.6,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'เลือกจุดหมาย แล้วให้ AI ช่วยวางแผน\nทั้งที่เที่ยว ที่พัก และการเดินทางในที่เดียว',
                          style: TextStyle(
                            color: Color(0xFFA8BDD6),
                            height: 1.7,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 23),
                        Wrap(
                          spacing: 16,
                          runSpacing: 12,
                          children: [
                            _feature(
                              Icons.auto_awesome_rounded,
                              'AI ช่วยวางแผน',
                              _blue,
                            ),
                            _feature(
                              Icons.tune_rounded,
                              'ปรับได้ตามใจ',
                              const Color(0xFF65DAD1),
                            ),
                            _feature(
                              Icons.bookmark_border_rounded,
                              'บันทึกทริปไว้',
                              const Color(0xFFC3A4FF),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(19),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1475D3), Color(0xFF2AA9FA)],
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x342196F3),
                                blurRadius: 22,
                                offset: Offset(0, 9),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SignupScreen(),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 22,
                                vertical: 19,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(19),
                              ),
                            ),
                            child: const Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'เริ่มต้นใช้งาน',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Icon(Icons.arrow_forward_rounded),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: TextButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                            ),
                            child: const Text.rich(
                              TextSpan(
                                style: TextStyle(
                                  color: Color(0xFFA8BDD6),
                                  fontSize: 13,
                                ),
                                children: [
                                  TextSpan(text: 'มีบัญชีแล้ว?  '),
                                  TextSpan(
                                    text: 'เข้าสู่ระบบ',
                                    style: TextStyle(
                                      color: Color(0xFF70E9ED),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _TravelIllustration extends StatefulWidget {
  const _TravelIllustration();
  @override
  State<_TravelIllustration> createState() => _TravelIllustrationState();
}

class _TravelIllustrationState extends State<_TravelIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _orbit = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 18),
  );
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
    _orbit.dispose();
    super.dispose();
  }

  Widget _tag(IconData icon, String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
    decoration: BoxDecoration(
      color: const Color(0xEE152A43),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFF34516E)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 7),
        Flexible(
          child: Text(
            label,
            style: const TextStyle(color: Color(0xFFDEEBFA), fontSize: 11),
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: 1.35,
    child: Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _orbit,
              builder: (_, child) =>
                  CustomPaint(painter: _OrbitPainter(_orbit.value)),
            ),
          ),
        ),
        Container(
          width: 91,
          height: 91,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF68EBEF), Color(0xFF248BF0), Color(0xFF635EE7)],
            ),
            border: Border.all(color: const Color(0xFF95E8FF)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x552196F3),
                blurRadius: 40,
                spreadRadius: 8,
              ),
            ],
          ),
          child: const Icon(
            Icons.flight_takeoff_rounded,
            size: 44,
            color: Colors.white,
          ),
        ),
        Positioned(
          top: 8,
          left: 0,
          right: 25,
          child: _tag(
            Icons.auto_awesome,
            'AI วางแผนให้คุณ',
            const Color(0xFF76EEE8),
          ),
        ),
        Positioned(
          bottom: 10,
          right: 0,
          left: 25,
          child: _tag(
            Icons.explore_outlined,
            'ทุกจุดหมายเป็นไปได้',
            const Color(0xFFB7A1FF),
          ),
        ),
      ],
    ),
  );
}

class _OrbitPainter extends CustomPainter {
  final double phase;
  const _OrbitPainter(this.phase);
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide * 0.4;
    final paint = Paint();
    canvas.drawCircle(
      center,
      radius * 1.3,
      paint
        ..shader = const RadialGradient(
          colors: [Color(0x402A9CEA), Color(0x00101D38)],
        ).createShader(Rect.fromCircle(center: center, radius: radius * 1.3)),
    );
    paint.shader = null;
    paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (final scale in [0.74, 1.0, 1.22]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: center,
          width: radius * 2 * scale,
          height: radius * 1.55 * scale,
        ),
        paint..color = const Color(0x443AA8D4),
      );
    }
    for (var i = 0; i < 3; i++) {
      final angle = phase * math.pi * 2 + i * math.pi * 2 / 3;
      final point =
          center +
          Offset(math.cos(angle) * radius, math.sin(angle) * radius * 0.775);
      paint.style = PaintingStyle.fill;
      canvas.drawCircle(point, 9, paint..color = const Color(0x225CE6ED));
      canvas.drawCircle(point, 3.5, paint..color = const Color(0xFF80EAF4));
    }
    for (var i = 0; i < 15; i++) {
      final x = ((i * 73 + 17) % 100) / 100 * size.width;
      final y = ((i * 43 + 9) % 100) / 100 * size.height;
      canvas.drawCircle(
        Offset(x, y),
        i % 3 == 0 ? 1.5 : 0.8,
        paint..color = const Color(0x886EA8D4),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _OrbitPainter oldDelegate) =>
      oldDelegate.phase != phase;
}
