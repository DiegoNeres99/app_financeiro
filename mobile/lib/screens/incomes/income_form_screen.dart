import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../../config/app_theme.dart';
import '../../models/income_model.dart';
import '../../models/financial_models.dart';
import '../../services/financial_service.dart';
import '../../utils/validators.dart';
import '../../utils/formatters.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/app_button.dart';

class IncomeFormScreen extends StatefulWidget {
  final IncomeModel? income;

  const IncomeFormScreen({super.key, this.income});

  @override
  State<IncomeFormScreen> createState() => _IncomeFormScreenState();
}

class _IncomeFormScreenState extends State<IncomeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();
  final _service = FinancialService();

  List<CategoryModel> _categories = [];
  CategoryModel? _selectedCategory;
  String _incomeType = 'salary';
  bool _isRecurring = false;

  bool get _isEditing => widget.income != null;

  static const _incomeTypes = [
    ('salary', 'Salário'),
    ('freelance', 'Freelance'),
    ('investment', 'Investimento'),
    ('rental', 'Aluguel'),
    ('other', 'Outros'),
  ];

  @override
  void initState() {
    super.initState();
    _loadCategories();
    if (_isEditing) _populateForm();
  }

  void _populateForm() {
    final inc = widget.income!;
    _descCtrl.text = inc.description;
    _amountCtrl.text = inc.amount.toStringAsFixed(2).replaceAll('.', ',');
    _dateCtrl.text = AppFormatters.date(inc.receiptDate);
    _incomeType = inc.incomeType;
    _isRecurring = inc.isRecurring;
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await _service.getCategories(type: 'income');
      setState(() {
        _categories = cats;
        if (_isEditing && widget.income!.categoryId != null) {
          _selectedCategory = cats.firstWhere((c) => c.id == widget.income!.categoryId, orElse: () => cats.first);
        }
      });
    } catch (_) {}
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date != null) _dateCtrl.text = AppFormatters.date(date);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final amount = double.tryParse(_amountCtrl.text.replaceAll(',', '.').replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;

    EasyLoading.show();
    try {
      final payload = {
        'description': _descCtrl.text.trim(),
        'amount': amount,
        'receipt_date': AppFormatters.toApiDateFromDisplay(_dateCtrl.text),
        'income_type': _incomeType,
        'is_recurring': _isRecurring,
        if (_selectedCategory != null) 'category_id': _selectedCategory!.id,
      };

      if (_isEditing) {
        await _service.updateIncome(widget.income!.id, payload);
      } else {
        await _service.createIncome(payload);
      }

      EasyLoading.dismiss();
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      EasyLoading.dismiss();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: AppColors.expense));
    }
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _amountCtrl.dispose();
    _dateCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Editar Renda' : 'Nova Renda')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                controller: _descCtrl,
                label: 'Descrição',
                hint: 'Ex: Salário mensal',
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
                controller: _dateCtrl,
                label: 'Data de Recebimento',
                hint: 'dd/MM/aaaa',
                prefixIcon: Icons.calendar_today_outlined,
                readOnly: true,
                onTap: _pickDate,
                validator: (v) => Validators.required(v, 'Data'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _incomeType,
                decoration: const InputDecoration(labelText: 'Tipo de Renda', prefixIcon: Icon(Icons.category_outlined)),
                items: _incomeTypes.map((t) => DropdownMenuItem(value: t.$1, child: Text(t.$2))).toList(),
                onChanged: (v) => setState(() => _incomeType = v ?? 'salary'),
              ),
              const SizedBox(height: 16),
              if (_categories.isNotEmpty)
                DropdownButtonFormField<CategoryModel>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(labelText: 'Categoria', prefixIcon: Icon(Icons.label_outline)),
                  items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
                  onChanged: (c) => setState(() => _selectedCategory = c),
                ),
              const SizedBox(height: 8),
              CheckboxListTile(
                title: const Text('Renda recorrente', style: TextStyle(fontFamily: 'Poppins')),
                value: _isRecurring,
                onChanged: (v) => setState(() => _isRecurring = v ?? false),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 24),
              AppButton(label: _isEditing ? 'Salvar alterações' : 'Criar renda', onPressed: _save, color: AppColors.income),
            ],
          ),
        ),
      ),
    );
  }
}
