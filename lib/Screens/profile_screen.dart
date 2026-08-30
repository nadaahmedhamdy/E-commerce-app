import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/favourites_provider.dart';
import '../utils/app_colors.dart';
import '../utils/app_routes.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _handleSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign Out', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    context.read<CartProvider>().bindToUser(null);
    context.read<FavoritesProvider>().bindToUser(null);
    await context.read<AuthProvider>().signOut();

    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final name = auth.userProfile?.name ?? auth.firebaseUser?.displayName ?? 'User';
    final email = auth.userProfile?.email ?? auth.firebaseUser?.email ?? '';
    final photoUrl = auth.userProfile?.photoUrl ?? auth.firebaseUser?.photoURL ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: AppColors.primary.withOpacity(0.15),
                    backgroundImage: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                    child: photoUrl.isEmpty
                        ? const Icon(Icons.person, size: 44, color: AppColors.primary)
                        : null,
                  ),
                  const SizedBox(height: 14),
                  Text(name,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  if (email.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(email,
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _ProfileTile(icon: Icons.person_outline, label: 'Profile', onTap: () {}),
            _ProfileTile(icon: Icons.settings_outlined, label: 'Setting', onTap: () {}),
            _ProfileTile(icon: Icons.mail_outline, label: 'Contact', onTap: () {}),
            _ProfileTile(icon: Icons.ios_share, label: 'Share App', onTap: () {}),
            _ProfileTile(icon: Icons.help_outline, label: 'Help', onTap: () {}),
            const SizedBox(height: 30),
            Center(
              child: TextButton(
                onPressed: () => _handleSignOut(context),
                child: const Text('Sign Out',
                    style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ProfileTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.textPrimary),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
