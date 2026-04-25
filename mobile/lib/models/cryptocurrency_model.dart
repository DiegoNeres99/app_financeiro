class CryptocurrencyModel {
  final int id;
  final int userId;
  final String name;
  final String symbol;
  final double quantity;
  final double purchaseValue;
  final double currentValue;
  final double profitLoss;
  final double profitLossPercentage;
  final String? exchange;
  final DateTime? purchaseDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CryptocurrencyModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.symbol,
    required this.quantity,
    required this.purchaseValue,
    required this.currentValue,
    required this.profitLoss,
    required this.profitLossPercentage,
    this.exchange,
    this.purchaseDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CryptocurrencyModel.fromJson(Map<String, dynamic> json) {
    return CryptocurrencyModel(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'] ?? '',
      symbol: json['symbol'] ?? '',
      quantity: double.tryParse(json['quantity'].toString()) ?? 0.0,
      purchaseValue: double.tryParse(json['purchase_value'].toString()) ?? 0.0,
      currentValue: double.tryParse(json['current_value'].toString()) ?? 0.0,
      profitLoss: double.tryParse(json['profit_loss']?.toString() ?? '0') ?? 0.0,
      profitLossPercentage: double.tryParse(json['profit_loss_percentage']?.toString() ?? '0') ?? 0.0,
      exchange: json['exchange'],
      purchaseDate: json['purchase_date'] != null ? DateTime.parse(json['purchase_date']) : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  double get totalInvested => quantity * purchaseValue;
  double get totalCurrentValue => quantity * currentValue;
  bool get isProfit => profitLoss >= 0;
}
