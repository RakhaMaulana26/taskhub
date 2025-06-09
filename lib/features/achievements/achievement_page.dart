import 'package:flutter/material.dart';
import 'package:taskhub/config/theme/app_theme.dart';
import 'package:taskhub/features/navbar/bottom_navbar.dart';
import 'package:taskhub/data/db/todo_database.dart';

class AchievementPage extends StatefulWidget {
  const AchievementPage({super.key});

  @override
  State<AchievementPage> createState() => _AchievementPageState();
}

class _AchievementPageState extends State<AchievementPage> {
  int totalPoints = 0;
  int currentPoints = 0;
  bool _isLoading = true;

  // Daftar rank dan poinnya
  final List<_RankPhase> ranks = const [
    _RankPhase('assets/ranks/warrior.png', 0, 'Warrior'),
    _RankPhase('assets/ranks/elite.png', 250, 'Elite'),
    _RankPhase('assets/ranks/master.png', 500, 'Master'),
    _RankPhase('assets/ranks/grandmaster.png', 750, 'Grandmaster'),
    _RankPhase('assets/ranks/epic.png', 1000, 'Epic'),
    _RankPhase('assets/ranks/legend.png', 1250, 'Legend'),
    _RankPhase('assets/ranks/mawi.png', 1500, 'Mythic'),
    _RankPhase('assets/ranks/glory.png', 1750, 'Mythical Glory'),
  ];

  @override
  void initState() {
    super.initState();
    _loadPoints();
  }

  Future<void> _loadPoints() async {
    final todos = await TodoDatabase.instance.readAllTodos();
    int points = 0;
    final now = DateTime.now();
    for (final t in todos) {
      if (t.isDone && t.deadline != null && t.deadline!.isAfter(now)) {
        points += 20; // Selesai tepat waktu
      } else if (t.isDone && t.deadline != null && t.deadline!.isBefore(now)) {
        points -= 10; // Selesai terlambat
      } else if (!t.isDone && t.deadline != null && t.deadline!.isBefore(now)) {
        points -= 20; // Terlambat
      } else if (!t.isDone) {
        // Belum selesai
        // points += 0;
      }
    }
    if (points < 0) points = 0;
    setState(() {
      totalPoints = 2000; // Tetap 2000 untuk batas rank
      currentPoints = points;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final double progress = (currentPoints / totalPoints).clamp(0.0, 1.0);
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Achievement'),
            const SizedBox(height: 2),
            Text(
              'Jumlah Poin: $currentPoints',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.background,
      ),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        reverse: true, // agar scroll dari bawah ke atas
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Progress bar di ujung kiri
                Container(
                  height: 8 * 250 + 7 * 16, // 8 rank * 250 + 7 jarak antar rank (16)
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: AppColors.primary, width: 4),
                  ),
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: FractionallySizedBox(
                          heightFactor: progress,
                          child: Container(
                            width: 60,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.vertical(
                                bottom: Radius.circular(30),
                                top: Radius.circular(progress == 1.0 ? 30 : 0),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Tulisan point di dalam progress bar
                      Positioned(
                        bottom: 16 + ((8 * 250 + 7 * 16) - 32) * (1 - progress),
                        left: 0,
                        right: 0,
                        child: Center(
                        ),
                      ),
                    ],
                  ),
                ),
                // Spacer untuk area kanan (bisa diisi widget lain nanti)
                const SizedBox(width: 32),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end, // dari bawah ke atas
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (int i = ranks.length - 1; i >= 0; i--)
                        _RankCard(
                          rank: ranks[i],
                          isActive: currentPoints >= ranks[i].points,
                          isCurrent: (i == ranks.length - 1) ? currentPoints >= ranks[i].points : (currentPoints >= ranks[i].points && currentPoints < ranks[i + 1].points),
                          nextPoints: (i < ranks.length - 1) ? ranks[i + 1].points : totalPoints,
                          currentPoints: currentPoints,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: BottomNavBar(
          currentIndex: 3,
          onTap: (idx) {
            navigateToNavBarPage(context, idx);
          },
          onCenterButtonTap: () {
            navigateToAddTaskPage(context);
          },
        ),
      ),
    );
  }
}

// Tambahkan widget kartu rank
class _RankCard extends StatelessWidget {
  final _RankPhase rank;
  final bool isActive;
  final bool isCurrent;
  final int nextPoints;
  final int currentPoints;
  const _RankCard({
    required this.rank,
    required this.isActive,
    required this.isCurrent,
    required this.nextPoints,
    required this.currentPoints,
  });

  @override
  Widget build(BuildContext context) {
    final double percent = ((currentPoints - rank.points) / (nextPoints - rank.points)).clamp(0.0, 1.0);
    // Path background asset: ganti .png ke .jpg dan folder ranks ke background_ranks
    final String bgAsset = rank.asset.replaceFirst('ranks/', 'background_ranks/').replaceFirst('.png', '.jpg');
    return Container(
      height: 250,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCurrent ? AppColors.primary : Colors.grey.shade300,
          width: isCurrent ? 3 : 1.5,
        ),
        boxShadow: [
          if (isCurrent)
            BoxShadow(
              color: AppColors.primary.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Opacity(
              opacity: 0.5, // Semua background diberi opacity 0.5
              child: Image.asset(
                bgAsset,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: isCurrent ? AppColors.primary.withOpacity(0.10) : Colors.white.withOpacity(0.10),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(rank.asset, width: 80, height: 80),
                const SizedBox(height: 12),
                Text(
                  rank.name,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isCurrent ? AppColors.primary : Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${rank.points} poin',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
                if (isCurrent)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: LinearProgressIndicator(
                      value: percent,
                      minHeight: 10,
                      backgroundColor: AppColors.primary.withOpacity(0.15),
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                if (isCurrent)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      '${(percent * 100).toStringAsFixed(1)}% menuju ${nextPoints} poin',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (isActive && !isCurrent)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withOpacity(0.92), // Gold
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.emoji_events, color: Colors.white, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      'Tercapai',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.18),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _RankPhase {
  final String asset;
  final int points;
  final String name;
  const _RankPhase(this.asset, this.points, this.name);
}
