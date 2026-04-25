import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../utils/formatters.dart';
import '../../routes/app_routes.dart';

class UpcomingExpensesCard extends StatelessWidget {
  final List<Map<String, dynamic>> expenses;

  const UpcomingExpensesCard({super.key, required this.expenses});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Column(
        children: [
          ...expenses.take(5).map((e) {
            final amount = double.tryParse(e['amount'].toString()) ?? 0;
            final dueDate = e['due_date'] != null ? AppFormatters.dateFromStr(e['due_date'].toString()) : '';
            final status = e['status'] ?? 'pending';
            final color = status == 'overdue' ? AppColors.overdue : AppColors.pending;

            return ListTile(
              leading: CircleAvatar(
                backgroundColor: color.withOpacity(0.1),
                child: Icon(Icons.receipt_outlined, color: color, size: 20),
              ),
              title: Text(
                e['description'] ?? '',
                style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500, fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                'Vence: $dueDate',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: color),
              ),
              trailing: Text(
                AppFormatters.currency(amount),
                style: TextStyle(color: color, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
              ),
            );
          }),
          if (expenses.length > 5)
            TextButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.expenses),
              child: Text('Ver todas (${expenses.length})', style: const TextStyle(fontFamily: 'Poppins', color: AppColors.primary)),
            ),
        ],
      ),
    );
  }
}
