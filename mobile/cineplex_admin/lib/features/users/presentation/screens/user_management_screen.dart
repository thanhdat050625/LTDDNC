import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_shared/mobile_shared.dart';
import '../cubit/user_management_cubit.dart';
import '../widgets/create_staff_bottom_sheet.dart';
import '../widgets/user_card_item.dart';
import '../widgets/user_detail_bottom_sheet.dart';

class UserManagementScreen extends StatefulWidget {
  final Widget? drawer;
  const UserManagementScreen({super.key, this.drawer});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    context.read<UserManagementCubit>().loadUsers();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      if (mounted) {
        context.read<UserManagementCubit>().searchUsers(query.trim());
      }
    });
  }

  void _confirmToggleStatus(
    BuildContext context,
    UserModel user,
    AppLocalizations l10n,
    CineplexColors theme,
  ) {
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
              final success = await cubit.toggleUserStatus(
                user.id,
                user.status,
              );
              if (mounted && success) {
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

  Future<void> _openAddStaffModal(BuildContext context, AppLocalizations l10n, CineplexColors theme) async {
    final messenger = ScaffoldMessenger.of(context);
    final created = await CreateStaffBottomSheet.show(context);
    if (created == true && mounted) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.staffCreatedSuccess),
          backgroundColor: theme.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context).extension<CineplexColors>()!;

    return AppScaffold(
      title: l10n.userManagement,
      drawer: widget.drawer,
      body: Column(
        children: [
          // Top Bar: Search Bar & Add Staff Button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(color: theme.textPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: l10n.searchUser,
                      hintStyle: TextStyle(color: theme.textSecondary.withValues(alpha: 0.7), fontSize: 13),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                      prefixIcon: Icon(LucideIcons.search, size: 18, color: theme.textSecondary),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(LucideIcons.x, size: 16, color: theme.textSecondary),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                                context.read<UserManagementCubit>().searchUsers('');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: theme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: theme.textSecondary.withValues(alpha: 0.15),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: theme.textSecondary.withValues(alpha: 0.15),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: theme.primary,
                          width: 1.5,
                        ),
                      ),
                    ),
                    onChanged: (val) {
                      setState(() {});
                      _onSearchChanged(val);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                // Add Staff Button
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => _openAddStaffModal(context, l10n, theme),
                  icon: const Icon(LucideIcons.userPlus, size: 16),
                  label: Text(
                    l10n.addStaff,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),

          // Main Content
          Expanded(
            child: BlocBuilder<UserManagementCubit, UserManagementState>(
              builder: (context, state) {
                if (state is UserManagementLoading) {
                  return const Center(child: AppLoading());
                }

                if (state is UserManagementError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.alertTriangle, size: 48, color: theme.error),
                          const SizedBox(height: 12),
                          Text(
                            state.message,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: theme.textSecondary),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () => context.read<UserManagementCubit>().loadUsers(),
                            icon: const Icon(LucideIcons.rotateCcw, size: 16),
                            label: Text(l10n.retry),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (state is UserManagementLoaded) {
                  return RefreshIndicator(
                    onRefresh: () => context.read<UserManagementCubit>().loadUsers(),
                    color: theme.primary,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                      children: [
                        // Stats Overview Banner (4 cards)
                        _buildStatsOverview(context, state, theme, l10n),
                        const SizedBox(height: 12),

                        // Role Tabs (All, Customer, Staff)
                        _buildRoleTabs(context, state, theme, l10n),
                        const SizedBox(height: 10),

                        // Status Filter Chips (All, Active, Blocked)
                        _buildStatusChips(context, state, theme, l10n),
                        const SizedBox(height: 6),

                        // Inline loading bar during filter/search to prevent full-screen flashing
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: state.isFiltering
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(2),
                                    child: LinearProgressIndicator(
                                      minHeight: 3,
                                      backgroundColor: theme.textSecondary.withValues(alpha: 0.1),
                                      valueColor: AlwaysStoppedAnimation<Color>(theme.primary),
                                    ),
                                  ),
                                )
                              : const SizedBox(height: 11),
                        ),

                        // List of Users / Staff
                        if (state.users.isEmpty)
                          state.isFiltering
                              ? const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 48),
                                  child: Center(child: AppLoading()),
                                )
                              : _buildEmptyState(context, state, theme, l10n)
                        else ...[
                          AnimatedOpacity(
                            opacity: state.isFiltering ? 0.5 : 1.0,
                            duration: const Duration(milliseconds: 150),
                            child: Column(
                              children: state.users.map((user) {
                                return UserCardItem(
                                  user: user,
                                  isUpdating: state.updatingUserId == user.id,
                                  onToggleStatus: () => _confirmToggleStatus(context, user, l10n, theme),
                                  onTap: () => UserDetailBottomSheet.show(context, user),
                                );
                              }).toList(),
                            ),
                          ),

                          // Pagination Controls
                          const SizedBox(height: 8),
                          _buildPaginationBar(context, state, theme, l10n),
                        ],
                      ],
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  // Stats Grid Overview
  Widget _buildStatsOverview(
    BuildContext context,
    UserManagementLoaded state,
    CineplexColors theme,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.textSecondary.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          _buildStatItem(
            theme,
            label: l10n.totalAccounts,
            value: state.totalAll.toString(),
            icon: LucideIcons.users,
            iconColor: theme.textPrimary,
          ),
          _buildVerticalDivider(theme),
          _buildStatItem(
            theme,
            label: l10n.tabCustomers,
            value: state.totalCustomers.toString(),
            icon: LucideIcons.user,
            iconColor: const Color(0xFFD946EF),
          ),
          _buildVerticalDivider(theme),
          _buildStatItem(
            theme,
            label: l10n.tabStaff,
            value: state.totalStaff.toString(),
            icon: LucideIcons.userCheck,
            iconColor: const Color(0xFF3A86FF),
          ),
          _buildVerticalDivider(theme),
          _buildStatItem(
            theme,
            label: l10n.statusBlocked,
            value: state.totalBlocked.toString(),
            icon: LucideIcons.lock,
            iconColor: theme.error,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    CineplexColors theme, {
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 13, color: iconColor),
              const SizedBox(width: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: theme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider(CineplexColors theme) {
    return Container(
      width: 1,
      height: 24,
      color: theme.textSecondary.withValues(alpha: 0.15),
    );
  }

  // Role Segmented Tabs (Tất cả, Khách hàng, Nhân viên)
  Widget _buildRoleTabs(
    BuildContext context,
    UserManagementLoaded state,
    CineplexColors theme,
    AppLocalizations l10n,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.textSecondary.withValues(alpha: 0.12),
        ),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _buildRoleTabButton(
            context,
            title: l10n.tabAll,
            isSelected: state.selectedRole == null,
            onTap: () => context.read<UserManagementCubit>().setRoleFilter(null),
            theme: theme,
          ),
          _buildRoleTabButton(
            context,
            title: l10n.tabCustomers,
            count: state.totalCustomers,
            isSelected: state.selectedRole == 'CUSTOMER',
            onTap: () => context.read<UserManagementCubit>().setRoleFilter('CUSTOMER'),
            theme: theme,
          ),
          _buildRoleTabButton(
            context,
            title: l10n.tabStaff,
            count: state.totalStaff,
            isSelected: state.selectedRole == 'STAFF',
            onTap: () => context.read<UserManagementCubit>().setRoleFilter('STAFF'),
            theme: theme,
          ),
        ],
      ),
    );
  }

  Widget _buildRoleTabButton(
    BuildContext context, {
    required String title,
    int? count,
    required bool isSelected,
    required VoidCallback onTap,
    required CineplexColors theme,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? theme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            count != null ? '$title ($count)' : title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.white : theme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  // Status Filter Chips (Tất cả, Hoạt động, Đã khóa)
  Widget _buildStatusChips(
    BuildContext context,
    UserManagementLoaded state,
    CineplexColors theme,
    AppLocalizations l10n,
  ) {
    return Row(
      children: [
        _buildChip(
          label: l10n.statusAll,
          isSelected: state.selectedStatus == null,
          onTap: () => context.read<UserManagementCubit>().setStatusFilter(null),
          theme: theme,
        ),
        const SizedBox(width: 8),
        _buildChip(
          label: l10n.statusActive,
          isSelected: state.selectedStatus == 'ACTIVE',
          onTap: () => context.read<UserManagementCubit>().setStatusFilter('ACTIVE'),
          theme: theme,
          activeColor: theme.success,
        ),
        const SizedBox(width: 8),
        _buildChip(
          label: l10n.statusBlocked,
          isSelected: state.selectedStatus == 'BLOCKED',
          onTap: () => context.read<UserManagementCubit>().setStatusFilter('BLOCKED'),
          theme: theme,
          activeColor: theme.error,
        ),
      ],
    );
  }

  Widget _buildChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required CineplexColors theme,
    Color? activeColor,
  }) {
    final chipColor = activeColor ?? theme.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? chipColor.withValues(alpha: 0.15) : theme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? chipColor : theme.textSecondary.withValues(alpha: 0.15),
            width: isSelected ? 1.2 : 0.8,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? chipColor : theme.textSecondary,
          ),
        ),
      ),
    );
  }

  // Empty State
  Widget _buildEmptyState(
    BuildContext context,
    UserManagementLoaded state,
    CineplexColors theme,
    AppLocalizations l10n,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: theme.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.textSecondary.withValues(alpha: 0.15),
                ),
              ),
              child: Icon(LucideIcons.userX, size: 28, color: theme.textSecondary),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.noMatchingUsers,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.primary,
                side: BorderSide(color: theme.primary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                _searchController.clear();
                setState(() {});
                context.read<UserManagementCubit>().loadUsers(
                  page: 1,
                  clearRole: true,
                  clearStatus: true,
                  keyword: '',
                );
              },
              icon: const Icon(LucideIcons.rotateCcw, size: 14),
              label: Text(l10n.resetFilters, style: const TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  // Pagination Bar
  Widget _buildPaginationBar(
    BuildContext context,
    UserManagementLoaded state,
    CineplexColors theme,
    AppLocalizations l10n,
  ) {
    final canGoPrev = state.page > 1;
    final canGoNext = state.page < state.totalPages;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.textSecondary.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Prev Button
          IconButton(
            icon: Icon(
              LucideIcons.chevronLeft,
              color: canGoPrev ? theme.textPrimary : theme.textSecondary.withValues(alpha: 0.3),
            ),
            onPressed: canGoPrev
                ? () => context.read<UserManagementCubit>().goToPage(state.page - 1)
                : null,
            tooltip: l10n.prevPage,
          ),

          // Page Indicator
          Text(
            l10n.pageIndicator(state.page, state.totalPages),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: theme.textPrimary,
            ),
          ),

          // Next Button
          IconButton(
            icon: Icon(
              LucideIcons.chevronRight,
              color: canGoNext ? theme.textPrimary : theme.textSecondary.withValues(alpha: 0.3),
            ),
            onPressed: canGoNext
                ? () => context.read<UserManagementCubit>().goToPage(state.page + 1)
                : null,
            tooltip: l10n.nextPage,
          ),
        ],
      ),
    );
  }
}
