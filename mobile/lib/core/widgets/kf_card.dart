import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';
import 'kf_status.dart';

/// Standard card container
class KFCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color? backgroundColor;
  final List<BoxShadow>? boxShadow;
  final BorderRadius? borderRadius;
  final Border? border;

  const KFCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.onLongPress,
    this.backgroundColor,
    this.boxShadow,
    this.borderRadius,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color:
            backgroundColor ?? (isDark ? KFColors.darkSurface : KFColors.white),
        borderRadius: borderRadius ?? KFRadius.radiusXl,
        border: border ??
            Border.all(
              color: isDark ? KFColors.darkBorder : KFColors.gray200,
            ),
        boxShadow: boxShadow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: borderRadius ?? KFRadius.radiusXl,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: borderRadius ?? KFRadius.radiusXl,
          child: Padding(
            padding: padding ?? KFSpacing.cardPadding,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Elevated card with shadow
class KFElevatedCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final List<BoxShadow> elevation;

  const KFElevatedCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.elevation = KFShadows.md,
  });

  @override
  Widget build(BuildContext context) {
    return KFCard(
      padding: padding,
      onTap: onTap,
      boxShadow: elevation,
      border: Border.all(color: Colors.transparent),
      child: child,
    );
  }
}

/// Payslip card for payslip list
class KFPayslipCard extends StatelessWidget {
  final String month;
  final String year;
  final double netAmount;
  final String currencyCode;
  final bool isNew;
  final bool isPaid;
  final VoidCallback? onTap;

  const KFPayslipCard({
    super.key,
    required this.month,
    required this.year,
    required this.netAmount,
    this.currencyCode = 'RM',
    this.isNew = false,
    this.isPaid = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return KFCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // NEW badge
          if (isNew)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: KFColors.primary600,
                borderRadius: KFRadius.radiusSm,
              ),
              child: const Text(
                'NEW',
                style: TextStyle(
                  color: KFColors.white,
                  fontSize: KFTypography.fontSizeXs,
                  fontWeight: KFTypography.bold,
                ),
              ),
            ),

          if (isNew) const SizedBox(height: KFSpacing.space2),

          // Month
          Text(
            month.toUpperCase(),
            style: const TextStyle(
              fontSize: KFTypography.fontSizeBase,
              fontWeight: KFTypography.semibold,
              color: KFColors.gray600,
            ),
          ),

          // Year
          Text(
            year,
            style: const TextStyle(
              fontSize: KFTypography.fontSizeSm,
              color: KFColors.gray400,
            ),
          ),

          const Spacer(),

          // Net amount
          Text(
            '$currencyCode ${_formatAmount(netAmount)}',
            style: const TextStyle(
              fontSize: KFTypography.fontSizeLg,
              fontWeight: KFTypography.bold,
              color: KFColors.gray900,
            ),
          ),

          const SizedBox(height: KFSpacing.space2),

