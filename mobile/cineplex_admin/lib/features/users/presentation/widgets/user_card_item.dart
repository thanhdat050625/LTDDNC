import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_shared/mobile_shared.dart';

class UserCardItem extends StatelessWidget {
  final UserModel user;
  final bool isUpdating;
  final VoidCallback onToggleStatus;
  final VoidCallback onTap;

  const UserCardItem({
    super.key,
    required this.user,
    required this.isUpdating,
    required this.onToggleStatus,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = CineplexColors.of(context);
    final l10n = AppLocalizations.of(context)!;

    final isBlocked = user.isBlocked;
    final name = user.fullName.isNotEmpty ? user.fullName : (user.email.isNotEmpty ? user.email : 'User');
    final firstLetter = name.isNotEmpty ? name[0].toUpperCase() : 'U';

    Color roleColor;
    String roleLabel;
    IconData roleIcon;

    if (user.isAdmin) {
      roleColor = const Color(0xFFE58E26); // Amber Gold
      roleLabel = l10n.adminRole;
      roleIcon = LucideIcons.shieldCheck;
    } else if (user.isStaff) {
      roleColor = const Color(0xFF3A86FF); // Tech IMAX Blue
      roleLabel = l10n.staffRole;
      roleIcon = LucideIcons.userCheck;
    } else {
      roleColor = const Color(0xFFD946EF); // Customer Orchid
      roleLabel = l10n.customerRole;
      roleIcon = LucideIcons.user;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: theme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.textSecondary.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar with initials and role indicator ring
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isBlocked
                            ? theme.error.withValues(alpha: 0.6)
                            : roleColor.withValues(alpha: 0.8),
                        width: 2,
                      ),
                      color: isBlocked
                          ? theme.error.withValues(alpha: 0.12)
                          : roleColor.withValues(alpha: 0.12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      firstLetter,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isBlocked ? theme.error : roleColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // User Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: theme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        // Role Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: roleColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: roleColor.withValues(alpha: 0.3),
                              width: 0.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(roleIcon, size: 11, color: roleColor),
                              const SizedBox(width: 3),
                              Flexible(
                                child: Text(
                                  roleLabel,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: roleColor,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 3),

                        // Email
                        Row(
                          children: [
                            Icon(
                              LucideIcons.mail,
                              size: 13,
                              color: theme.textSecondary.withValues(alpha: 0.7),
                            ),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                user.email,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Phone (if present)
                        if (user.phone != null && user.phone!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                LucideIcons.phone,
                                size: 13,
                                color: theme.textSecondary.withValues(alpha: 0.7),
                              ),
                              const SizedBox(width: 5),
                              Flexible(
                                child: Text(
                                  user.phone!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: theme.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isBlocked
                          ? theme.error.withValues(alpha: 0.12)
                          : theme.success.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isBlocked
                            ? theme.error.withValues(alpha: 0.3)
                            : theme.success.withValues(alpha: 0.3),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isBlocked ? theme.error : theme.success,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          isBlocked ? l10n.statusBlocked : l10n.statusActive,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isBlocked ? theme.error : theme.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),
              Divider(
                height: 1,
                color: theme.textSecondary.withValues(alpha: 0.08),
              ),
              const SizedBox(height: 8),

              // Bottom Row: Details hint + Quick Action Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Extra info (Points or Created Date)
                  Expanded(
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        if (user.isCustomer && user.loyaltyPoints > 0)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(LucideIcons.star, size: 13, color: Color(0xFFE58E26)),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  '${user.loyaltyPoints} ${l10n.pointsSuffix}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFE58E26),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        if (user.createdAt != null)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                LucideIcons.calendar,
                                size: 12,
                                color: theme.textSecondary.withValues(alpha: 0.6),
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  FormatUtils.formatDate(user.createdAt!),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: theme.textSecondary.withValues(alpha: 0.8),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Toggle Status Button
                  if (isUpdating)
                    SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.primary,
                      ),
                    )
                  else
                    InkWell(
                      onTap: onToggleStatus,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 36, minWidth: 44),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isBlocked
                              ? theme.success.withValues(alpha: 0.1)
                              : theme.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isBlocked
                                ? theme.success.withValues(alpha: 0.3)
                                : theme.error.withValues(alpha: 0.3),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isBlocked ? LucideIcons.unlock : LucideIcons.lock,
                              size: 13,
                              color: isBlocked ? theme.success : theme.error,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isBlocked ? l10n.unblockUser : l10n.blockUser,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isBlocked ? theme.success : theme.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
