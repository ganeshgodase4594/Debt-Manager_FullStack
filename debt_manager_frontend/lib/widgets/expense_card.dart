import 'package:debt_manager_frontend/models/expense.dart';
import 'package:debt_manager_frontend/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ExpenseCard extends StatelessWidget {
  final Expense expense;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final int? currentUserId;
  final bool showCreditor;

  const ExpenseCard({
    super.key,
    required this.expense,
    this.onTap,
    this.onDelete,
    this.currentUserId,
    this.showCreditor = false,
  });

  Color _getStatusColor() {
    switch (expense.status) {
      case ExpenseStatus.PAID:
        return AppColors.successColor;
      case ExpenseStatus.OVERDUE:
        return AppColors.errorColor;
      case ExpenseStatus.CANCELLED:
        return Colors.grey;
      default:
        return AppColors.warningColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      expense.description,
                      style: AppTextStyles.headline2,
                    ),
                  ),
                  if (onDelete != null)
                    PopupMenuButton(
                      itemBuilder:
                          (context) => [
                            PopupMenuItem(
                              child: ListTile(
                                leading: Icon(
                                  Icons.delete,
                                  color: AppColors.errorColor,
                                ),
                                title: Text('Delete'),
                                dense: true,
                              ),
                              onTap: onDelete,
                            ),
                          ],
                    ),
                ],
              ),
              if (showCreditor) ...[
                SizedBox(height: 4),
                Text(
                  'Creditor: ${expense.creator.fullName} (@${expense.creator.username})',
                  style: AppTextStyles.body2,
                ),
              ],
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Rs. ${expense.amount.toStringAsFixed(2)}',
                    style: AppTextStyles.headline1.copyWith(
                      color: AppColors.primaryColor,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _getStatusColor()),
                    ),
                    child: Text(
                      expense.status.toString().split('.').last,
                      style: TextStyle(
                        color: _getStatusColor(),
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              if (!showCreditor)
                (currentUserId != null && expense.debtor.id == currentUserId)
                    ? Text(
                      'Creditor: ${expense.creator.fullName} (@${expense.creator.username})',
                      style: AppTextStyles.body2,
                    )
                    : Text(
                      'Debtor: ${expense.debtor.fullName} (@${expense.debtor.username})',
                      style: AppTextStyles.body2,
                    ),
              if (expense.dueDate != null) ...[
                SizedBox(height: 4),
                Text(
                  'Due: ${DateFormat('MMM dd, yyyy').format(expense.dueDate!)}',
                  style: AppTextStyles.body2.copyWith(
                    color:
                        expense.dueDate!.isBefore(DateTime.now()) &&
                                expense.status != ExpenseStatus.PAID
                            ? AppColors.errorColor
                            : Colors.grey[600],
                  ),
                ),
              ],
              if (expense.notes != null && expense.notes!.isNotEmpty) ...[
                SizedBox(height: 4),
                Text(
                  'Notes: ${expense.notes!}',
                  style: AppTextStyles.body2,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              SizedBox(height: 8),
              Text(
                'Created: ${DateFormat('MMM dd, yyyy').format(expense.createdAt)}',
                style: AppTextStyles.body2.copyWith(color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
