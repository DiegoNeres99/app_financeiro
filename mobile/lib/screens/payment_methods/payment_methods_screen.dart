import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../../config/app_theme.dart';
import '../../models/financial_models.dart';
import '../../services/financial_service.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final _service = FinancialService();
  List<PaymentMethodModel> _methods = [];
  bool _isLoading = true;

  static const _types = [
    ('card', 'Cartão'), ('cash', 'Dinheiro'), ('check', 'Cheque'),
    ('pix', 'PIX'), ('transfer', 'Transferência'), ('cryptocurrency', 'Cripto'),
    ('boleto', 'Boleto'), ('debit', 'Débito'), ('credit', 'Crédito'), ('other', 'Outro'),
  ];

  @override
  void initState() {
    super.initState();
    _loadMethods();
  }

  Future<void> _loadMethods() async {
    setState(() => _isLoading = true);
    try {
      final data = await _service.getPaymentMethods();
      setState(() { _methods = data; _isLoading = false; });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _add() async {
    final nameCtrl = TextEditingController();
    String selectedType = 'other';

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 24, right: 24, top: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Novo Método de Pagamento', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
            const SizedBox(height: 16),
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Nome', prefixIcon: Icon(Icons.payment_outlined)),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            StatefulBuilder(
              builder: (_, setSheetState) => DropdownButtonFormField<String>(
                value: selectedType,
                decoration: const InputDecoration(labelText: 'Tipo'),
                items: _types.map((t) => DropdownMenuItem(value: t.$1, child: Text(t.$2))).toList(),
                onChanged: (v) => setSheetState(() => selectedType = v ?? 'other'),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty) return;
                Navigator.pop(ctx);
                EasyLoading.show();
                try {
                  await _service.createPaymentMethod({'name': nameCtrl.text.trim(), 'type': selectedType});
                  EasyLoading.dismiss();
                  _loadMethods();
                } catch (e) {
                  EasyLoading.dismiss();
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: AppColors.expense));
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Criar', style: TextStyle(color: Colors.white, fontFamily: 'Poppins')),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
    nameCtrl.dispose();
  }

  Future<void> _delete(PaymentMethodModel method) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir método'),
        content: Text('Deseja excluir "${method.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Excluir', style: TextStyle(color: AppColors.expense))),
        ],
      ),
    );
    if (confirm != true) return;
    EasyLoading.show();
    try {
      await _service.deletePaymentMethod(method.id);
      EasyLoading.dismiss();
      _loadMethods();
    } catch (e) {
      EasyLoading.dismiss();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: AppColors.expense));
    }
  }

  static const _typeIcons = {
    'card': Icons.credit_card,
    'cash': Icons.money,
    'pix': Icons.qr_code,
    'transfer': Icons.swap_horiz,
    'debit': Icons.credit_card_outlined,
    'credit': Icons.credit_card,
    'boleto': Icons.receipt_outlined,
    'check': Icons.article_outlined,
    'cryptocurrency': Icons.currency_bitcoin,
    'other': Icons.payment_outlined,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Métodos de Pagamento')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _methods.isEmpty
              ? const Center(child: Text('Nenhum método cadastrado', style: TextStyle(color: AppColors.textSecondary, fontFamily: 'Poppins')))
              : RefreshIndicator(
                  onRefresh: _loadMethods,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _methods.length,
                    itemBuilder: (_, i) {
                      final m = _methods[i];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            child: Icon(_typeIcons[m.type] ?? Icons.payment_outlined, color: AppColors.primary, size: 20),
                          ),
                          title: Text(m.name, style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500)),
                          subtitle: Text(m.typeLabel, style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.textSecondary)),
                          trailing: IconButton(icon: const Icon(Icons.delete_outline, color: AppColors.expense), onPressed: () => _delete(m)),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _add,
        icon: const Icon(Icons.add),
        label: const Text('Novo Método'),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}
