import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../../config/app_theme.dart';
import '../../models/cryptocurrency_model.dart';
import '../../services/financial_service.dart';
import '../../utils/validators.dart';
import '../../utils/formatters.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/app_button.dart';

class CryptocurrencyFormScreen extends StatefulWidget {
  final CryptocurrencyModel? crypto;

  const CryptocurrencyFormScreen({super.key, this.crypto});

  @override
  State<CryptocurrencyFormScreen> createState() => _CryptocurrencyFormScreenState();
}

class _CryptocurrencyFormScreenState extends State<CryptocurrencyFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _symbolCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController();
  final _purchaseValueCtrl = TextEditingController();
  final _currentValueCtrl = TextEditingController();
  final _exchangeCtrl = TextEditingController();
  final _purchaseDateCtrl = TextEditingController();
  final _service = FinancialService();

  bool get _isEditing => widget.crypto != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final c = widget.crypto!;
      _nameCtrl.text = c.name;
      _symbolCtrl.text = c.symbol;
      _quantityCtrl.text = c.quantity.toString();
      _purchaseValueCtrl.text = c.purchaseValue.toStringAsFixed(2).replaceAll('.', ',');
      _currentValueCtrl.text = c.currentValue.toStringAsFixed(2).replaceAll('.', ',');
      _exchangeCtrl.text = c.exchange ?? '';
      if (c.purchaseDate != null) _purchaseDateCtrl.text = AppFormatters.date(c.purchaseDate!);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _symbolCtrl.dispose(); _quantityCtrl.dispose();
    _purchaseValueCtrl.dispose(); _currentValueCtrl.dispose();
    _exchangeCtrl.dispose(); _purchaseDateCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2009), lastDate: DateTime.now());
    if (date != null) _purchaseDateCtrl.text = AppFormatters.date(date);
  }

  double _parseAmount(String text) {
    return double.tryParse(text.replaceAll(',', '.').replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    EasyLoading.show();
    try {
      final payload = {
        'name': _nameCtrl.text.trim(),
        'symbol': _symbolCtrl.text.trim().toUpperCase(),
        'quantity': double.tryParse(_quantityCtrl.text.replaceAll(',', '.')) ?? 0,
        'purchase_value': _parseAmount(_purchaseValueCtrl.text),
        'current_value': _parseAmount(_currentValueCtrl.text),
        if (_exchangeCtrl.text.isNotEmpty) 'exchange': _exchangeCtrl.text.trim(),
        if (_purchaseDateCtrl.text.isNotEmpty) 'purchase_date': AppFormatters.toApiDateFromDisplay(_purchaseDateCtrl.text),
      };

      if (_isEditing) {
        await _service.updateCryptocurrency(widget.crypto!.id, payload);
      } else {
        await _service.createCryptocurrency(payload);
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
      appBar: AppBar(title: Text(_isEditing ? 'Editar Cripto' : 'Nova Criptomoeda')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(child: AppTextField(controller: _nameCtrl, label: 'Nome', hint: 'Bitcoin', prefixIcon: Icons.currency_bitcoin, validator: (v) => Validators.required(v, 'Nome'), textCapitalization: TextCapitalization.words)),
                  const SizedBox(width: 12),
                  SizedBox(width: 100, child: AppTextField(controller: _symbolCtrl, label: 'Símbolo', hint: 'BTC', validator: (v) => Validators.required(v, 'Símbolo'))),
                ],
              ),
              const SizedBox(height: 16),
              AppTextField(controller: _quantityCtrl, label: 'Quantidade', hint: '0.00000000', keyboardType: TextInputType.number, prefixIcon: Icons.numbers, validator: Validators.amount),
              const SizedBox(height: 16),
              AppTextField(controller: _purchaseValueCtrl, label: 'Valor de Compra (R\$)', hint: '0,00', keyboardType: TextInputType.number, prefixIcon: Icons.attach_money, validator: Validators.amount),
              const SizedBox(height: 16),
              AppTextField(controller: _currentValueCtrl, label: 'Valor Atual (R\$)', hint: '0,00', keyboardType: TextInputType.number, prefixIcon: Icons.show_chart, validator: Validators.amount),
              const SizedBox(height: 16),
              AppTextField(controller: _exchangeCtrl, label: 'Exchange', hint: 'Binance, Coinbase...', prefixIcon: Icons.swap_horiz),
              const SizedBox(height: 16),
              AppTextField(controller: _purchaseDateCtrl, label: 'Data de Compra', hint: 'dd/MM/aaaa', prefixIcon: Icons.calendar_today_outlined, readOnly: true, onTap: _pickDate),
              const SizedBox(height: 32),
              AppButton(label: _isEditing ? 'Salvar alterações' : 'Criar criptomoeda', onPressed: _save, color: Colors.orange),
            ],
          ),
        ),
      ),
    );
  }
}