          // Status
          Row(
            children: [
              Icon(
                isPaid ? Icons.check_circle : Icons.schedule,
                size: KFIconSizes.sm,
                color: isPaid ? KFColors.success600 : KFColors.warning600,
              ),
              const SizedBox(width: 4),
              Text(
                isPaid ? 'Paid' : 'Processing',
                style: TextStyle(
                  fontSize: KFTypography.fontSizeSm,
                  color: isPaid ? KFColors.success600 : KFColors.warning600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatAmount(double amount) {
    return amount.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}

/// Leave balance card
class KFLeaveBalanceCard extends StatelessWidget {
  final String leaveType;
  final IconData icon;
  final Color color;
  final int balance;
  final int total;
  final VoidCallback? onTap;

  const KFLeaveBalanceCard({
    super.key,
    required this.leaveType,
    required this.icon,
    required this.color,
    required this.balance,
    required this.total,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = total > 0 ? balance / total : 0.0;

    return KFCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: KFRadius.radiusMd,
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: KFSpacing.space3),
              Expanded(
                child: Text(
                  leaveType,
                  style: const TextStyle(
                    fontSize: KFTypography.fontSizeMd,
                    fontWeight: KFTypography.semibold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: KFSpacing.space4),

          // Balance
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$balance',
                  style: const TextStyle(
                    fontFamily: KFTypography.fontFamily,
                    fontSize: KFTypography.fontSize3xl,
                    fontWeight: KFTypography.bold,
                    color: KFColors.gray900,
                  ),
                ),
                TextSpan(
                  text: ' / $total days',
                  style: const TextStyle(
                    fontFamily: KFTypography.fontFamily,
                    fontSize: KFTypography.fontSizeBase,
                    color: KFColors.gray500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: KFSpacing.space3),

          // Progress bar
          ClipRRect(
            borderRadius: KFRadius.radiusFull,
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: KFColors.gray200,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}

/// Stats card for dashboard
class KFStatsCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color iconColor;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const KFStatsCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    this.iconColor = KFColors.primary600,
    this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return KFCard(
      onTap: onTap,
      backgroundColor: backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: KFTypography.fontSizeSm,
                  color: KFColors.gray600,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: KFRadius.radiusMd,
                ),
                child: Icon(icon, size: KFIconSizes.md, color: iconColor),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: KFTypography.fontSize2xl,
              fontWeight: KFTypography.bold,
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              style: const TextStyle(
                fontSize: KFTypography.fontSizeSm,
                color: KFColors.gray500,
              ),
            ),
        ],
      ),
    );
  }
}

/// Approval card for pending approvals
class KFApprovalCard extends StatelessWidget {
  final String employeeName;
  final String? employeeId;
  final String? employeeAvatar;
  final String leaveType;
  final IconData? leaveTypeIcon;
  final Color? leaveTypeColor;
  final DateTime? startDate;
  final DateTime? endDate;
  final double? days;
  final String? reason;
  final StatusType? status;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final VoidCallback? onTap;

  const KFApprovalCard({
    super.key,
    required this.employeeName,
    this.employeeId,
    this.employeeAvatar,
    required this.leaveType,
    this.leaveTypeIcon,
    this.leaveTypeColor,
    this.startDate,
    this.endDate,
    this.days,
    this.reason,
    this.status,
    this.onApprove,
    this.onReject,
    this.onTap,
  });

  String _formatDateRange() {
    if (startDate == null || endDate == null) return '';
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    if (startDate == endDate) {
      return '${startDate!.day} ${months[startDate!.month - 1]} ${startDate!.year}';
    }
    return '${startDate!.day} ${months[startDate!.month - 1]} - ${endDate!.day} ${months[endDate!.month - 1]} ${endDate!.year}';
  }

  @override
  Widget build(BuildContext context) {
    final color = leaveTypeColor ?? KFColors.primary600;
    final icon = leaveTypeIcon ?? Icons.event;

    return KFCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: KFColors.primary100,
                backgroundImage:
                    employeeAvatar != null ? NetworkImage(employeeAvatar!) : null,
                child: employeeAvatar == null
                    ? Text(
                        employeeName.isNotEmpty ? employeeName[0].toUpperCase() : '?',
                        style: const TextStyle(
                          color: KFColors.primary600,
                          fontWeight: KFTypography.semibold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: KFSpacing.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      employeeName,
                      style: const TextStyle(
                        fontSize: KFTypography.fontSizeBase,
                        fontWeight: KFTypography.semibold,
                      ),
                    ),
                    if (employeeId != null)
                      Text(
                        employeeId!,
                        style: const TextStyle(
                          fontSize: KFTypography.fontSizeSm,
                          color: KFColors.gray500,
                        ),
                      ),
                  ],
                ),
              ),
              if (status != null)
                _buildStatusBadge(status!),
            ],
          ),
          const SizedBox(height: KFSpacing.space3),
          // Leave type with icon
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: KFRadius.radiusSm,
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: KFSpacing.space2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      leaveType,
                      style: const TextStyle(
                        fontSize: KFTypography.fontSizeSm,
                        fontWeight: KFTypography.medium,
                      ),
                    ),
                    if (days != null)
                      Text(
                        '${days!.toStringAsFixed(days! % 1 == 0 ? 0 : 1)} ${days == 1 ? 'day' : 'days'}',
                        style: const TextStyle(
                          fontSize: KFTypography.fontSizeXs,
                          color: KFColors.gray500,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (startDate != null && endDate != null) ...[
            const SizedBox(height: KFSpacing.space2),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: KFIconSizes.sm,
                  color: KFColors.gray500,
                ),
                const SizedBox(width: KFSpacing.space1),
                Text(
                  _formatDateRange(),
                  style: const TextStyle(
                    fontSize: KFTypography.fontSizeSm,
                    color: KFColors.gray600,
                  ),
                ),
              ],
            ),
          ],
          if (reason != null) ...[
            const SizedBox(height: KFSpacing.space2),
            Text(
              reason!,
              style: const TextStyle(
                fontSize: KFTypography.fontSizeSm,
                color: KFColors.gray500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (onApprove != null || onReject != null) ...[
            const SizedBox(height: KFSpacing.space4),
            Row(
              children: [
                if (onReject != null)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onReject,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: KFColors.error600,
                        side: const BorderSide(color: KFColors.error600),
                      ),
                      child: const Text('Reject'),
                    ),
                  ),
                if (onApprove != null && onReject != null)
                  const SizedBox(width: KFSpacing.space3),
                if (onApprove != null)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onApprove,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: KFColors.success600,
                        foregroundColor: KFColors.white,
                      ),
                      child: const Text('Approve'),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(StatusType status) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case StatusType.pending:
        bgColor = KFColors.warning100;
        textColor = KFColors.warning700;
        label = 'Pending';
        break;
      case StatusType.approved:
        bgColor = KFColors.success100;
        textColor = KFColors.success700;
        label = 'Approved';
        break;
      case StatusType.rejected:
        bgColor = KFColors.error100;
        textColor = KFColors.error700;
        label = 'Rejected';
        break;
      default:
        bgColor = KFColors.gray100;
        textColor = KFColors.gray600;
        label = 'Unknown';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: KFRadius.radiusFull,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: KFTypography.fontSizeXs,
          fontWeight: KFTypography.medium,
          color: textColor,
        ),
      ),
    );
  }
}

