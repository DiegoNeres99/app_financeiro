class IncomeModel {
  final int id;
  final int userId;
  final String description;
  final double amount;
  final DateTime receiptDate;
  final String incomeType;
  final int? categoryId;
  final String? categoryName;
  final String? categoryColor;
  final bool isRecurring;
  final DateTime createdAt;
  final DateTime updatedAt;

  const IncomeModel({
    required this.id,
    required this.userId,
    required this.description,
    required this.amount,
    required this.receiptDate,
    required this.incomeType,
    this.categoryId,
    this.categoryName,
    this.categoryColor,
    required this.isRecurring,
    required this.createdAt,
    required this.updatedAt,
  });

  factory IncomeModel.fromJson(Map<String, dynamic> json) {
    return IncomeModel(
      id: json['id'],
      userId: json['user_id'],
      description: json['description'] ?? '',
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      receiptDate: DateTime.parse(json['receipt_date']),
      incomeType: json['income_type'] ?? 'other',
      categoryId: json['category_id'],
      categoryName: json['category_name'],
      categoryColor: json['category_color'],
      isRecurring: json['is_recurring'] == 1 || json['is_recurring'] == true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  String get incomeTypeLabel {
    const labels = {
      'salary': 'Salário',
      'freelance': 'Freelance',
      'investment': 'Investimento',
      'sale': 'Venda',
      'other': 'Outro',
    };
    return labels[incomeType] ?? incomeType;
  }
}
