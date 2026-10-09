import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_shared/mobile_shared.dart';
import '../cubit/user_management_cubit.dart';

class UserDetailBottomSheet extends StatelessWidget {
  final UserModel user;

  const UserDetailBottomSheet({super.key, required this.user});

  static void show(BuildContext context, UserModel user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<UserManagementCubit>(),
        child: UserDetailBottomSheet(user: user),
      ),
    );
  }

  void _confirmToggle(BuildContext context, AppLocalizations l10n, CineplexColors theme) {
    final isBlocked = user.isBlocked;
    final name = user.fullName.isNotEmpty ? user.fullName : user.email;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        actionsPadding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
        title: Text(
          isBlocked ? l10n.unblockUser : l10n.blockUser,
          style: TextStyle(color: theme.textPrimary, fontWeight: FontWeight.bold),
        ),
        content: Text(
          isBlocked
              ? l10n.confirmUnblockUserWithName(name)
              : l10n.confirmBlockUserWithName(name),
          style: TextStyle(color: theme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel, style: TextStyle(color: theme.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isBlocked ? theme.success : theme.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              final cubit = context.read<UserManagementCubit>();
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(ctx);
              Navigator.pop(context); // close bottom sheet
              final success = await cubit.toggleUserStatus(
                user.id,
                user.status,
              );
              if (success) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(l10n.userStatusUpdated),
                    backgroundColor: theme.primary,
                  ),
                );
              }
            },
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }

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
      roleColor = const Color(0xFFE58E26);
      roleLabel = l10n.adminRole;
      roleIcon = LucideIcons.shieldCheck;
    } else if (user.isStaff) {
      roleColor = const Color(0xFF3A86FF);
      roleLabel = l10n.staffRole;
      roleIcon = LucideIcons.userCheck;
    } else {
      roleColor = const Color(0xFFD946EF);
      roleLabel = l10n.customerRole;
      roleIcon = LucideIcons.user;
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(
          top: BorderSide(
            color: theme.textSecondary.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: theme.textSecondary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header with Title & Close
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  l10n.accountDetailsTitle,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(LucideIcons.x, color: theme.textSecondary, size: 20),
                tooltip: l10n.close,
                constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                padding: const EdgeInsets.all(8),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Avatar & Basic Info Card
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.textSecondary.withValues(alpha: 0.12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: roleColor, width: 2),
                    color: roleColor.withValues(alpha: 0.15),
                  ),
                  alignment: Alignment.center,
                  child: ClipOval(
                    child: user.avatar != null && user.avatar!.isNotEmpty
                        ? AppCachedImage(
                            imageUrl: user.avatar!,
                            width: 44,
                            height: 44,
                            fit: BoxFit.cover,
                          )
                        : Text(
                            firstLetter,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: roleColor,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: theme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        user.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          // Role Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: roleColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(roleIcon, size: 10, color: roleColor),
                                const SizedBox(width: 3),
                                Text(
                                  roleLabel,
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: roleColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Status Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isBlocked
                                  ? theme.error.withValues(alpha: 0.15)
                                  : theme.success.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              isBlocked ? l10n.statusBlocked : l10n.statusActive,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: isBlocked ? theme.error : theme.success,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Details List
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.textSecondary.withValues(alpha: 0.12),
              ),
            ),
            child: Column(
              children: [
                _buildInfoRow(
                  theme,
                  icon: LucideIcons.hash,
                  label: l10n.userIdLabel,
                  value: '#${user.id}',
                ),
                _buildDivider(theme),
                _buildInfoRow(
                  theme,
                  icon: LucideIcons.phone,
                  label: l10n.phoneLabel,
                  value: user.phone != null && user.phone!.isNotEmpty ? user.phone! : l10n.notProvided,
                ),
                if (user.isCustomer) ...[
                  _buildDivider(theme),
                  _buildInfoRow(
                    theme,
                    icon: LucideIcons.star,
                    label: l10n.loyaltyPointsTitle,
                    value: '${user.loyaltyPoints} ${l10n.pointsSuffix}',
                    valueColor: const Color(0xFFE58E26),
                  ),
                ],
                _buildDivider(theme),
                _buildInfoRow(
                  theme,
                  icon: LucideIcons.user,
                  label: l10n.genderLabel,
                  value: user.gender != null && user.gender!.isNotEmpty ? user.gender! : l10n.notProvided,
                ),
                _buildDivider(theme),
                _buildInfoRow(
                  theme,
                  icon: LucideIcons.calendar,
                  label: l10n.dobLabel,
                  value: user.dateOfBirth != null
                      ? FormatUtils.formatDate(user.dateOfBirth!)
                      : l10n.notProvided,
                ),
                _buildDivider(theme),
                _buildInfoRow(
                  theme,
                  icon: LucideIcons.clock,
                  label: l10n.joinedDateLabel,
                  value: user.createdAt != null
                      ? FormatUtils.formatDate(user.createdAt!)
                      : l10n.notProvided,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Bottom Action: Toggle Status
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: isBlocked
                    ? theme.success
                    : theme.error,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => _confirmToggle(context, l10n, theme),
              icon: Icon(isBlocked ? LucideIcons.unlock : LucideIcons.lock, size: 15),
              label: Text(
                isBlocked ? l10n.unblockUser : l10n.blockUser,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    CineplexColors theme, {
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
      child: Row(
        children: [
          Icon(icon, size: 14, color: theme.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: theme.textSecondary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: valueColor ?? theme.textPrimary,
              ),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(CineplexColors theme) {
    return Divider(
      height: 1,
      color: theme.textSecondary.withValues(alpha: 0.08),
    );
  }
}
