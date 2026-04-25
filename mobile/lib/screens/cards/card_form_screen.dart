import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../../config/app_theme.dart';
import '../../models/card_model.dart';
import '../../services/financial_service.dart';
import '../../utils/validators.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/app_button.dart';

class CardFormScreen extends StatefulWidget {
  final CardModel? card;

  const CardFormScreen({super.key, this.card});

  @override
  State<CardFormScreen> createState() => _CardFormScreenState();
}

class _CardFormScreenState extends State<CardFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _flagCtrl = TextEditingController();
  final _limitCtrl = TextEditingController();
  final _usedCtrl = TextEditingController();
  final _dueDayCtrl = TextEditingController();
  final _closingDayCtrl = TextEditingController();
  final _bestPurchaseDayCtrl = TextEditingController();
  final _service = FinancialService();
  bool _isActive = true;

  bool get _isEditing => widget.card != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final c = widget.card!;
      _nameCtrl.text = c.cardName;
      _flagCtrl.text = c.flag ?? '';
      _limitCtrl.text = c.totalLimit.toStringAsFixed(2).replaceAll('.', ',');
      _usedCtrl.text = c.usedLimit.toStringAsFixed(2).replaceAll('.', ',');
      _dueDayCtrl.text = c.dueDay?.toString() ?? '';
      _closingDayCtrl.text = c.closingDay?.toString() ?? '';
      _bestPurchaseDayCtrl.text = c.bestPurchaseDay?.toString() ?? '';
      _isActive = c.isActive;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _flagCtrl.dispose(); _limitCtrl.dispose();
    _usedCtrl.dispose(); _dueDayCtrl.dispose(); _closingDayCtrl.dispose();
    _bestPurchaseDayCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final limit = double.tryParse(_limitCtrl.text.replaceAll(',', '.').replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
    final used = double.tryParse(_usedCtrl.text.replaceAll(',', '.').replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;

    EasyLoading.show();
    try {
      final payload = {
        'card_name': _nameCtrl.text.trim(),
        if (_flagCtrl.text.isNotEmpty) 'flag': _flagCtrl.text.trim(),
        'total_limit': limit,
        'used_limit': used,
        'is_active': _isActive,
        if (_dueDayCtrl.text.isNotEmpty) 'due_day': int.tryParse(_dueDayCtrl.text),
        if (_closingDayCtrl.text.isNotEmpty) 'closing_day': int.tryParse(_closingDayCtrl.text),
        if (_bestPurchaseDayCtrl.text.isNotEmpty) 'best_purchase_day': int.tryParse(_bestPurchaseDayCtrl.text),
      };

      if (_isEditing) {
        await _service.updateCard(widget.card!.id, payload);
      } else {
        await _service.createCard(payload);
      }

      EasyLoading.dismiss();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      EasyLoading.dismiss();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: AppColors.expense));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Editar Cartão' : 'Novo Cartão')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(controller: _nameCtrl, label: 'Nome do cartão', hint: 'Ex: Nubank', prefixIcon: Icons.credit_card, validator: (v) => Validators.required(v, 'Nome'), textCapitalization: TextCapitalization.words),
              const SizedBox(height: 16),
              AppTextField(controller: _flagCtrl, label: 'Bandeira', hint: 'Ex: Visa, Mastercard', prefixIcon: Icons.payment_outlined),
              const SizedBox(height: 16),
              AppTextField(controller: _limitCtrl, label: 'Limite total (R\$)', hint: '0,00', keyboardType: TextInputType.number, prefixIcon: Icons.attach_money, validator: Validators.amount),
              const SizedBox(height: 16),
              AppTextField(controller: _usedCtrl, label: 'Limite utilizado (R\$)', hint: '0,00', keyboardType: TextInputType.number, prefixIcon: Icons.money_off_outlined),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: AppTextField(controller: _dueDayCtrl, label: 'Dia vencimento', hint: '1-31', keyboardType: TextInputType.number, prefixIcon: Icons.event_outlined)),
                  const SizedBox(width: 12),
                  Expanded(child: AppTextField(controller: _closingDayCtrl, label: 'Dia fechamento', hint: '1-31', keyboardType: TextInputType.number, prefixIcon: Icons.event_note_outlined)),
                ],
              ),
              const SizedBox(height: 16),
              AppTextField(controller: _bestPurchaseDayCtrl, label: 'Melhor dia de compra', hint: '1-31', keyboardType: TextInputType.number, prefixIcon: Icons.shopping_cart_outlined),
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text('Cartão ativo', style: TextStyle(fontFamily: 'Poppins')),
                value: _isActive,
                onChanged: (v) => setState(() => _isActive = v),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 24),
              AppButton(label: _isEditing ? 'Salvar alterações' : 'Criar cartão', onPressed: _save, color: AppColors.info),
            ],
          ),
        ),
      ),
    );
  }
}
