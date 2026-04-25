import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

class MonthYearSelector extends StatelessWidget {
  final int month;
  final int year;
  final void Function(int month, int year) onChanged;

  const MonthYearSelector({
    super.key,
    required this.month,
    required this.year,
    required this.onChanged,
  });

  static const _months = [
    'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
    'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
  ];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPicker(context),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${_months[month - 1]} $year',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontFamily: 'Poppins',
            ),
          ),
          const Icon(Icons.arrow_drop_down, color: Colors.white70, size: 16),
        ],
      ),
    );
  }

  void _showPicker(BuildContext context) {
    int tempMonth = month;
    int tempYear = year;

    showModalBottomSheet(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Selecionar Período', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Poppins')),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () => setSheetState(() {
                      if (tempYear > 2020) {
                        if (tempMonth == 1) { tempMonth = 12; tempYear--; }
                        else tempMonth--;
                      }
                    }),
                  ),
                  Text(
                    '${_months[tempMonth - 1]} $tempYear',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () => setSheetState(() {
                      if (tempMonth == 12) { tempMonth = 1; tempYear++; }
                      else tempMonth++;
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    onChanged(tempMonth, tempYear);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  child: const Text('Confirmar', style: TextStyle(color: Colors.white, fontFamily: 'Poppins')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
