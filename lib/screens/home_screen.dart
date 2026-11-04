import '../theme/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../data/featured_trips.dart';
import '../services/featured_trip_service.dart';
import '../widgets/trip_preview_card.dart';
import 'my_trips_screen.dart';
import 'trip_input_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;
  String _query = '';
  final _search = TextEditingController();
  late final _featuredStream = FeaturedTripService.watch();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _plan() => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const TripInputScreen()),
  );

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ออกจากระบบไม่สำเร็จ กรุณาลองอีกครั้ง')),
        );
      }
    }
  }

  Widget _profile() {
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName?.trim();
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'พื้นที่ของคุณ',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                const Text(
                  'ทุกการเดินทาง เริ่มต้นจากความเป็นคุณ',
                  style: TextStyle(color: AppTheme.muted),
                ),
                const SizedBox(height: 26),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(26),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1A3D58), AppTheme.surface],
                    ),
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.accent),
                        ),
                        child: const CircleAvatar(
                          radius: 36,
                          backgroundColor: Color(0xFF20475F),
                          child: Icon(
                            Icons.person_rounded,
                            color: AppTheme.accent,
                            size: 40,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        name != null && name.isNotEmpty ? name : 'นักเดินทาง',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        user?.email ?? '',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppTheme.muted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  margin: EdgeInsets.zero,
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        leading: const Icon(
                          Icons.bookmarks_outlined,
                          color: AppTheme.accent,
                        ),
                        title: const Text('ทริปฉัน'),
                        subtitle: const Text('เปิดดูแผนที่บันทึกไว้'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => setState(() => _tab = 1),
                      ),
                      const Divider(height: 1, indent: 20, endIndent: 20),
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        leading: const Icon(
                          Icons.auto_awesome,
                          color: Color(0xFFBBA8FF),
                        ),
                        title: const Text('ออกแบบทริปใหม่'),
                        subtitle: const Text('ให้ AI ช่วยวางแผนการเดินทาง'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: _plan,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout),
                    label: const Text('ออกจากระบบ'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _home(List<FeaturedTrip> catalog, {bool failed = false}) {
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName?.trim();
    final visible = catalog
        .where(
          (item) => ('${item.trip.destination} ${item.trip.styles.join(' ')}')
              .toLowerCase()
              .contains(_query.toLowerCase()),
        )
        .toList();
    return CustomScrollView(
      key: const PageStorageKey('home-feed'),
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF193B58), Color(0xFF101C33)],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 26),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'สวัสดี 👋',
                                style: TextStyle(
                                  color: Color(0xFFDCF0FF),
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                name != null && name.isNotEmpty
                                    ? name
                                    : 'นักเดินทาง',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppTheme.text,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'ทริปฉัน',
                          onPressed: () => setState(() => _tab = 1),
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0x30FFFFFF),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.all(14),
                          ),
                          icon: const Icon(Icons.luggage_outlined),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _search,
                      onChanged: (value) =>
                          setState(() => _query = value.trim()),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'ค้นหาทริปแนะนำ...',
                        hintStyle: const TextStyle(color: Color(0xFFE1F2FF)),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: AppTheme.text,
                        ),
                        suffixIcon: _query.isEmpty
                            ? null
                            : IconButton(
                                tooltip: 'ล้างคำค้น',
                                icon: const Icon(
                                  Icons.close,
                                  color: AppTheme.text,
                                ),
                                onPressed: () {
                                  _search.clear();
                                  setState(() => _query = '');
                                },
                              ),
                        filled: true,
                        fillColor: AppTheme.field,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: AppTheme.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(
                            color: AppTheme.text,
                            width: 2,
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
        SliverPadding(
          padding: const EdgeInsets.all(22),
          sliver: SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF167AD2), Color(0xFF38A9F5)],
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x302196F3),
                            blurRadius: 14,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: _plan,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 19,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.auto_awesome, color: Colors.white),
                                SizedBox(width: 10),
                                Flexible(
                                  child: Text(
                                    'วางแผนทริปใหม่ด้วย AI',
                                    style: TextStyle(
                                      color: AppTheme.text,
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 26),
                    const Text(
                      'ทริปแนะนำ',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.text,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'แผนตัวอย่าง เปิดอ่านได้เลย ไม่ต้องรอ AI',
                      style: TextStyle(fontSize: 13, color: AppTheme.muted),
                    ),
                    const SizedBox(height: 18),
                    if (failed)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: Text(
                          'โหลดข้อมูลล่าสุดไม่สำเร็จ กำลังแสดงแผนที่มีอยู่',
                          style: TextStyle(color: AppTheme.muted),
                        ),
                      ),
                    if (visible.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Text(
                            'ไม่พบทริปแนะนำ ลองค้นหาเมืองหรือสไตล์อื่น',
                          ),
                        ),
                      ),
                    for (final item in visible)
                      TripPreviewCard(
                        trip: item.trip,
                        imageQuery: item.imageQuery,
                        subtitle: item.tagline,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SavedItineraryView(
                              trip: item.trip,
                              readOnly: true,
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
      ],
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.background,
    body: IndexedStack(
      index: _tab,
      children: [
        StreamBuilder<List<FeaturedTrip>>(
          stream: _featuredStream,
          builder: (context, snapshot) {
            if (!snapshot.hasData && !snapshot.hasError) {
              return const Center(child: CircularProgressIndicator());
            }
            return _home(
              snapshot.data ?? featuredTrips,
              failed: snapshot.hasError,
            );
          },
        ),
        const MyTripsScreen(),
        const SizedBox.shrink(),
        _profile(),
      ],
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: _tab,
      backgroundColor: AppTheme.surface,
      indicatorColor: const Color(0xFF20475F),
      onDestinationSelected: (index) {
        if (index == 2) {
          _plan();
        } else {
          setState(() => _tab = index);
        }
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home, color: AppTheme.accent),
          label: 'หน้าหลัก',
        ),
        NavigationDestination(
          icon: Icon(Icons.map_outlined),
          selectedIcon: Icon(Icons.map, color: AppTheme.accent),
          label: 'ทริปฉัน',
        ),
        NavigationDestination(
          icon: Icon(Icons.flight_takeoff),
          label: 'วางแผน',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person, color: AppTheme.accent),
          label: 'โปรไฟล์',
        ),
      ],
    ),
  );
}
