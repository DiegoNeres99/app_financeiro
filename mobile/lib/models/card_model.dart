class CardModel {
  final int id;
  final int userId;
  final String cardName;
  final String? flag;
  final double totalLimit;
  final double usedLimit;
  final double availableLimit;
  final double usagePercentage;
  final int? bestPurchaseDay;
  final int? closingDay;
  final int? dueDay;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CardModel({
    required this.id,
    required this.userId,
    required this.cardName,
    this.flag,
    required this.totalLimit,
    required this.usedLimit,
    required this.availableLimit,
    required this.usagePercentage,
    this.bestPurchaseDay,
    this.closingDay,
    this.dueDay,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      id: json['id'],
      userId: json['user_id'],
      cardName: json['card_name'] ?? '',
      flag: json['flag'],
      totalLimit: double.tryParse(json['total_limit'].toString()) ?? 0.0,
      usedLimit: double.tryParse(json['used_limit'].toString()) ?? 0.0,
      availableLimit: double.tryParse(json['available_limit']?.toString() ?? '0') ?? 0.0,
      usagePercentage: double.tryParse(json['usage_percentage']?.toString() ?? '0') ?? 0.0,
      bestPurchaseDay: json['best_purchase_day'],
      closingDay: json['closing_day'],
      dueDay: json['due_day'],
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
