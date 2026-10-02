import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_shared/mobile_shared.dart';
import '../cubit/profile_cubit.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().loadProfile();
  }

  void _showLoyaltyPolicyDialog(BuildContext context, Map<String, dynamic> loyalty, AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.stars_rounded, color: Color(0xFFFFB800)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(l10n.loyaltyPolicyTitle),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPolicyItem(
              icon: Icons.card_giftcard,
              color: colorScheme.primary,
              text: l10n.loyaltyPolicyEarn,
            ),
            const SizedBox(height: 12),
            _buildPolicyItem(
              icon: Icons.discount_outlined,
              color: colorScheme.secondary,
              text: l10n.loyaltyPolicyDiscount,
            ),
            const SizedBox(height: 12),
            _buildPolicyItem(
              icon: Icons.fastfood_outlined,
              color: colorScheme.tertiary,
              text: l10n.loyaltyPolicyGifts,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyItem({required IconData icon, required Color color, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, height: 1.4),
          ),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.logout),
        content: Text(l10n.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthBloc>().add(LogoutRequested());
            },
            child: Text(
              l10n.logout,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        final user = state is ProfileLoaded ? state.user : null;

        return AppScaffold(
          title: l10n.profile,
          actions: [
            if (user != null)
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: l10n.editProfile,
                onPressed: () => context.push('/edit-profile', extra: user),
              ),
          ],
          bottomSafeArea: false,
          body: () {
            if (state is ProfileLoading) return const AppLoading();
            if (state is ProfileLoaded) {
              final loyalty = state.loyaltyInfo;
              final role = (user!['role'] ?? 'CUSTOMER').toString().toUpperCase();
              final isStaffOrAdmin = role == 'STAFF' || role == 'ADMIN';

              final fullName = user['fullName'] ?? user['name'] ?? '';
              final email = user['email'] ?? '';
              final phone = user['phone'] ?? '';
              final gender = user['gender'] == 'MALE'
                  ? l10n.male
                  : (user['gender'] == 'FEMALE' ? l10n.female : '');
              final dob = user['dateOfBirth'] != null ? user['dateOfBirth'].toString().split('T').first : '';
              final points = loyalty['loyaltyPoints'] ?? user['loyaltyPoints'] ?? 0;

              return ListView(
                padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).padding.bottom + 16),
                children: [
                  // Header Avatar & Name (Avatar qua trái, thông tin qua phải)
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: colorScheme.primaryContainer,
                        backgroundImage: (user['avatar'] != null && user['avatar'].toString().isNotEmpty)
                            ? NetworkImage(user['avatar'].toString())
                            : null,
                        child: (user['avatar'] != null && user['avatar'].toString().isNotEmpty)
                            ? null
                            : Text(
                                fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onPrimaryContainer,
                                ),
                              ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fullName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              email,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: isStaffOrAdmin ? colorScheme.errorContainer : colorScheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                role,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isStaffOrAdmin ? colorScheme.onErrorContainer : colorScheme.onSecondaryContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Loyalty Card
                  InkWell(
                    onTap: () => _showLoyaltyPolicyDialog(context, loyalty, l10n),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            colorScheme.primaryContainer,
                            colorScheme.surfaceContainerHighest,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.stars_rounded, size: 20, color: Color(0xFFFFB800)),
                                  const SizedBox(width: 6),
                                  Text(
                                    l10n.loyaltyInfo,
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colorScheme.onSurfaceVariant),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '$points ${l10n.pointsSuffix}',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                l10n.info,
                                style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500),
                              ),
                              Icon(Icons.chevron_right, size: 18, color: colorScheme.onSurfaceVariant),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Personal Info Details
                  if (phone.isNotEmpty || gender.isNotEmpty || dob.isNotEmpty)
                    Card(
                      elevation: 0,
                      color: colorScheme.surfaceContainerLow,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
                      ),
                      child: Column(
                        children: [
                          if (phone.isNotEmpty)
                            ListTile(
                              leading: const Icon(Icons.phone_outlined),
                              title: Text(l10n.phone),
                              trailing: Text(phone, style: const TextStyle(fontWeight: FontWeight.w500)),
                            ),
                          if (gender.isNotEmpty)
                            ListTile(
                              leading: const Icon(Icons.person_outline),
                              title: Text(l10n.gender),
                              trailing: Text(gender, style: const TextStyle(fontWeight: FontWeight.w500)),
                            ),
                          if (dob.isNotEmpty)
                            ListTile(
                              leading: const Icon(Icons.calendar_today_outlined),
                              title: Text(l10n.dateOfBirth),
                              trailing: Text(dob, style: const TextStyle(fontWeight: FontWeight.w500)),
                            ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Logout Button
                  ListTile(
                    leading: Icon(Icons.logout, color: colorScheme.error),
                    title: Text(l10n.logout, style: TextStyle(color: colorScheme.error, fontWeight: FontWeight.w600)),
                    onTap: () => _showLogoutDialog(context, l10n),
                  ),
                ],
              );
            }
            if (state is ProfileError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.message, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => context.read<ProfileCubit>().loadProfile(),
                      child: Text(l10n.retry),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }(),
        );
      },
    );
  }
}
