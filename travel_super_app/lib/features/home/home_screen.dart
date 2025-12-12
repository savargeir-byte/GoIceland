import 'package:flutter/material.dart';

import '../../core/theme/color_palette.dart';
import '../../core/widgets/bottom_sheet.dart';
import '../../core/widgets/custom_card.dart';
import '../../data/api/poi_api.dart';
import '../../data/models/poi_model.dart';
import '../map/pin_details_sheet.dart';
import '../weather/weather_banner.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _poiApi = PoiApi();
  late Future<List<PoiModel>> _featuredFuture;

  @override
  void initState() {
    super.initState();
    _featuredFuture = _poiApi.fetchFeatured();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: const Text('Fresh Explorer'),
            actions: const [CircleAvatar(child: Icon(Icons.person))],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  WeatherBanner(),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: const [
                  _CategoryChip(label: 'Food', icon: Icons.restaurant),
                  _CategoryChip(label: 'Photo', icon: Icons.photo_camera),
                  _CategoryChip(label: 'Nature', icon: Icons.terrain),
                  _CategoryChip(label: 'Wellness', icon: Icons.spa),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: Text('Today’s picks', style: Theme.of(context).textTheme.titleMedium),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 240,
              child: FutureBuilder<List<PoiModel>>(
                future: _featuredFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final pois = snapshot.data!;
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (_, index) => _PoiCard(
                      poi: pois[index],
                      onTap: () => _openPoi(pois[index]),
                    ),
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemCount: pois.length,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openPoi(PoiModel poi) {
    AppBottomSheet.show(
      context: context,
      child: PinDetailsSheet(poi: poi),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: FilterChip(
        label: Text(label),
        avatar: Icon(icon, size: 18),
        onSelected: (_) {},
      ),
    );
  }
}

class _PoiCard extends StatelessWidget {
  const _PoiCard({required this.poi, this.onTap});

  final PoiModel poi;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: CustomCard(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  poi.image ?? '',
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(color: ColorPalette.background),
                  loadingBuilder: (_, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      alignment: Alignment.center,
                      color: ColorPalette.background,
                      child: const CircularProgressIndicator(),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(poi.name, style: Theme.of(context).textTheme.titleMedium),
            Text(poi.type.toUpperCase(), style: Theme.of(context).textTheme.labelSmall),
            Row(
              children: [
                const Icon(Icons.star, size: 16, color: Colors.amber),
                const SizedBox(width: 4),
                Text('${poi.rating ?? 'New'}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
