import 'package:flutter/material.dart';
import '../../../chess/presentation/screens/online_lobby_screen.dart';
import '../../../chess/presentation/screens/computer_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../coins/presentation/screens/coins_screen.dart';
import '../../../leaderboard/presentation/screens/leaderboard_screen.dart';
import '../../../games/presentation/screens/my_games_screen.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../../../tournaments/presentation/screens/tournaments_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  int coins = 250;

  static const bg = Color(0xFF120D08);
  static const panel = Color(0xFF21150C);
  static const panel2 = Color(0xFF302015);
  static const gold = Color(0xFFD6A84F);
  static const cream = Color(0xFFF5E7C9);
  static const muted = Color(0xFFB9A78A);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();
  }
  @override void dispose() { _controller.dispose(); super.dispose(); }

  void _open(Widget page) => Navigator.of(context).push(
    PageRouteBuilder(pageBuilder: (_, a, __) => page, transitionsBuilder: (_, a, __, child) =>
      FadeTransition(opacity: CurvedAnimation(parent: a, curve: Curves.easeOutCubic), child: child),
      transitionDuration: const Duration(milliseconds: 320)),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (_, __) => CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
                sliver: SliverToBoxAdapter(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Container(width: 46, height: 46, decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [gold, Color(0xFF9D7128)]),
                      borderRadius: BorderRadius.circular(14), boxShadow: const [BoxShadow(color: Color(0x553D270B), blurRadius: 16)]),
                      child: const Icon(Icons.emoji_events_rounded, color: Color(0xFF21150C), size: 27)),
                    const SizedBox(width: 12),
                    const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('CHESS PLATFORM', style: TextStyle(color: cream, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                      Text('KOPERSAY TECHNOLOGY', style: TextStyle(color: gold, fontSize: 8, fontWeight: FontWeight.w800, letterSpacing: 2.4)),
                    ])),
                    _iconButton(Icons.notifications_none_rounded, () => _open(const NotificationsScreen())),
                    const SizedBox(width: 6),
                    _iconButton(Icons.settings_outlined, () => _open(const SettingsScreen())),
                  ]),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => _open(const ProfileScreen()),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF3A2818), panel]),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: gold.withValues(alpha: .28)),
                      ),
                      child: Row(children: [
                        const CircleAvatar(radius: 27, backgroundColor: cream, child: Icon(Icons.person_rounded, color: Color(0xFF2B1B10), size: 31)),
                        const SizedBox(width: 13),
                        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Welcome back', style: TextStyle(color: muted, fontSize: 11)),
                          Text('Chess Player', style: TextStyle(color: cream, fontSize: 19, fontWeight: FontWeight.w900)),
                          SizedBox(height: 3),
                          Text('Rating 1200  •  Online', style: TextStyle(color: gold, fontSize: 11, fontWeight: FontWeight.w700)),
                        ])),
                        _coinPill(),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _heroCard(),
                  const SizedBox(height: 18),
                  const Text('PLAY', style: TextStyle(color: muted, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2)),
                  const SizedBox(height: 9),
                  Row(children: [
                    Expanded(child: _actionCard(Icons.flash_on_rounded, 'Quick Game', 'Fast online match', gold, () => _open(const OnlineLobbyScreen()), large: true)),
                    const SizedBox(width: 10),
                    Expanded(child: _actionCard(Icons.smart_toy_rounded, 'Computer', 'Practice & improve', const Color(0xFFB89562), () => _open(const ComputerScreen()), large: true)),
                  ]),
                  const SizedBox(height: 18),
                  const Text('DISCOVER', style: TextStyle(color: muted, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2)),
                  const SizedBox(height: 9),
                  GridView.count(
                    crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 1.55,
                    children: [
                      _actionCard(Icons.emoji_events_rounded, 'Tournaments', 'Compete & win', gold, () => _open(const TournamentsScreen())),
                      _actionCard(Icons.leaderboard_rounded, 'Leaderboard', 'Global rankings', const Color(0xFFB78D4C), () => _open(const LeaderboardScreen())),
                      _actionCard(Icons.history_rounded, 'My Games', 'Match history', const Color(0xFF9E8158), () => _open(const MyGamesScreen())),
                      _actionCard(Icons.monetization_on_rounded, 'Coins', '$coins coins', gold, () => _open(const CoinsScreen())),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _profileStrip(),
                ])),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _heroCard() => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      gradient: const LinearGradient(colors: [Color(0xFF4A3219), Color(0xFF24170D)]),
      border: Border.all(color: gold.withValues(alpha: .5)),
      boxShadow: const [BoxShadow(color: Color(0x663C250D), blurRadius: 24, offset: Offset(0, 10))],
    ),
    child: Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('READY FOR YOUR NEXT MOVE?', style: TextStyle(color: cream, fontSize: 17, fontWeight: FontWeight.w900)),
        const SizedBox(height: 6),
        const Text('Challenge a player and climb the rating ladder.', style: TextStyle(color: muted, fontSize: 11)),
        const SizedBox(height: 14),
        FilledButton.icon(
          onPressed: () => _open(const OnlineLobbyScreen()),
          icon: const Icon(Icons.play_arrow_rounded),
          label: const Text('PLAY ONLINE'),
          style: FilledButton.styleFrom(backgroundColor: gold, foregroundColor: Color(0xFF24170D)),
        ),
      ])),
      const SizedBox(width: 8),
      const Icon(Icons.auto_awesome_rounded, color: gold, size: 64),
    ]),
  );

  Widget _actionCard(IconData icon, String title, String subtitle, Color accent, VoidCallback onTap, {bool large=false}) => Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap, borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: EdgeInsets.all(large ? 16 : 13),
        decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(18), border: Border.all(color: accent.withValues(alpha: .2))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: accent, size: large ? 30 : 25),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(color: cream, fontSize: 14, fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: muted, fontSize: 9)),
        ]),
      ),
    ),
  );

  Widget _iconButton(IconData icon, VoidCallback onTap) => Material(
    color: panel2, borderRadius: BorderRadius.circular(13),
    child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(13), child: Padding(padding: const EdgeInsets.all(10), child: Icon(icon, color: cream, size: 21))),
  );

  Widget _coinPill() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: BoxDecoration(color: const Color(0x332D220F), borderRadius: BorderRadius.circular(13), border: Border.all(color: gold.withValues(alpha: .35))),
    child: Row(children: [const Icon(Icons.monetization_on_rounded, color: gold, size: 18), const SizedBox(width: 5), Text('$coins', style: const TextStyle(color: cream, fontWeight: FontWeight.w900))]),
  );

  Widget _profileStrip() => Material(
    color: panel, borderRadius: BorderRadius.circular(18),
    child: InkWell(onTap: () => _open(const ProfileScreen()), borderRadius: BorderRadius.circular(18),
      child: const Padding(padding: EdgeInsets.all(15), child: Row(children: [
        Icon(Icons.person_outline_rounded, color: gold), SizedBox(width: 10),
        Expanded(child: Text('Profile & statistics', style: TextStyle(color: cream, fontWeight: FontWeight.w800))),
        Icon(Icons.chevron_right_rounded, color: muted),
      ])),
    ),
  );
}
