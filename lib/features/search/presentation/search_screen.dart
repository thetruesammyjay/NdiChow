import 'package:flutter/material.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) => SafeArea(
    child: ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
      children: [
        Text('Find your next meal', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 18),
        const TextField(autofocus: false, decoration: InputDecoration(prefixIcon: Icon(Icons.search_rounded), hintText: 'Jollof, shawarma, restaurant…')),
        const SizedBox(height: 28),
        Text('Popular searches', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        const Wrap(spacing: 8, runSpacing: 8, children: [Chip(label: Text('Jollof rice')), Chip(label: Text('Chicken')), Chip(label: Text('Shawarma')), Chip(label: Text('Under ₦5,000'))]),
      ],
    ),
  );
}
