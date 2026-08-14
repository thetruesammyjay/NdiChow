import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/basil_icon.dart';
import '../../auth/application/auth_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final customer = auth.customer!;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
        children: [
          Text('Profile', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 24),
          const CircleAvatar(
            radius: 42,
            backgroundColor: AppColors.primaryContainer,
            child: BasilIcon('user-solid', size: 44, color: AppColors.primary),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              customer.name,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              customer.email,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 28),
          const _ProfileTile(
            icon: 'location-outline',
            title: 'Delivery addresses',
            subtitle: 'Saved addresses arrive with the next backend phase',
          ),
          const _ProfileTile(
            icon: 'headset-outline',
            title: 'Help and support',
            subtitle: 'Support channels coming soon',
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: auth.isSubmitting ? null : auth.logout,
            icon: const Icon(Icons.logout),
            label: const Text('Sign out'),
          ),
          const SizedBox(height: 24),
          const Text(
            'Basil icons by Craftwork • CC BY 4.0',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final String icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 10),
    child: ListTile(
      leading: BasilIcon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
    ),
  );
}
