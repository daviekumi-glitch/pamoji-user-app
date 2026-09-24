// Home: search, categories, featured + recent listings (real backend feed).
import 'package:flutter/material.dart';
import '../../core/api.dart';
import '../../core/models.dart';
import '../../core/theme.dart';
import '../../widgets/common.dart';
import '../detail/detail_screen.dart';
import '../favorites/favorites_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? _data;
  String? _error;
  String _query = '';

  Future<void> _load() async {
    setState(() => _error = null);
    try {
      final d = await PamojiApi.home();
      if (mounted) setState(() => _data = d);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  List<PListing> _parse(String key) =>
      ((_data?[key] ?? []) as List).map((e) => PListing.fromJson(e as Map<String, dynamic>)).toList();

  List<Map<String, dynamic>> get _categories =>
      ((_data?['categories'] ?? []) as List).cast<Map<String, dynamic>>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PAMOJI'),
        actions: [
          IconButton(icon: const Icon(Icons.favorite_outline), onPressed: () =>
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FavoritesScreen()))),
          IconButton(icon: const Icon(Icons.logout), tooltip: 'Sign out',
              onPressed: () async { await PamojiApi.logout(); }),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: GestureDetector(
              onTap: () => _openSearch(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                height: 44,
                decoration: BoxDecoration(
                  color: PamojiColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.search, color: PamojiColors.dim),
                    SizedBox(width: 10),
                    Text('Search the marketplace…', style: TextStyle(color: PamojiColors.dim)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: _error != null
          ? ErrorRetry(message: _error!, onRetry: _load)
          : _data == null
              ? _loadingFeed()
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    children: [
                      if (_categories.isNotEmpty) ...[
                        const Text('Categories',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 84,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _categories.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 10),
                            itemBuilder: (context, i) {
                              final c = _categories[i];
                              return GestureDetector(
                                onTap: () => _openSearch(context, categoryId: c['id'] as String, title: c['name'] as String),
                                child: Container(
                                  width: 74,
                                  decoration: BoxDecoration(
                                    color: PamojiColors.surface,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  padding: const EdgeInsets.all(6),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.category, color: PamojiColors.gold, size: 26),
                                      const SizedBox(height: 6),
                                      Text(c['name'] as String,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                      if (_parse('featured').isNotEmpty) _row('Featured', _parse('featured')),
                      if (_parse('recent').isNotEmpty) _row('New in the market', _parse('recent')),
                      if (_parse('featured').isEmpty && _parse('recent').isEmpty)
                        const EmptyState(
                          icon: Icons.storefront,
                          title: 'The marketplace is warming up',
                          subtitle: 'Listings appear here once sellers publish and admins approve them.',
                        ),
                    ],
                  ),
                ),
    );
  }

  Widget _loadingFeed() => ListView(
        padding: const EdgeInsets.all(16),
        children: List.generate(2, (_) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Skeleton(),
            const SizedBox(height: 10),
            Row(children: const [Expanded(child: Skeleton()), SizedBox(width: 10), Expanded(child: Skeleton())]),
          ],
        )),
      );

  Widget _row(String title, List<PListing> items) => Padding(
        padding: const EdgeInsets.only(bottom: 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                TextButton(
                  onPressed: () => _openSearch(context, title: title),
                  child: const Text('See all'),
                ),
              ],
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 0.68),
              itemCount: items.length,
              itemBuilder: (context, i) => ListingCard(
                listing: items[i],
                onTap: () => _openDetail(items[i]),
              ),
            ),
          ],
        ),
      );

  void _openDetail(PListing l) {
    PamojiApi.addRecent(l.id);
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => DetailScreen(listingId: l.id)));
  }

  void _openSearch(BuildContext context, {String? categoryId, String title = 'Search'}) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => _SearchScreen(categoryId: categoryId, title: title, query: _query)));
  }
}

class _SearchScreen extends StatefulWidget {
  final String? categoryId;
  final String title;
  final String query;
  const _SearchScreen({this.categoryId, required this.title, required this.query});
  @override
  State<_SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<_SearchScreen> {
  final _controller = TextEditingController();
  List<PListing> _results = [];
  bool _loading = true;
  String? _error;
  String _sortBy = 'relevance';
  String? _condition;
  String? _location;

  Future<void> _run() async {
    setState(() { _loading = true; _error = null; });
    try {
      final res = await PamojiApi.search(
        query: _controller.text,
        categoryId: widget.categoryId,
        condition: _condition,
        location: _location,
        sortBy: _sortBy,
        limit: 30,
      );
      if (mounted) {
        setState(() => _results = (res['results'] as List)
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
  void initState() {
    super.initState();
    _controller.text = widget.query;
    _run();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onSubmitted: (_) => _run(),
                      decoration: const InputDecoration(hintText: 'What are you looking for?'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(onPressed: _run, icon: const Icon(Icons.search)),
                ],
              ),
            ),
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _chip('Newest', 'newest', _sortBy, (v) => setState(() { _sortBy = v; _run(); })),
                  _chip('Price ↑', 'price_asc', _sortBy, (v) => setState(() { _sortBy = v; _run(); })),
                  _chip('Price ↓', 'price_desc', _sortBy, (v) => setState(() { _sortBy = v; _run(); })),
                  const SizedBox(width: 8, child: VerticalDivider()),
                  for (final c in ['new', 'like_new', 'good', 'fair', 'used'])
                    _chip(c.replaceAll('_', ' '), c, _condition, (v) => setState(() { _condition = _condition == v ? null : v; _run(); })),
                  const SizedBox(width: 8, child: VerticalDivider()),
                  for (final l in ['Blantyre', 'Lilongwe', 'Mzuzu', 'Zomba'])
                    _chip(l, l, _location, (v) => setState(() { _location = _location == v ? null : v; _run(); })),
                ],
              ),
            ),
            Expanded(
              child: _error != null
                  ? ErrorRetry(message: _error!, onRetry: _run)
                  : _loading
                      ? const Center(child: CircularProgressIndicator())
                      : _results.isEmpty
                          ? const EmptyState(icon: Icons.search_off, title: 'No listings found', subtitle: 'Try different words, filters or location.')
                          : GridView.builder(
                              padding: const EdgeInsets.all(16),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 0.68),
                              itemCount: _results.length,
                              itemBuilder: (context, i) => ListingCard(
                                listing: _results[i],
                                onTap: () {
                                  PamojiApi.addRecent(_results[i].id);
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (_) => DetailScreen(listingId: _results[i].id)));
                                },
                              ),
                            ),
            ),
          ],
        ),
      );

  Widget _chip(String label, String value, String? current, void Function(String) onTap) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: FilterChip(label: Text(label), selected: current == value, onSelected: (_) => onTap(value)),
      );
}
