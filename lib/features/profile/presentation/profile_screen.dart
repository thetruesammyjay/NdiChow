import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/basil_icon.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) => SafeArea(
    child: ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
      children: [
        Text('Profile', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 24),
        const CircleAvatar(
          radius: 42,
          child: BasilIcon('user-solid', size: 44),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            'Welcome to NdiChow',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        const SizedBox(height: 28),
        const _ProfileTile(icon: 'location-outline', title: 'Saved addresses'),
        const _ProfileTile(icon: 'card-outline', title: 'Payment methods'),
        const _ProfileTile(icon: 'heart-outline', title: 'Favorites'),
        const _ProfileTile(icon: 'headset-outline', title: 'Help and support'),
        const _ProfileTile(icon: 'settings-outline', title: 'Settings'),
        const SizedBox(height: 20),
        const Text(
          'Basil icons by Craftwork • CC BY 4.0',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
        ),
      ],
    ),
  );
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({required this.icon, required this.title});
  final String icon;
  final String title;
  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 10),
    child: ListTile(
      leading: BasilIcon(icon),
      title: Text(title),
      trailing: const BasilIcon('caret-right-outline'),
      onTap: () {},
    ),
  );
}