/// Notification card
class KFNotificationCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;
  final String? time;
  final DateTime? timestamp;
  final bool isRead;
  final VoidCallback? onTap;

  const KFNotificationCard({
    super.key,
    required this.icon,
    this.iconColor = KFColors.primary600,
    required this.title,
    required this.message,
    this.time,
    this.timestamp,
    this.isRead = false,
    this.onTap,
  });

  String _formatTimestamp(DateTime ts) {
    final now = DateTime.now();
    final diff = now.difference(ts);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${ts.day} ${months[ts.month - 1]}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayTime = time ?? (timestamp != null ? _formatTimestamp(timestamp!) : '');

    return KFCard(
      onTap: onTap,
      backgroundColor: isRead ? null : KFColors.primary50,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: KFIconSizes.md),
          ),
          const SizedBox(width: KFSpacing.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: KFTypography.fontSizeBase,
                    fontWeight:
                        isRead ? KFTypography.regular : KFTypography.semibold,
                  ),
                ),
                const SizedBox(height: KFSpacing.space1),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: KFTypography.fontSizeSm,
                    color: KFColors.gray600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: KFSpacing.space2),
                Text(
                  displayTime,
                  style: const TextStyle(
                    fontSize: KFTypography.fontSizeXs,
                    color: KFColors.gray400,
                  ),
                ),
              ],
            ),
          ),
          if (!isRead)
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: KFColors.primary600,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}
