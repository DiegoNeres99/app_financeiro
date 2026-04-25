import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../../config/app_theme.dart';
import '../../models/expense_model.dart';
import '../../services/financial_service.dart';
import '../../routes/app_routes.dart';
import '../../utils/formatters.dart';
import '../../widgets/common/month_year_selector.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final _service = FinancialService();
  List<ExpenseModel> _expenses = [];
  bool _isLoading = true;
  int _month = DateTime.now().month;
  int _year = DateTime.now().year;
  String _statusFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    setState(() => _isLoading = true);
    try {
      final data = await _service.getExpenses(
        month: _month,
        year: _year,
        status: _statusFilter == 'all' ? null : _statusFilter,
      );
      setState(() { _expenses = data; _isLoading = false; });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: AppColors.expense));
    }
  }

  Future<void> _delete(ExpenseModel expense) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir despesa'),
        content: Text('Deseja excluir "${expense.description}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Excluir', style: TextStyle(color: AppColors.expense))),
        ],
      ),
    );
    if (confirm != true) return;
    EasyLoading.show();
    try {
      await _service.deleteExpense(expense.id);
      EasyLoading.dismiss();
      _loadExpenses();
    } catch (e) {
      EasyLoading.dismiss();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: AppColors.expense));
    }
  }

  Future<void> _markAsPaid(ExpenseModel expense) async {
    EasyLoading.show(status: 'Marcando...');
    try {
      await _service.markExpenseAsPaid(expense.id);
      EasyLoading.dismiss();
      _loadExpenses();
    } catch (e) {
      EasyLoading.dismiss();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: AppColors.expense));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Despesas'),
        actions: [
          MonthYearSelector(
            month: _month,
            year: _year,
            onChanged: (m, y) { setState(() { _month = m; _year = y; }); _loadExpenses(); },
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Column(
        children: [
          _buildFilter(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _expenses.isEmpty
                    ? _buildEmpty()
                    : RefreshIndicator(
                        onRefresh: _loadExpenses,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _expenses.length,
                          itemBuilder: (_, i) => _buildItem(_expenses[i]),
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.pushNamed(context, AppRoutes.expenseForm);
          _loadExpenses();
        },
        icon: const Icon(Icons.add),
        label: const Text('Nova Despesa'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildFilter() {
    const statuses = [
      ('all', 'Todas'), ('pending', 'Pendentes'), ('paid', 'Pagas'), ('overdue', 'Atrasadas'),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: statuses.map((s) {
          final selected = _statusFilter == s.$1;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(s.$2),
              selected: selected,
              onSelected: (_) { setState(() => _statusFilter = s.$1); _loadExpenses(); },
              selectedColor: AppColors.primary.withOpacity(0.15),
              checkmarkColor: AppColors.primary,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildItem(ExpenseModel e) {
    return Dismissible(
      key: Key(e.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        color: AppColors.expense,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        await _delete(e);
        return false;
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: e.statusColor.withOpacity(0.15),
            child: Icon(Icons.receipt_outlined, color: e.statusColor, size: 20),
          ),
          title: Text(e.description, style: const TextStyle(fontWeight: FontWeight.w500, fontFamily: 'Poppins'), maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(
            '${e.statusLabel} · Vence: ${AppFormatters.date(e.dueDate)}',
            style: TextStyle(color: e.statusColor, fontSize: 12, fontFamily: 'Poppins'),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(AppFormatters.currency(e.amount), style: TextStyle(color: e.statusColor, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
              if (e.status != 'paid')
                GestureDetector(
                  onTap: () => _markAsPaid(e),
                  child: const Text('Pagar', style: TextStyle(color: AppColors.income, fontSize: 11, fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
                ),
            ],
          ),
          onTap: () async {
            await Navigator.pushNamed(context, AppRoutes.expenseForm, arguments: e);
            _loadExpenses();
          },
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.receipt_long_outlined, size: 64, color: AppColors.textSecondary),
          const SizedBox(height: 12),
          const Text('Nenhuma despesa encontrada', style: TextStyle(color: AppColors.textSecondary, fontFamily: 'Poppins')),
        ],
      ),
    );
  }
}
