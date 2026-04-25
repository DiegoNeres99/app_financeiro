import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../../config/app_theme.dart';
import '../../models/expense_model.dart';
import '../../models/financial_models.dart';
import '../../services/financial_service.dart';
import '../../utils/validators.dart';
import '../../utils/formatters.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/app_button.dart';

class ExpenseFormScreen extends StatefulWidget {
  final ExpenseModel? expense;

  const ExpenseFormScreen({super.key, this.expense});

  @override
  State<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends State<ExpenseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _dueDateCtrl = TextEditingController();
  final _service = FinancialService();

  List<CategoryModel> _categories = [];
  List<PaymentMethodModel> _paymentMethods = [];
  CategoryModel? _selectedCategory;
  PaymentMethodModel? _selectedPaymentMethod;
  bool _isRecurring = false;
  bool _isLoading = false;

  bool get _isEditing => widget.expense != null;

  @override
  void initState() {
    super.initState();
    _loadOptions();
    if (_isEditing) _populateForm();
  }

  void _populateForm() {
    final e = widget.expense!;
    _descCtrl.text = e.description;
    _amountCtrl.text = e.amount.toStringAsFixed(2).replaceAll('.', ',');
    _dueDateCtrl.text = AppFormatters.date(e.dueDate);
    _isRecurring = e.isRecurring;
  }

  Future<void> _loadOptions() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _service.getCategories(type: 'expense'),
        _service.getPaymentMethods(),
      ]);
      setState(() {
        _categories = results[0] as List<CategoryModel>;
        _paymentMethods = results[1] as List<PaymentMethodModel>;
        if (_isEditing && widget.expense!.categoryId != null) {
          _selectedCategory = _categories.firstWhere((c) => c.id == widget.expense!.categoryId, orElse: () => _categories.first);
        }
        if (_isEditing && widget.expense!.paymentMethodId != null) {
          _selectedPaymentMethod = _paymentMethods.firstWhere((p) => p.id == widget.expense!.paymentMethodId, orElse: () => _paymentMethods.first);
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date != null) {
      _dueDateCtrl.text = AppFormatters.date(date);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountCtrl.text.replaceAll(',', '.').replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;

    EasyLoading.show(status: _isEditing ? 'Salvando...' : 'Criando...');
    try {
      final payload = {
        'description': _descCtrl.text.trim(),
        'amount': amount,
        'due_date': AppFormatters.toApiDateFromDisplay(_dueDateCtrl.text),
        'is_recurring': _isRecurring,
        if (_selectedCategory != null) 'category_id': _selectedCategory!.id,
        if (_selectedPaymentMethod != null) 'payment_method_id': _selectedPaymentMethod!.id,
      };

      if (_isEditing) {
        await _service.updateExpense(widget.expense!.id, payload);
      } else {
        await _service.createExpense(payload);
      }

      EasyLoading.dismiss();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      EasyLoading.dismiss();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: AppColors.expense));
    }
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _amountCtrl.dispose();
    _dueDateCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Editar Despesa' : 'Nova Despesa')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppTextField(
                      controller: _descCtrl,
                      label: 'Descrição',
                      hint: 'Ex: Conta de luz',
                      prefixIcon: Icons.description_outlined,
                      validator: (v) => Validators.required(v, 'Descrição'),
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _amountCtrl,
                      label: 'Valor (R\$)',
                      hint: '0,00',
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.attach_money,
                      validator: Validators.amount,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _dueDateCtrl,
                      label: 'Data de Vencimento',
                      hint: 'dd/MM/aaaa',
                      prefixIcon: Icons.calendar_today_outlined,
                      readOnly: true,
                      onTap: _pickDate,
                      validator: (v) => Validators.required(v, 'Data'),
                    ),
                    const SizedBox(height: 16),
                    if (_categories.isNotEmpty)
                      DropdownButtonFormField<CategoryModel>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(labelText: 'Categoria', prefixIcon: Icon(Icons.category_outlined)),
                        items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
                        onChanged: (c) => setState(() => _selectedCategory = c),
                      ),
                    const SizedBox(height: 16),
                    if (_paymentMethods.isNotEmpty)
                      DropdownButtonFormField<PaymentMethodModel>(
                        value: _selectedPaymentMethod,
                        decoration: const InputDecoration(labelText: 'Método de pagamento', prefixIcon: Icon(Icons.payment_outlined)),
                        items: _paymentMethods.map((p) => DropdownMenuItem(value: p, child: Text(p.name))).toList(),
                        onChanged: (p) => setState(() => _selectedPaymentMethod = p),
                      ),
                    const SizedBox(height: 8),
                    CheckboxListTile(
                      title: const Text('Despesa recorrente', style: TextStyle(fontFamily: 'Poppins')),
                      value: _isRecurring,
                      onChanged: (v) => setState(() => _isRecurring = v ?? false),
                      contentPadding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 24),
                    AppButton(label: _isEditing ? 'Salvar alterações' : 'Criar despesa', onPressed: _save),
                  ],
                ),
              ),
            ),
    );
  }
}
