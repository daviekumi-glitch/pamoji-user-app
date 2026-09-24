// Product details: gallery, price, seller card with verification badge,
// favorite, share, message seller (real conversation), WhatsApp, report.
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/api.dart';
import '../../core/models.dart';
import '../../core/theme.dart';
import '../../widgets/common.dart';

class DetailScreen extends StatefulWidget {
  final String listingId;
  const DetailScreen({super.key, required this.listingId});
  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  Map<String, dynamic>? _data;
  String? _error;
  bool _isFavorite = false;
  bool _busy = false;

  Future<void> _load() async {
    setState(() => _error = null);
    try {
      final d = await PamojiApi.listing(widget.listingId);
      if (mounted) setState(() { _data = d; _isFavorite = d['isFavorite'] as bool? ?? false; });
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _toggleFavorite() async {
    final listing = _data!['listing'] as Map<String, dynamic>;
    final add = !_isFavorite;
    setState(() => _isFavorite = add); // optimistic
    try {
      await PamojiApi.favorite(widget.listingId, add);
    } on ApiException catch (e) {
      if (mounted) { setState(() => _isFavorite = !add); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message))); }
    }
  }

  Future<void> _messageSeller() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final res = await PamojiApi.startConversation(widget.listingId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Conversation started with ${res['conversation']['sellerName']} — the chat screen ships in the next build phase; the seller has been notified.'),
          duration: const Duration(seconds: 4),
        ));
      }
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _whatsapp(String? number, String title) async {
    if (number == null || number.isEmpty) return;
    final clean = number.replaceAll(RegExp(r'[^0-9+]'), '');
    final url = 'https://wa.me/$clean?text=${Uri.encodeComponent('Hi, I saw "$title" on PAMOJI.')}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('WhatsApp is not available on this device.')));
    }
  }

  Future<void> _report() async {
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Report this listing'),
        children: [
          for (final r in ['Prohibited item', 'Fake or counterfeit', 'Stolen goods', 'Scam or fraud', 'Wrong category', 'Other'])
            SimpleDialogOption(onPressed: () => Navigator.pop(context, r), child: Text(r)),
        ],
      ),
    );
    if (reason == null) return;
    try {
      await PamojiApi.call('pamojiReports', {
        'action': 'report',
        'targetType': 'listing',
        'targetId': widget.listingId,
        'reason': reason,
        'description': 'Reported from listing details',
      });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report sent — our moderators will review it.')));
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(appBar: AppBar(), body: ErrorRetry(message: _error!, onRetry: _load));
    }
    if (_data == null) {
      return Scaffold(appBar: AppBar(), body: const Center(child: CircularProgressIndicator()));
    }
    final l = _data!['listing'] as Map<String, dynamic>;
    final s = _data!['seller'] as Map<String, dynamic>;
    final seller = PSeller.fromJson({...s, 'id': s['id'] ?? l['sellerId']});
    final images = (l['images'] as List).cast<String>();
    final whatsapp = s['whatsapp'] as String? ?? s['phone'] as String?;
    final verified = seller.verificationStatus == 'verified';
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border,
                color: _isFavorite ? PamojiColors.danger : null),
            onPressed: _toggleFavorite,
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () => Share.share('Check out "${l['title']}" on PAMOJI — MWK ${l['price']}'),
          ),
          IconButton(icon: const Icon(Icons.flag_outlined), onPressed: _report),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 1.15,
              child: images.isEmpty
                  ? Container(color: PamojiColors.surface, child: const Icon(Icons.storefront, size: 54, color: PamojiColors.dim))
                  : PageView.builder(
                      itemCount: images.length,
                      itemBuilder: (context, i) => CachedNetworkImage(imageUrl: images[i], fit: BoxFit.cover,
                          placeholder: (_, __) => const Skeleton(),
                          errorWidget: (_, __, ___) => Container(color: PamojiColors.surface2)),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(l['title'] as String,
                    style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800, height: 1.25)),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(fmtMwk((l['price'] as num).toDouble()),
                      style: const TextStyle(color: PamojiColors.green, fontSize: 19, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  StatusPill((l['condition'] as String).replaceAll('_', ' '), PamojiColors.gold),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8, runSpacing: 6,
            children: [
              const StatusPill('Published', PamojiColors.green),
              StatusPill(l['categoryName'] as String? ?? '', PamojiColors.gold),
              if (l['deliveryAvailable'] == true) const StatusPill('Delivery available', PamojiColors.green),
              StatusPill('Qty: ${l['quantity']}', PamojiColors.dim),
            ],
          ),
          const SizedBox(height: 14),
          Text(l['description'] as String? ?? '', style: const TextStyle(fontSize: 14, height: 1.5)),
          const SizedBox(height: 18),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const CircleAvatar(backgroundColor: PamojiColors.surface2, child: Icon(Icons.store, color: PamojiColors.gold)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(child: Text(seller.businessName ?? seller.contactPerson,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5))),
                            if (verified) ...[
                              const SizedBox(width: 6),
                              const Icon(Icons.verified, color: PamojiColors.green, size: 17),
                            ],
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${seller.location} · ★ ${seller.rating.toStringAsFixed(1)} (${seller.reviewCount} reviews)',
                          style: const TextStyle(color: PamojiColors.dim, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _busy ? null : _messageSeller,
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('Message'),
                ),
              ),
              if (whatsapp != null && whatsapp.isNotEmpty) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _whatsapp(whatsapp, l['title'] as String),
                    icon: const Icon(Icons.whatsapp, color: PamojiColors.green),
                    label: const Text('WhatsApp'),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
