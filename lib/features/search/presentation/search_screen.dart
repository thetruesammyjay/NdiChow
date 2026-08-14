import 'package:flutter/material.dart';

import '../../../shared/models/restaurant.dart';
import '../../../shared/widgets/basil_icon.dart';
import '../../../shared/widgets/restaurant_card.dart';
import '../../home/data/home_repository.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, required this.repository});

  final HomeRepository repository;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  Future<List<Restaurant>>? _results;

  void _search(String query) {
    setState(() {
      _results = widget.repository.getNearbyRestaurants(query: query);
    });
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
      children: [
        Text(
          'Find your next meal',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 18),
        TextField(
          textInputAction: TextInputAction.search,
          onSubmitted: _search,
          decoration: const InputDecoration(
            prefixIcon: BasilIcon('search-outline'),
            hintText: 'Jollof, shawarma, restaurant…',
          ),
        ),
        const SizedBox(height: 28),
        Text('Popular searches', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final query in const ['Jollof rice', 'Chicken', 'Shawarma'])
              ActionChip(label: Text(query), onPressed: () => _search(query)),
            const Chip(label: Text('Under ₦5,000')),
          ],
        ),
        const SizedBox(height: 20),
        if (_results != null)
          FutureBuilder<List<Restaurant>>(
            future: _results,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Text('Search failed. Please try again.');
              }
              final restaurants = snapshot.data ?? const <Restaurant>[];
              if (restaurants.isEmpty) {
                return const Text('No restaurants found.');
              }
              return Column(
                children: restaurants
                    .map((restaurant) => RestaurantCard(restaurant: restaurant))
                    .toList(growable: false),
              );
            },
          ),
      ],
    ),
  );
}
