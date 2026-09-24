import 'package:flutter/material.dart';
import '../../core/api.dart';
import '../../core/models.dart';
import '../../widgets/common.dart';
import '../detail/detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});
  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<PListing> _items = [];
  bool _loading = true;
  String? _error;

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final res = await PamojiApi.myFavorites();
      if (mounted) {
        setState(() => _items = (res['favorites'] as List)
            .map((e) => PListing.fromJson(e as Map<String, dynamic>))
            .toList());
      }
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void initState() { super.initState(); _load(); }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('My favorites')),
        body: _error != null
            ? ErrorRetry(message: _error!, onRetry: _load)
            : _loading
                ? const Center(child: CircularProgressIndicator())
                : _items.isEmpty
                    ? const EmptyState(icon: Icons.favorite_outline, title: 'No favorites yet', subtitle: 'Tap the heart on a listing to save it here.')
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 0.68),
                        itemCount: _items.length,
                        itemBuilder: (context, i) => ListingCard(
                          listing: _items[i],
                          onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => DetailScreen(listingId: _items[i].id))),
                        ),
                      ),
      );
}
