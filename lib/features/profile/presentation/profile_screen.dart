import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) => SafeArea(
    child: ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
      children: [
        Text('Profile', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 24),
        const CircleAvatar(radius: 42, child: Icon(Icons.person_rounded, size: 44)),
        const SizedBox(height: 12),
        Center(child: Text('Welcome to NdiChow', style: Theme.of(context).textTheme.titleLarge)),
        const SizedBox(height: 28),
        const _ProfileTile(icon: Icons.location_on_outlined, title: 'Saved addresses'),
        const _ProfileTile(icon: Icons.credit_card_outlined, title: 'Payment methods'),
        const _ProfileTile(icon: Icons.favorite_border_rounded, title: 'Favorites'),
        const _ProfileTile(icon: Icons.help_outline_rounded, title: 'Help and support'),
        const _ProfileTile(icon: Icons.settings_outlined, title: 'Settings'),
      ],
    ),
  );
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({required this.icon, required this.title});
  final IconData icon;
  final String title;
  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 10),
    child: ListTile(leading: Icon(icon), title: Text(title), trailing: const Icon(Icons.chevron_right_rounded), onTap: () {}),
  );
}
