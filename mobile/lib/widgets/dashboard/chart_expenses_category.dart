import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../config/app_theme.dart';
import '../../utils/formatters.dart';

class ChartExpensesCategory extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const ChartExpensesCategory({super.key, required this.data});

  static const _colors = [
    Color(0xFF6366F1), Color(0xFFEC4899), Color(0xFFF59E0B),
    Color(0xFF10B981), Color(0xFF3B82F6), Color(0xFFF97316),
    Color(0xFF8B5CF6), Color(0xFFEF4444),
  ];

  @override
  Widget build(BuildContext context) {
    final total = data.fold<double>(0, (sum, d) => sum + (double.tryParse(d['total'].toString()) ?? 0));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 160,
            child: PieChart(
              PieChartData(
                sections: data.asMap().entries.map((e) {
                  final i = e.key;
                  final d = e.value;
                  final val = double.tryParse(d['total'].toString()) ?? 0;
                  final pct = total > 0 ? (val / total * 100) : 0;
                  return PieChartSectionData(
                    value: val,
                    title: '${pct.toStringAsFixed(0)}%',
                    color: _colors[i % _colors.length],
                    radius: 55,
                    titleStyle: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                  );
                }).toList(),
                sectionsSpace: 2,
                centerSpaceRadius: 36,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: data.asMap().entries.map((e) {
              final i = e.key;
              final d = e.value;
              final val = double.tryParse(d['total'].toString()) ?? 0;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 10, height: 10, decoration: BoxDecoration(color: _colors[i % _colors.length], shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                  Text(
                    '${d['category_name'] ?? 'Outros'} ${AppFormatters.currency(val)}',
                    style: const TextStyle(fontSize: 11, fontFamily: 'Poppins', color: AppColors.textSecondary),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
