// Profile: real account info, seller status, notifications, sign out.
import 'package:flutter/material.dart';
import '../../core/api.dart';
import '../../core/models.dart';
import '../../core/theme.dart';
import '../../widgets/common.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  PUser? _me;
  List<Map<String, dynamic>> _notifs = [];
  String? _error;

  Future<void> _load() async {
    setState(() => _error = null);
    try {
      final me = await PamojiApi.me();
      final notifs = await PamojiApi.notifications();
      if (mounted) {
        setState(() {
          _me = PUser.fromJson(me['user'] as Map<String, dynamic>);
          _notifs = (notifs['notifications'] as List).cast<Map<String, dynamic>>();
        });
      }
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  @override
  void initState() { super.initState(); _load(); }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(appBar: AppBar(title: const Text('Profile')), body: ErrorRetry(message: _error!, onRetry: _load));
    }
    if (_me == null) {
      return Scaffold(appBar: AppBar(title: const Text('Profile')), body: const Center(child: CircularProgressIndicator()));
    }
    final me = _me!;
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              CircleAvatar(radius: 30, backgroundColor: PamojiColors.surface2,
                  child: Text(me.displayName.isNotEmpty ? me.displayName[0].toUpperCase() : '?',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800))),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(me.displayName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 3),
                    Text('${me.location}${me.isSeller ? ' · Seller' : ''}',
                        style: const TextStyle(color: PamojiColors.dim, fontSize: 13)),
                  ],
                ),
              ),
              if (!me.emailVerified)
                const StatusPill('Email unverified', PamojiColors.gold),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                _row(Icons.badge_outlined, 'Account status', me.accountStatus),
                _row(Icons.star_outline, 'Rating', me.reviewCount > 0 ? '★ ${me.rating.toStringAsFixed(1)} (${me.reviewCount})' : 'No reviews yet'),
                if (me.email != null) _row(Icons.email_outlined, 'Email', me.email!),
                _row(Icons.verified_outlined, 'Seller status', me.isSeller ? 'Seller — see Sell tab (next phase: onboarding screen)' : 'Buyer (become a seller in the Sell tab — next phase)'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text('Notifications', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          if (_notifs.isEmpty)
            const EmptyState(icon: Icons.notifications_none, title: 'Nothing yet', subtitle: 'Order updates, verification decisions and messages land here.'),
          for (final n in _notifs.take(12))
            Card(
              child: ListTile(
                title: Text(n['title'] as String, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                subtitle: Text(n['body'] as String? ?? '', style: const TextStyle(fontSize: 12.5)),
                trailing: n['read'] == true ? null : const StatusPill('new', PamojiColors.gold),
              ),
            ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () async { await PamojiApi.logout(); },
            icon: const Icon(Icons.logout),
            label: const Text('Sign out'),
          ),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        child: Row(
          children: [
            Icon(icon, size: 20, color: PamojiColors.gold),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: const TextStyle(color: PamojiColors.dim, fontSize: 13))),
            Expanded(
              flex: 2,
              child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      );
}
