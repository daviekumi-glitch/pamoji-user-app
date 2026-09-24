// Reusable widgets: listing card, skeleton loaders, empty states, error states.
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../core/models.dart';
import '../core/theme.dart';

class ListingCard extends StatelessWidget {
  final PListing listing;
  final VoidCallback onTap;
  const ListingCard({super.key, required this.listing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final img = listing.images.isNotEmpty ? listing.images.first : null;
    return GestureDetector(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1.25,
              child: img != null
                  ? CachedNetworkImage(
                      imageUrl: img,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => const Skeleton(),
                      errorWidget: (_, __, ___) => const _NoImage(),
                    )
                  : const _NoImage(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(listing.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13.5)),
                  const SizedBox(height: 5),
                  Text('MWK ${listing.price.round()}',
                      style: const TextStyle(
                          color: PamojiColors.green,
                          fontWeight: FontWeight.w800,
                          fontSize: 14)),
                  const SizedBox(height: 4),
                  Text('${listing.location} · ${listing.condition.replaceAll('_', ' ')}',
                      style: const TextStyle(
                          color: PamojiColors.dim, fontSize: 11.5)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoImage extends StatelessWidget {
  const _NoImage();
  @override
  Widget build(BuildContext context) => Container(
        color: PamojiColors.surface2,
        child: const Center(
          child: Icon(Icons.storefront, color: PamojiColors.dim, size: 34),
        ),
      );
}

class Skeleton extends StatefulWidget {
  const Skeleton({super.key});
  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton>
    with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900))..repeat();
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (_, __) => Container(
          color: PamojiColors.surface2.withOpacity(0.4 + 0.3 * _c.value),
        ),
      );
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const EmptyState(
      {super.key, required this.icon, required this.title, required this.subtitle});
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 46, color: PamojiColors.dim),
              const SizedBox(height: 12),
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 6),
              Text(subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: PamojiColors.dim, fontSize: 13)),
            ],
          ),
        ),
      );
}

class ErrorRetry extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const ErrorRetry({super.key, required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 42, color: PamojiColors.dim),
              const SizedBox(height: 12),
              Text(message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: PamojiColors.dim, fontSize: 13.5)),
              const SizedBox(height: 16),
              FilledButton.icon(
                  onPressed: onRetry, icon: const Icon(Icons.refresh), label: const Text('Try again')),
            ],
          ),
        ),
      );
}

class StatusPill extends StatelessWidget {
  final String text;
  final Color color;
  const StatusPill(this.text, this.color, {super.key});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        decoration: BoxDecoration(
            color: color.withOpacity(0.16),
            borderRadius: BorderRadius.circular(20)),
        child: Text(text,
            style: TextStyle(
                color: color, fontSize: 11, fontWeight: FontWeight.w700)),
      );
}

String fmtMwk(num v) {
  var s = v.round().toString();
  final b = StringBuffer();
  while (s.length > 3) {
    b.write(',${s.substring(s.length - 3)}');
    s = s.substring(0, s.length - 3);
  }
  b.write(s);
  return 'MWK ${b.toString()}';
}
