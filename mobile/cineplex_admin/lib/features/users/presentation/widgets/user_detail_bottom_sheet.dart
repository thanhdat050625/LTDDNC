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
    final theme = Theme.of(context).extension<CineplexColors>()!;
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
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: theme.textSecondary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header with Title & Close
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.accountDetailsTitle,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.textPrimary,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(LucideIcons.x, color: theme.textSecondary, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Avatar & Basic Info Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.textSecondary.withValues(alpha: 0.12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: roleColor, width: 2.5),
                    color: roleColor.withValues(alpha: 0.15),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    firstLetter,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: roleColor,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user.email,
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          // Role Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: roleColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(roleIcon, size: 11, color: roleColor),
                                const SizedBox(width: 3),
                                Text(
                                  roleLabel,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: roleColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Status Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: isBlocked
                                  ? theme.error.withValues(alpha: 0.15)
                                  : theme.success.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isBlocked ? l10n.statusBlocked : l10n.statusActive,
                              style: TextStyle(
                                fontSize: 10,
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
          const SizedBox(height: 14),

          // Details List
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.textSecondary.withValues(alpha: 0.12),
              ),
            ),
            child: Column(
              children: [
                _buildInfoRow(
                  theme,
                  icon: LucideIcons.hash,
                  label: 'ID',
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
          const SizedBox(height: 18),

          // Bottom Action: Toggle Status
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: isBlocked
                    ? theme.success
                    : theme.error,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => _confirmToggle(context, l10n, theme),
              icon: Icon(isBlocked ? LucideIcons.unlock : LucideIcons.lock, size: 16),
              label: Text(
                isBlocked ? l10n.unblockUser : l10n.blockUser,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 4),
      child: Row(
        children: [
          Icon(icon, size: 15, color: theme.textSecondary),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: theme.textSecondary,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: valueColor ?? theme.textPrimary,
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
