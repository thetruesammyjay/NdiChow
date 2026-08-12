import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../shared/models/restaurant.dart';
import '../../../shared/widgets/restaurant_card.dart';
import '../data/home_repository.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.repository});

  final HomeRepository repository;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Restaurant>> _restaurants;

  @override
  void initState() {
    super.initState();
    _restaurants = widget.repository.getNearbyRestaurants();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          setState(() => _restaurants = widget.repository.getNearbyRestaurants());
          await _restaurants;
        },
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
              sliver: SliverList.list(
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: AppColors.primaryContainer,
                        child: Icon(Icons.location_on_rounded, color: AppColors.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Deliver to', style: Theme.of(context).textTheme.bodySmall),
                            const Text('Home • Lagos', style: TextStyle(fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ),
                      IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none_rounded)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text('What are you\nchowing today?', style: Theme.of(context).textTheme.headlineLarge),
                  const SizedBox(height: 18),
                  TextField(
                    readOnly: true,
                    decoration: const InputDecoration(
                      hintText: 'Search dishes and restaurants',
                      prefixIcon: Icon(Icons.search_rounded),
                    ),
                    onTap: () {},
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Your first bite is on us', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
                              const SizedBox(height: 8),
                              const Text('Get 20% off your first NdiChow order.', style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                        const Text('🍛', style: TextStyle(fontSize: 54)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Browse cuisines', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  const _CuisineRow(),
                  const SizedBox(height: 26),
                  Text('Popular near you', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            FutureBuilder<List<Restaurant>>(
              future: _restaurants,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: FilledButton(
                        onPressed: () => setState(() => _restaurants = widget.repository.getNearbyRestaurants()),
                        child: const Text('Try again'),
                      ),
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                  sliver: SliverList.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (_, index) => RestaurantCard(restaurant: snapshot.data![index]),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CuisineRow extends StatelessWidget {
  const _CuisineRow();

  @override
  Widget build(BuildContext context) {
    const cuisines = [('🍚', 'Rice'), ('🍗', 'Chicken'), ('🍔', 'Fast food'), ('🥣', 'Soups')];
    return SizedBox(
      height: 84,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: cuisines.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, index) {
          final item = cuisines[index];
          return Container(
            width: 76,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(children: [Text(item.$1, style: const TextStyle(fontSize: 28)), const Spacer(), Text(item.$2, overflow: TextOverflow.ellipsis)]),
          );
        },
      ),
    );
  }
}
