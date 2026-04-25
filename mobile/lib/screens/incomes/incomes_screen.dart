import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../../config/app_theme.dart';
import '../../models/income_model.dart';
import '../../services/financial_service.dart';
import '../../routes/app_routes.dart';
import '../../utils/formatters.dart';
import '../../widgets/common/month_year_selector.dart';

class IncomesScreen extends StatefulWidget {
  const IncomesScreen({super.key});

  @override
  State<IncomesScreen> createState() => _IncomesScreenState();
}

class _IncomesScreenState extends State<IncomesScreen> {
  final _service = FinancialService();
  List<IncomeModel> _incomes = [];
  bool _isLoading = true;
  int _month = DateTime.now().month;
  int _year = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _loadIncomes();
  }

  Future<void> _loadIncomes() async {
    setState(() => _isLoading = true);
    try {
      final data = await _service.getIncomes(month: _month, year: _year);
      setState(() { _incomes = data; _isLoading = false; });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _delete(IncomeModel income) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir renda'),
        content: Text('Deseja excluir "${income.description}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Excluir', style: TextStyle(color: AppColors.expense))),
        ],
      ),
    );
    if (confirm != true) return;
    EasyLoading.show();
    try {
      await _service.deleteIncome(income.id);
      EasyLoading.dismiss();
      _loadIncomes();
    } catch (e) {
      EasyLoading.dismiss();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: AppColors.expense));
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = _incomes.fold<double>(0, (s, i) => s + i.amount);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rendas'),
        actions: [
          MonthYearSelector(
            month: _month,
            year: _year,
            onChanged: (m, y) { setState(() { _month = m; _year = y; }); _loadIncomes(); },
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Column(
        children: [
          if (!_isLoading && _incomes.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: AppColors.income.withOpacity(0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total do mês:', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500)),
                  Text(AppFormatters.currency(total), style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: AppColors.income, fontSize: 16)),
                ],
              ),
            ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _incomes.isEmpty
                    ? const Center(child: Text('Nenhuma renda encontrada', style: TextStyle(color: AppColors.textSecondary, fontFamily: 'Poppins')))
                    : RefreshIndicator(
                        onRefresh: _loadIncomes,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _incomes.length,
                          itemBuilder: (_, i) => _buildItem(_incomes[i]),
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.pushNamed(context, AppRoutes.incomeForm);
          _loadIncomes();
        },
        icon: const Icon(Icons.add),
        label: const Text('Nova Renda'),
        backgroundColor: AppColors.income,
      ),
    );
  }

  Widget _buildItem(IncomeModel income) {
    return Dismissible(
      key: Key(income.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        color: AppColors.expense,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) async { await _delete(income); return false; },
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: const CircleAvatar(
            backgroundColor: Color(0xFFDCFCE7),
            child: Icon(Icons.attach_money, color: AppColors.income, size: 20),
          ),
          title: Text(income.description, style: const TextStyle(fontWeight: FontWeight.w500, fontFamily: 'Poppins'), maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(
            '${income.incomeTypeLabel} · ${AppFormatters.date(income.receiptDate)}',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontFamily: 'Poppins'),
          ),
          trailing: Text(AppFormatters.currency(income.amount), style: const TextStyle(color: AppColors.income, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
          onTap: () async {
            await Navigator.pushNamed(context, AppRoutes.incomeForm, arguments: income);
            _loadIncomes();
          },
        ),
      ),
    );
  }
}
