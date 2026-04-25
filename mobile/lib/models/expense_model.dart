import 'package:flutter/material.dart';
import '../config/app_theme.dart';

class ExpenseModel {
  final int id;
  final int userId;
  final String description;
  final double amount;
  final DateTime dueDate;
  final DateTime? paymentDate;
  final int? categoryId;
  final String? categoryName;
  final String? categoryColor;
  final String status;
  final int? paymentMethodId;
  final String? paymentMethodName;
  final bool isRecurring;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ExpenseModel({
    required this.id,
    required this.userId,
    required this.description,
    required this.amount,
    required this.dueDate,
    this.paymentDate,
    this.categoryId,
    this.categoryName,
    this.categoryColor,
    required this.status,
    this.paymentMethodId,
    this.paymentMethodName,
    required this.isRecurring,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'],
      userId: json['user_id'],
      description: json['description'] ?? '',
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      dueDate: DateTime.parse(json['due_date']),
      paymentDate: json['payment_date'] != null ? DateTime.parse(json['payment_date']) : null,
      categoryId: json['category_id'],
      categoryName: json['category_name'],
      categoryColor: json['category_color'],
      status: json['status'] ?? 'pending',
      paymentMethodId: json['payment_method_id'],
      paymentMethodName: json['payment_method_name'],
      isRecurring: json['is_recurring'] == 1 || json['is_recurring'] == true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  String get statusLabel {
    const labels = {'pending': 'Pendente', 'paid': 'Pago', 'overdue': 'Atrasado'};
    return labels[status] ?? status;
  }

  Color get statusColor {
    switch (status) {
      case 'paid': return AppColors.paid;
      case 'overdue': return AppColors.overdue;
      default: return AppColors.pending;
    }
  }

  bool get isOverdue => status == 'overdue' || (status == 'pending' && dueDate.isBefore(DateTime.now()));
}
