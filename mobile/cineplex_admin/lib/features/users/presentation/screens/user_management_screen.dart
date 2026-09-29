import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_shared/mobile_shared.dart';
import '../cubit/user_management_cubit.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<UserManagementCubit>().loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _confirmToggleStatus(
    BuildContext context,
    Map<String, dynamic> user,
    AppLocalizations l10n,
  ) {
    final isBlocked = user['status'] == 'BLOCKED';
    final name = user['fullName'] ?? user['name'] ?? user['email'] ?? 'User';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isBlocked ? l10n.unblockUser : l10n.blockUser),
        content: Text(
          isBlocked
              ? l10n.confirmUnblockUserWithName(name)
              : l10n.confirmBlockUserWithName(name),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isBlocked ? Colors.green.shade700 : Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final primaryColor = Theme.of(context).colorScheme.primary;
              Navigator.pop(ctx);
              final success = await context.read<UserManagementCubit>().toggleUserStatus(
                    user['id'] is int ? user['id'] : int.parse(user['id'].toString()),
                    user['status'] ?? 'ACTIVE',
                  );
              if (mounted && success) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(l10n.userStatusUpdated),
                    backgroundColor: primaryColor,
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
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return AppScaffold(
      title: l10n.userManagement,
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.searchUser,
                isDense: true,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          context.read<UserManagementCubit>().loadUsers();
                          setState(() {});
                        },
                      )
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (val) {
                setState(() {});
                context.read<UserManagementCubit>().searchUsers(val);
              },
            ),
          ),

          // User List
          Expanded(
            child: BlocBuilder<UserManagementCubit, UserManagementState>(
              builder: (context, state) {
                if (state is UserManagementLoading) return const AppLoading();
                if (state is UserManagementLoaded) {
                  final users = state.users;
                  final totalUsers = users.length;
                  final blockedUsers = users.where((u) => u['status'] == 'BLOCKED').length;

                  return RefreshIndicator(
                    onRefresh: () => context.read<UserManagementCubit>().loadUsers(),
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        // Summary Banner
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text(
                                l10n.totalUsersCount(totalUsers),
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                              ),
                              Container(height: 16, width: 1, color: colorScheme.outlineVariant),
                              Text(
                                l10n.blockedUsersCount(blockedUsers),
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: blockedUsers > 0 ? colorScheme.error : colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),

                        if (users.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            child: Center(
                              child: Text(
                                state.isSearching
                                    ? l10n.noMatchingUsers
                                    : l10n.noData,
                                style: TextStyle(color: colorScheme.onSurfaceVariant),
                              ),
                            ),
                          )
                        else
                          ...users.map((user) {
                            final name = user['fullName'] ?? user['name'] ?? 'No Name';
                            final email = user['email'] ?? '';
                            final phone = user['phone'] ?? '';
                            final role = (user['role'] ?? 'CUSTOMER').toString().toUpperCase();
                            final status = user['status'] ?? 'ACTIVE';
                            final isBlocked = status == 'BLOCKED';
                            final isUpdating = state.updatingUserId == user['id'];

                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              elevation: 0,
                              color: colorScheme.surfaceContainerLow,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: 22,
                                      backgroundColor: isBlocked
                                          ? colorScheme.errorContainer
                                          : colorScheme.primaryContainer,
                                      child: Text(
                                        name.isNotEmpty ? name[0].toUpperCase() : 'U',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: isBlocked
                                              ? colorScheme.onErrorContainer
                                              : colorScheme.onPrimaryContainer,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  name,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: colorScheme.secondaryContainer,
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  role,
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: colorScheme.onSecondaryContainer,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            email,
                                            style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                                          ),
                                          if (phone.isNotEmpty)
                                            Text(
                                              phone,
                                              style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                                            ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),

                                    // Action Button (Block/Unblock)
                                    if (isUpdating)
                                      const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    else
                                      OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          visualDensity: VisualDensity.compact,
                                          foregroundColor: isBlocked ? Colors.green.shade700 : colorScheme.error,
                                          side: BorderSide(
                                            color: isBlocked ? Colors.green.shade700 : colorScheme.error,
                                          ),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        ),
                                        onPressed: () => _confirmToggleStatus(context, user, l10n),
                                        child: Text(
                                          isBlocked ? l10n.unblockUser : l10n.blockUser,
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          }),
                      ],
                    ),
                  );
                }
                if (state is UserManagementError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(state.message, textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => context.read<UserManagementCubit>().loadUsers(),
                          child: Text(l10n.retry),
                        ),
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
}
