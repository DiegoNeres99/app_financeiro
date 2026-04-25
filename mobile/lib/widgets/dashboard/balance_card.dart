import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../models/financial_models.dart';
import '../../utils/formatters.dart';

class BalanceCard extends StatelessWidget {
  final DashboardSummary summary;

  const BalanceCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final balance = summary.incomeTotal - summary.expensesTotal;
    final isPositive = balance >= 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Saldo do Mês', style: TextStyle(color: Colors.white70, fontSize: 13, fontFamily: 'Poppins')),
          const SizedBox(height: 8),
          Text(
            AppFormatters.currency(balance),
            style: TextStyle(
              color: isPositive ? Colors.white : Colors.red[200],
              fontSize: 28,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _balanceItem(Icons.trending_up, 'Renda', summary.incomeTotal, AppColors.income),
              const SizedBox(width: 24),
              _balanceItem(Icons.trending_down, 'Despesas', summary.expensesTotal, Colors.red[300]!),
            ],
          ),
        ],
      ),
    );
  }

  Widget _balanceItem(IconData icon, String label, double value, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11, fontFamily: 'Poppins')),
            Text(
              AppFormatters.currency(value),
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
            ),
          ],
        ),
      ],
    );
  }
}
