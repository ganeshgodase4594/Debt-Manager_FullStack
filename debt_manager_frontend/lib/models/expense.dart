import 'package:debt_manager_frontend/models/user.dart';

enum ExpenseStatus { PENDING, PAID, CANCELLED, OVERDUE }

class Expense {
  final int id;
  final String description;
  final double amount;
  final User creator;
  final User debtor;
  final ExpenseStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? dueDate;
  final String? notes;

  Expense({
    required this.id,
    required this.description,
    required this.amount,
    required this.creator,
    required this.debtor,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.dueDate,
    this.notes,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      description: json['description'],
      amount: (json['amount'] as num).toDouble(),
      creator: User.fromJson(json['creator']),
      debtor: User.fromJson(json['debtor']),
      status: ExpenseStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => ExpenseStatus.PENDING,
      ),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      dueDate:
          json['due_date'] != null ? DateTime.parse(json['due_date']) : null,
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'creator': creator.toJson(),
      'debtor': debtor.toJson(),
      'status': status.toString().split('.').last,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'due_date': dueDate?.toIso8601String(),
      'notes': notes,
    };
  }
}
