import '../theme/app_theme.dart';
import 'package:flutter/material.dart';
import '../widgets/gradient_app_bar.dart';

class EditItineraryScreen extends StatefulWidget {
  final String initialText;
  final String confirmLabel;
  const EditItineraryScreen({
    super.key,
    required this.initialText,
    this.confirmLabel = 'ใช้แผนที่แก้ไข',
  });

  @override
  State<EditItineraryScreen> createState() => _EditItineraryScreenState();
}

class _EditItineraryScreenState extends State<EditItineraryScreen> {
  late final TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const GradientAppBar(title: 'แก้ไขแผน'),
    backgroundColor: AppTheme.background,
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'ปรับข้อความ เวลา และรายละเอียดกิจกรรมได้ที่นี่\nการแก้ข้อความจะไม่เปลี่ยนหมุดแผนที่และรูปสถานที่',
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Form(
                key: _formKey,
                child: TextFormField(
                  controller: _controller,
                  expands: true,
                  maxLines: null,
                  minLines: null,
                  textAlignVertical: TextAlignVertical.top,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                    labelText: 'รายละเอียดแผนทริป',
                    alignLabelWithHint: true,
                    filled: true,
                    fillColor: AppTheme.field,
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'กรุณากรอกรายละเอียดแผนทริป'
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('ยกเลิก'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        Navigator.pop(context, _controller.text.trim());
                      }
                    },
                    child: Text(widget.confirmLabel),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
