// PAMOJI Marketplace — entry point.
// Auth gate: shows login until a valid session token exists.
import 'package:flutter/material.dart';
import 'core/api.dart';
import 'core/theme.dart';
import 'widgets/common.dart';
import 'features/auth/login_screen.dart';
import 'features/home/home_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/search/search_screen.dart';
import 'features/seller/seller_dashboard.dart';
import 'features/chat/chat_screen.dart';
import 'features/orders/orders_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PamojiApp());
}

class PamojiApp extends StatefulWidget {
  const PamojiApp({super.key});
  @override
  State<PamojiApp> createState() => _PamojiAppState();
}

class _PamojiAppState extends State<PamojiApp> {
  @override
  void initState() {
    super.initState();
    PamojiApi.init();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'PAMOJI',
        debugShowCheckedModeBanner: false,
        theme: pamojiTheme(),
        home: StreamBuilder<bool>(
          stream: Stream.periodic(const Duration(milliseconds: 200),
              (_) => PamojiApi.hasToken),
          initialData: PamojiApi.hasToken,
          builder: (context, snap) =>
              (snap.data ?? false) ? const HomeShell() : const LoginScreen(),
        ),
      );
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _tab = 0;
  final _pages = const [HomeScreen(), SearchScreen(), SellerDashboard(), ChatScreen(), ProfileScreen()];

  @override
  Widget build(BuildContext context) => Scaffold(
        body: IndexedStack(index: _tab, children: _pages),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _tab,
          onDestinationSelected: (i) => setState(() => _tab = i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.search_outlined), selectedIcon: Icon(Icons.search), label: 'Search'),
            NavigationDestination(icon: Icon(Icons.sell_outlined), selectedIcon: Icon(Icons.sell), label: 'Sell'),
            NavigationDestination(icon: Icon(Icons.chat_bubble_outline), selectedIcon: Icon(Icons.chat_bubble), label: 'Messages'),
            NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      );
}

class _Placeholder extends StatelessWidget {
  final String label;
  const _Placeholder(this.label);
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(label)),
        body: const EmptyStateStub(),
      );
}

class EmptyStateStub extends StatelessWidget {
  const EmptyStateStub();
  @override
  Widget build(BuildContext context) => const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.construction, size: 40, color: PamojiColors.dim),
              SizedBox(height: 12),
              Text('Next build phase',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              SizedBox(height: 6),
              Text(
                'The backend fully supports this feature — the screen ships in the next build phase. No fake screens here.',
                textAlign: TextAlign.center,
                style: TextStyle(color: PamojiColors.dim, fontSize: 13),
              ),
            ],
          ),
        ),
      );
}
