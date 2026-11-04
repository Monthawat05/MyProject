import '../theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'itinerary_result_screen.dart';
import '../models/trip_dates.dart';

class TripInputScreen extends StatefulWidget {
  const TripInputScreen({super.key});
  @override
  State<TripInputScreen> createState() => _TripInputScreenState();
}

class _TripInputScreenState extends State<TripInputScreen> {
  static const _blue = Color(0xFF2196F3);
  final _originController = TextEditingController();
  final _destinationController = TextEditingController();
  final _budgetController = TextEditingController();
  int _days = 3;
  int _travelers = 1;
  DateTime? _startDate;
  final List<String> _selectedStyles = [];
  static const _styles = [
    'ธรรมชาติ',
    'ชายหาด',
    'วัฒนธรรม',
    'ผจญภัย',
    'ช้อปปิ้ง',
    'อาหาร',
    'พักผ่อน',
  ];

  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate != null && !_startDate!.isBefore(today)
          ? _startDate!
          : today,
      firstDate: today,
      lastDate: DateTime(today.year + 5, 12, 31),
      helpText: 'เลือกวันเริ่มเดินทาง',
      cancelText: 'ยกเลิก',
      confirmText: 'เลือกวันที่',
    );
    if (picked != null && mounted) setState(() => _startDate = picked);
  }

  void _submit() {
    String? error;
    if (_originController.text.trim().isEmpty) {
      error = 'กรุณากรอกจุดเริ่มต้น';
    } else if (_destinationController.text.trim().isEmpty) {
      error = 'กรุณากรอกจุดหมายปลายทาง';
    } else if (_startDate == null ||
        _startDate!.isBefore(DateUtils.dateOnly(DateTime.now()))) {
      error = 'กรุณาเลือกวันเดินทางตั้งแต่วันนี้เป็นต้นไป';
    }
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ItineraryResultScreen(
          origin: _originController.text.trim(),
          destination: _destinationController.text.trim(),
          days: _days,
          travelers: _travelers,
          startDate: _startDate,
          budget: _budgetController.text.trim().isEmpty
              ? 'ไม่ระบุ'
              : _budgetController.text.trim(),
          styles: List.of(_selectedStyles),
        ),
      ),
    );
  }

  Widget _card(Widget child) => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 20),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppTheme.surface,
      border: Border.all(color: AppTheme.border),
      borderRadius: BorderRadius.circular(28),
      boxShadow: const [
        BoxShadow(
          color: Color(0x100F345C),
          blurRadius: 16,
          offset: Offset(0, 5),
        ),
      ],
    ),
    child: Material(color: Colors.transparent, child: child),
  );

  Widget _label(String text, [IconData? icon]) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 16, color: AppTheme.muted),
          const SizedBox(width: 6),
        ],
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppTheme.muted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );

  InputDecoration _decoration(
    String hint,
    Widget icon, {
    bool highlighted = false,
  }) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: AppTheme.muted, fontSize: 14),
    filled: true,
    fillColor: AppTheme.field,
    prefixIcon: icon,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(
        color: highlighted ? _blue : AppTheme.border,
        width: 1.5,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: _blue, width: 2),
    ),
  );

  Widget _counter(
    String title,
    IconData icon,
    int value,
    int max,
    ValueChanged<int> update,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _label(title, icon),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _stepButton(title, false, value > 1 ? () => update(value - 1) : null),
          Flexible(
            child: Text(
              '$value',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppTheme.accent,
              ),
            ),
          ),
          _stepButton(
            title,
            true,
            value < max ? () => update(value + 1) : null,
          ),
        ],
      ),
    ],
  );

  Widget _stepButton(String title, bool add, VoidCallback? onPressed) =>
      SizedBox(
        width: 44,
        height: 48,
        child: IconButton(
          tooltip: '${add ? 'เพิ่ม' : 'ลด'}$title',
          onPressed: onPressed,
          style: IconButton.styleFrom(
            backgroundColor: add ? _blue : const Color(0xFF203F59),
            foregroundColor: add ? Colors.white : _blue,
            disabledBackgroundColor: AppTheme.field,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          icon: Icon(add ? Icons.add : Icons.remove),
        ),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.background,
    appBar: AppBar(
      toolbarHeight: 96,
      foregroundColor: Colors.white,
      backgroundColor: _blue,
      elevation: 0,
      leadingWidth: 68,
      leading: Center(
        child: IconButton(
          tooltip: 'ย้อนกลับ',
          onPressed: () => Navigator.maybePop(context),
          style: IconButton.styleFrom(backgroundColor: const Color(0x30FFFFFF)),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      titleSpacing: 0,
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'วางแผนทริปใหม่',
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text(
            'บอก AI ให้รู้จักทริปของคุณ',
            style: TextStyle(fontSize: 14, color: Color(0xFFD5EDFF)),
          ),
        ],
      ),
      flexibleSpace: const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.surface, AppTheme.background],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    ),
    body: SafeArea(
      top: false,
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              children: [
                _card(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('จุดเริ่มต้น'),
                      TextField(
                        controller: _originController,
                        textInputAction: TextInputAction.next,
                        decoration: _decoration(
                          'เช่น กรุงเทพฯ, สนามบินดอนเมือง',
                          const Icon(Icons.trip_origin, color: _blue),
                        ),
                      ),
                      const SizedBox(height: 18),
                      _label('จุดหมายปลายทาง'),
                      TextField(
                        controller: _destinationController,
                        textInputAction: TextInputAction.next,
                        decoration: _decoration(
                          'เช่น ภูเก็ต, เชียงใหม่, ญี่ปุ่น...',
                          const Icon(Icons.location_on, color: _blue),
                          highlighted: true,
                        ),
                      ),
                    ],
                  ),
                ),
                _card(
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final days = _counter(
                        'จำนวนวัน',
                        Icons.calendar_month,
                        _days,
                        30,
                        (v) => setState(() => _days = v),
                      );
                      final travelers = _counter(
                        'จำนวนคน',
                        Icons.people_alt_outlined,
                        _travelers,
                        20,
                        (v) => setState(() => _travelers = v),
                      );
                      if (constraints.maxWidth < 270 ||
                          MediaQuery.textScalerOf(context).scale(14) > 20) {
                        return Column(
                          children: [
                            days,
                            const Divider(height: 32),
                            travelers,
                          ],
                        );
                      }
                      return Row(
                        children: [
                          Expanded(child: days),
                          Container(
                            width: 1,
                            height: 74,
                            margin: const EdgeInsets.symmetric(horizontal: 14),
                            color: AppTheme.border,
                          ),
                          Expanded(child: travelers),
                        ],
                      );
                    },
                  ),
                ),
                _card(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('วันเริ่มเดินทาง', Icons.event_outlined),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          _startDate == null
                              ? 'เลือกวันเดินทาง'
                              : formatTripDate(_startDate!),
                          style: const TextStyle(
                            color: _blue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: _startDate == null
                            ? null
                            : Text(tripDateRange(_startDate!, _days)),
                        trailing: const Icon(Icons.expand_more, color: _blue),
                        onTap: _pickDate,
                      ),
                    ],
                  ),
                ),
                _card(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label(
                        'งบรวมทั้งกลุ่มตลอดทริป (บาท)',
                        Icons.account_balance_wallet_outlined,
                      ),
                      TextField(
                        controller: _budgetController,
                        keyboardType: TextInputType.number,
                        decoration: _decoration(
                          'เช่น 15000',
                          const Padding(
                            padding: EdgeInsets.all(14),
                            child: Text(
                              '฿',
                              style: TextStyle(
                                color: Color(0xFF70E6B0),
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _card(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('สไตล์ทริป'),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: _styles.map((style) {
                          final selected = _selectedStyles.contains(style);
                          return FilterChip(
                            label: Text(style),
                            selected: selected,
                            showCheckmark: false,
                            selectedColor: _blue,
                            backgroundColor: AppTheme.field,
                            labelStyle: TextStyle(
                              color: selected ? Colors.white : AppTheme.accent,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            side: BorderSide(
                              color: selected ? _blue : AppTheme.border,
                              width: 1.5,
                            ),
                            onSelected: (value) => setState(() {
                              value
                                  ? _selectedStyles.add(style)
                                  : _selectedStyles.remove(style);
                            }),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'เลือกได้มากกว่า 1 สไตล์',
                        style: TextStyle(fontSize: 12, color: AppTheme.muted),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: _blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text(
                      'สร้างแผนทริปด้วย AI',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
