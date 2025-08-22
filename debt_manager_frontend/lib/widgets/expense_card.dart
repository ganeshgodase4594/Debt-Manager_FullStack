import 'package:debt_manager_frontend/models/expense.dart';
import 'package:debt_manager_frontend/utils/constants.dart';
import 'package:debt_manager_frontend/widgets/gradient_card.dart';
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
      case ExpenseStatus.CANCELLED:
        return Colors.grey;
      default:
        return AppColors.warningColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientCard(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(20),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  expense.description,
                  style: AppTextStyles.headline3,
                ),
              ),
              if (onDelete != null)
                PopupMenuButton(
                  icon: Icon(Icons.more_vert, color: AppColors.lightText),
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
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryPink.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Creditor: ${expense.creator.fullName}',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primaryPink,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Amount', style: AppTextStyles.caption),
                  SizedBox(height: 4),
                  Text(
                    '₹${expense.amount.toStringAsFixed(2)}',
                    style: AppTextStyles.headline2.copyWith(
                      color: AppColors.primaryPink,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _getStatusColor().withOpacity(0.3)),
                ),
                child: Text(
                  expense.status.toString().split('.').last.toUpperCase(),
                  style: TextStyle(
                    color: _getStatusColor(),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          if (!showCreditor)
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.primaryPink.withOpacity(0.1),
                    child: Icon(
                      Icons.person,
                      color: AppColors.primaryPink,
                      size: 16,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      (currentUserId != null &&
                              expense.debtor.id == currentUserId)
                          ? '${expense.creator.fullName} (@${expense.creator.username})'
                          : '${expense.debtor.fullName} (@${expense.debtor.username})',
                      style: AppTextStyles.body2,
                    ),
                  ),
                ],
              ),
            ),
          if (expense.dueDate != null) ...[
            SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 16,
                  color:
                      expense.dueDate!.isBefore(DateTime.now()) &&
                              expense.status != ExpenseStatus.PAID
                          ? AppColors.errorColor
                          : AppColors.lightText,
                ),
                SizedBox(width: 8),
                Text(
                  'Due: ${DateFormat('MMM dd, yyyy').format(expense.dueDate!)}',
                  style: AppTextStyles.body2.copyWith(
                    color:
                        expense.dueDate!.isBefore(DateTime.now()) &&
                                expense.status != ExpenseStatus.PAID
                            ? AppColors.errorColor
                            : AppColors.lightText,
                  ),
                ),
              ],
            ),
          ],
          if (expense.notes != null && expense.notes!.isNotEmpty) ...[
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.note, size: 16, color: AppColors.lightText),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      expense.notes!,
                      style: AppTextStyles.body2,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.access_time, size: 14, color: AppColors.lightText),
              SizedBox(width: 6),
              Text(
                'Created ${DateFormat('MMM dd, yyyy').format(expense.createdAt)}',
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
