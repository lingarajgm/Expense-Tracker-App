// lib/features/expense/presentation/pages/export_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';
import 'package:expense/features/expense/data/export_service.dart';
import 'package:expense/features/expense/domain/model/expense.dart';

class ExportScreen extends StatefulWidget {
  final List<Expense> expenses;

  const ExportScreen({super.key, required this.expenses});

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  final _exportService = ExportService();
  DateTime _from = DateTime.now().subtract(const Duration(days: 30));
  DateTime _to = DateTime.now();
  bool _loading = false;
  String? _exportedPath;

  final _dateFormat = DateFormat('dd MMM yyyy');

  // Quick range presets
  void _setRange(String preset) {
    final now = DateTime.now();
    setState(() {
      _exportedPath = null;
      switch (preset) {
        case 'this_month':
          _from = DateTime(now.year, now.month, 1);
          _to = now;
          break;
        case 'last_month':
          _from = DateTime(now.year, now.month - 1, 1);
          _to = DateTime(now.year, now.month, 0);
          break;
        case 'last_30':
          _from = now.subtract(const Duration(days: 30));
          _to = now;
          break;
        case 'last_90':
          _from = now.subtract(const Duration(days: 90));
          _to = now;
          break;
        case 'this_year':
          _from = DateTime(now.year, 1, 1);
          _to = now;
          break;
        case 'all':
          if (widget.expenses.isNotEmpty) {
            final sorted = [...widget.expenses]
              ..sort((a, b) => a.date.compareTo(b.date));
            _from = sorted.first.date;
            _to = now;
          }
          break;
      }
    });
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isFrom ? _from : _to,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _exportedPath = null;
        if (isFrom) {
          _from = picked;
          if (_from.isAfter(_to)) _to = _from;
        } else {
          _to = picked;
          if (_to.isBefore(_from)) _from = _to;
        }
      });
    }
  }

  int get _filteredCount => widget.expenses
      .where((e) =>
          e.date.isAfter(_from.subtract(const Duration(days: 1))) &&
          e.date.isBefore(_to.add(const Duration(days: 1))))
      .length;

  Future<void> _generatePDF() async {
    setState(() => _loading = true);
    try {
      final path = await _exportService.generatePDF(
        expenses: widget.expenses,
        from: _from,
        to: _to,
      );
      setState(() {
        _exportedPath = path;
        _loading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ PDF generated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _openFile() async {
    if (_exportedPath == null) return;
    await OpenFilex.open(_exportedPath!);
  }

  Future<void> _shareFile() async {
    if (_exportedPath == null) return;
    await Share.shareXFiles(
      [XFile(_exportedPath!)],
      subject: 'Expense Report',
      text:
          'Expense report from ${_dateFormat.format(_from)} to ${_dateFormat.format(_to)}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Export Expenses')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Quick presets ──
            const Text('Quick Range',
                style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _presetChip('This Month', 'this_month'),
                _presetChip('Last Month', 'last_month'),
                _presetChip('Last 30 Days', 'last_30'),
                _presetChip('Last 90 Days', 'last_90'),
                _presetChip('This Year', 'this_year'),
                _presetChip('All Time', 'all'),
              ],
            ),
            const SizedBox(height: 24),

            // ── Custom date range ──
            const Text('Custom Range',
                style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _dateTile(
                    label: 'From',
                    date: _from,
                    onTap: () => _pickDate(isFrom: true),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(Icons.arrow_forward,
                      color: Colors.deepPurple),
                ),
                Expanded(
                  child: _dateTile(
                    label: 'To',
                    date: _to,
                    onTap: () => _pickDate(isFrom: false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Transaction count ──
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.receipt_long,
                      color: Colors.deepPurple, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '$_filteredCount expense${_filteredCount == 1 ? '' : 's'} in selected range',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.deepPurple),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Generate button ──
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _filteredCount == 0 || _loading
                    ? null
                    : _generatePDF,
                icon: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.picture_as_pdf),
                label: Text(
                    _loading ? 'Generating...' : 'Generate PDF Report'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  disabledBackgroundColor: Colors.grey.shade300,
                ),
              ),
            ),

            // ── Download/Share buttons (after generation) ──
            if (_exportedPath != null) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _openFile,
                      icon: const Icon(Icons.download),
                      label: const Text('Open / Save'),
                      style: OutlinedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: 13),
                        foregroundColor: Colors.deepPurple,
                        side: const BorderSide(color: Colors.deepPurple),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _shareFile,
                      icon: const Icon(Icons.share),
                      label: const Text('Share'),
                      style: ElevatedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: 13),
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  '📄 PDF ready to open or share!',
                  style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _presetChip(String label, String preset) {
    return ActionChip(
      label: Text(label),
      onPressed: () => _setRange(preset),
      backgroundColor: Colors.deepPurple.withOpacity(0.1),
      labelStyle: const TextStyle(color: Colors.deepPurple),
      side: const BorderSide(color: Colors.deepPurple, width: 0.5),
    );
  }

  Widget _dateTile({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.deepPurple.withOpacity(0.4)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 11, color: Colors.grey)),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today,
                    size: 14, color: Colors.deepPurple),
                const SizedBox(width: 6),
                Text(
                  _dateFormat.format(date),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}