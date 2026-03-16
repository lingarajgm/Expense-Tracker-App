import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:expense/features/expense/domain/model/expense.dart';
import 'package:expense/core/extensions.dart';
import 'package:intl/intl.dart';

class ChartScreen extends StatefulWidget {
  final List<Expense> expenses;

  const ChartScreen({super.key, required this.expenses});

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _touchedIndex = -1;

  // Category colors
  static const List<Color> categoryColors = [
    Color(0xFF6C63FF),
    Color(0xFFFF6584),
    Color(0xFF43E97B),
    Color(0xFFFA8231),
    Color(0xFF00C9FF),
    Color(0xFFFFD700),
    Color(0xFFFF5E57),
    Color(0xFF5F27CD),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── Group by category ──
  Map<String, double> get categoryTotals {
    final Map<String, double> totals = {};
    for (final e in widget.expenses) {
      final cat = e.category.name; // uses enum name as string e.g. "food"
totals[cat] = (totals[cat] ?? 0) + e.amount;
    }
    return Map.fromEntries(
      totals.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
    );
  }

  // ── Group by month (last 6 months) ──
  Map<String, double> get monthlyTotals {
    final Map<String, double> totals = {};
    final now = DateTime.now();

    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i);
      final key = DateFormat('MMM yy').format(month);
      totals[key] = 0;
    }

    for (final e in widget.expenses) {
      final key = DateFormat('MMM yy').format(e.date);
      if (totals.containsKey(key)) {
        totals[key] = (totals[key] ?? 0) + e.amount;
      }
    }
    return totals;
  }

  double get totalAmount =>
      widget.expenses.fold(0.0, (sum, e) => sum + e.amount);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Charts'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.pie_chart), text: 'By Category'),
            Tab(icon: Icon(Icons.bar_chart), text: 'By Month'),
          ],
        ),
      ),
      body: widget.expenses.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bar_chart_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No expenses to display',
                      style: TextStyle(fontSize: 16, color: Colors.grey)),
                ],
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildCategoryTab(),
                _buildMonthlyTab(),
              ],
            ),
    );
  }

  // ════════════════════════════════════════
  // TAB 1 — PIE CHART by Category
  // ════════════════════════════════════════
  Widget _buildCategoryTab() {
    final data = categoryTotals;
    if (data.isEmpty) return const Center(child: Text('No data'));

    final keys = data.keys.toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Total card
          _buildTotalCard(),
          const SizedBox(height: 24),

          // Pie chart
          SizedBox(
            height: 260,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (event, response) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          response == null ||
                          response.touchedSection == null) {
                        _touchedIndex = -1;
                        return;
                      }
                      _touchedIndex =
                          response.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                borderData: FlBorderData(show: false),
                sectionsSpace: 3,
                centerSpaceRadius: 55,
                sections: keys.asMap().entries.map((entry) {
                  final i = entry.key;
                  final key = entry.value;
                  final value = data[key]!;
                  final percent = (value / totalAmount * 100);
                  final isTouched = i == _touchedIndex;

                  return PieChartSectionData(
                    color: categoryColors[i % categoryColors.length],
                    value: value,
                    title: isTouched
                        ? '${percent.toStringAsFixed(1)}%'
                        : percent >= 8
                            ? '${percent.toStringAsFixed(0)}%'
                            : '',
                    radius: isTouched ? 80 : 65,
                    titleStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Legend + amounts
          ...keys.asMap().entries.map((entry) {
            final i = entry.key;
            final key = entry.value;
            final value = data[key]!;
            final percent = (value / totalAmount * 100);
            final color = categoryColors[i % categoryColors.length];

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      key,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Text(
                    '${percent.toStringAsFixed(1)}%',
                    style: TextStyle(color: color, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    value.toCurrency(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ════════════════════════════════════════
  // TAB 2 — BAR CHART by Month
  // ════════════════════════════════════════
  Widget _buildMonthlyTab() {
    final data = monthlyTotals;
    final keys = data.keys.toList();
    final values = data.values.toList();
    final maxVal = values.isEmpty ? 1.0 : values.reduce((a, b) => a > b ? a : b);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildTotalCard(),
          const SizedBox(height: 24),

          // Bar chart
          SizedBox(
            height: 280,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxVal * 1.2,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${keys[groupIndex]}\n',
                        const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                        children: [
                          TextSpan(
                            text: rod.toY.toCurrency(),
                            style: const TextStyle(
                              color: Colors.yellow,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const SizedBox();
                        return Text(
                          '₹${(value / 1000).toStringAsFixed(0)}k',
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= keys.length) return const SizedBox();
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            keys[index],
                            style: const TextStyle(fontSize: 10),
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.withOpacity(0.15),
                    strokeWidth: 1,
                  ),
                ),
                barGroups: keys.asMap().entries.map((entry) {
                  final i = entry.key;
                  final value = values[i];
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: value,
                        gradient: LinearGradient(
                          colors: [
                            categoryColors[i % categoryColors.length],
                            categoryColors[i % categoryColors.length]
                                .withOpacity(0.6),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        width: 28,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Monthly breakdown list
          ...keys.asMap().entries.map((entry) {
            final i = entry.key;
            final key = entry.value;
            final value = values[i];
            final color = categoryColors[i % categoryColors.length];

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withOpacity(0.25)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(key,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  Text(
                    value == 0 ? 'No expenses' : value.toCurrency(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: value == 0 ? Colors.grey : null,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTotalCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF5F27CD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text('Total Expenses',
              style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 6),
          Text(
            totalAmount.toCurrency(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${widget.expenses.length} transactions',
            style: const TextStyle(color: Colors.white60, fontSize: 12),
          ),
        ],
      ),
    );
  }
}