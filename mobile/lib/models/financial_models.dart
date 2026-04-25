class CategoryModel {
  final int id;
  final int userId;
  final String name;
  final String type;
  final String color;
  final String icon;

  const CategoryModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.color,
    required this.icon,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'] ?? '',
      type: json['type'] ?? 'expense',
      color: json['color'] ?? '#6366f1',
      icon: json['icon'] ?? 'category',
    );
  }
}

class PaymentMethodModel {
  final int id;
  final int userId;
  final String name;
  final String type;
  final bool isActive;

  const PaymentMethodModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.isActive,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'] ?? '',
      type: json['type'] ?? 'other',
      isActive: json['is_active'] == 1 || json['is_active'] == true,
    );
  }

  String get typeLabel {
    const labels = {
      'card': 'Cartão',
      'cash': 'Dinheiro',
      'check': 'Cheque',
      'pix': 'PIX',
      'transfer': 'Transferência',
      'cryptocurrency': 'Criptomoeda',
      'boleto': 'Boleto',
      'debit': 'Débito',
      'credit': 'Crédito',
      'other': 'Outro',
    };
    return labels[type] ?? type;
  }
}

class DashboardSummary {
  final int month;
  final int year;
  final double incomeTotal;
  final double expensesTotal;
  final double expensesPaid;
  final double expensesPending;
  final double expensesOverdue;
  final int pendingCount;
  final int overdueCount;
  final double balance;
  final double cardsUsed;
  final double cardsLimit;
  final double cardsAvailable;
  final double cardUsagePercentage;
  final double cryptoInvested;
  final double cryptoCurrentValue;
  final double cryptoProfitLoss;

  const DashboardSummary({
    required this.month,
    required this.year,
    required this.incomeTotal,
    required this.expensesTotal,
    required this.expensesPaid,
    required this.expensesPending,
    required this.expensesOverdue,
    required this.pendingCount,
    required this.overdueCount,
    required this.balance,
    required this.cardsUsed,
    required this.cardsLimit,
    required this.cardsAvailable,
    required this.cardUsagePercentage,
    required this.cryptoInvested,
    required this.cryptoCurrentValue,
    required this.cryptoProfitLoss,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    final income = json['income'] as Map<String, dynamic>? ?? {};
    final expenses = json['expenses'] as Map<String, dynamic>? ?? {};
    final cards = json['cards'] as Map<String, dynamic>? ?? {};
    final crypto = json['cryptocurrencies'] as Map<String, dynamic>? ?? {};

    return DashboardSummary(
      month: json['month'] ?? DateTime.now().month,
      year: json['year'] ?? DateTime.now().year,
      incomeTotal: double.tryParse(income['total']?.toString() ?? '0') ?? 0.0,
      expensesTotal: double.tryParse(expenses['total']?.toString() ?? '0') ?? 0.0,
      expensesPaid: double.tryParse(expenses['paid']?.toString() ?? '0') ?? 0.0,
      expensesPending: double.tryParse(expenses['pending']?.toString() ?? '0') ?? 0.0,
      expensesOverdue: double.tryParse(expenses['overdue']?.toString() ?? '0') ?? 0.0,
      pendingCount: int.tryParse(expenses['pending_count']?.toString() ?? '0') ?? 0,
      overdueCount: int.tryParse(expenses['overdue_count']?.toString() ?? '0') ?? 0,
      balance: double.tryParse(json['balance']?.toString() ?? '0') ?? 0.0,
      cardsUsed: double.tryParse(cards['total_used']?.toString() ?? '0') ?? 0.0,
      cardsLimit: double.tryParse(cards['total_limit']?.toString() ?? '0') ?? 0.0,
      cardsAvailable: double.tryParse(cards['available']?.toString() ?? '0') ?? 0.0,
      cardUsagePercentage: double.tryParse(cards['usage_percentage']?.toString() ?? '0') ?? 0.0,
      cryptoInvested: double.tryParse(crypto['total_invested']?.toString() ?? '0') ?? 0.0,
      cryptoCurrentValue: double.tryParse(crypto['total_current_value']?.toString() ?? '0') ?? 0.0,
      cryptoProfitLoss: double.tryParse(crypto['profit_loss']?.toString() ?? '0') ?? 0.0,
    );
  }
}
