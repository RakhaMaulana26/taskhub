import 'package:flutter/material.dart';
import '../models/user.dart';
import '../../statistik/screens/statistics_screen.dart';
import '../../navbar/bottom_navbar.dart';
import 'package:taskhub/config/theme/app_theme.dart';
import 'package:taskhub/data/db/todo_database.dart';
import 'package:taskhub/data/models/todo.dart';
import 'package:taskhub/features/achievements/achievement_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final User _user = User(
    name: 'Fufufafa',
    fullName: 'Rembo',
    profileImage: 'https://i.pravatar.cc/150?img=3',
    weeklyProgress: 75,
  );

  List<Todo> _todayTodos = [];
  List<Todo> _upcomingTodos = [];
  bool _isLoading = true;

  // Tambahan untuk rank
  int _currentPoints = 0;
  String _currentRankAsset = 'assets/ranks/warrior.png';
  final List<_RankPhase> _ranks = const [
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
    _fetchTodayTodos();
    _fetchUpcomingTodos();
    _loadCurrentRank();
  }

  Future<void> _loadCurrentRank() async {
    final todos = await TodoDatabase.instance.readAllTodos();
    int points = 0;
    final now = DateTime.now();
    for (final t in todos) {
      if (t.isDone && t.deadline != null && t.deadline!.isAfter(now)) {
        points += 20;
      } else if (t.isDone && t.deadline != null && t.deadline!.isBefore(now)) {
        points += 10;
      } else if (!t.isDone && t.deadline != null && t.deadline!.isBefore(now)) {
        points -= 20;
      }
    }
    if (points < 0) points = 0;
    String asset = _ranks.first.asset;
    for (final r in _ranks) {
      if (points >= r.points) {
        asset = r.asset;
      } else {
        break;
      }
    }
    setState(() {
      _currentPoints = points;
      _currentRankAsset = asset;
    });
  }

  Future<void> _fetchTodayTodos() async {
    final allTodos = await TodoDatabase.instance.readAllTodos();
    final now = DateTime.now();
    final todayTodos =
        allTodos.where((todo) {
          if (todo.deadline == null) return false;
          return todo.deadline!.year == now.year &&
              todo.deadline!.month == now.month &&
              todo.deadline!.day == now.day;
        }).toList();
    setState(() {
      _todayTodos = todayTodos;
      _isLoading = false;
    });
  }

  Future<void> _fetchUpcomingTodos() async {
    final allTodos = await TodoDatabase.instance.readAllTodos();
    final now = DateTime.now();
    final upcomingTodos =
        allTodos.where((todo) {
          if (todo.deadline == null) return false;
          final d = todo.deadline!;
          // exclude today
          return !(d.year == now.year &&
                  d.month == now.month &&
                  d.day == now.day) &&
              d.isAfter(DateTime(now.year, now.month, now.day, 0, 0, 0));
        }).toList();
    setState(() {
      _upcomingTodos = upcomingTodos;
    });
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Guten Morgen!';
    } else if (hour < 17) {
      return 'Guten Tag!';
    } else {
      return 'Guten Abend!';
    }
  }

  String _formatDeadline(DateTime deadline) {
    // Format: Hari, Tanggal Bulan Tahun
    final weekDays = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];
    final monthNames = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${weekDays[deadline.weekday % 7]}, ${deadline.day} ${monthNames[deadline.month]} ${deadline.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _greeting(),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              _user.fullName,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[400],
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(_currentRankAsset, width: 32, height: 32),
                    Text(
                      '$_currentPoints poin',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white70,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _getRankBorderColor(_currentRankAsset),
                      width: 3,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(_user.profileImage),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatisticsCard(theme),
                      const SizedBox(height: 16),
                      _buildTodayTasksSection(theme),
                      const SizedBox(height: 16),
                      _buildUpcomingTasksSection(theme),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: BottomNavBar(
          currentIndex: 0,
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

  Widget _buildStatisticsCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.widget,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: Stack(
              children: [
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    value: _user.weeklyProgress / 100,
                    strokeWidth: 8,
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Statistik Mingguan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Pantau statistik kegiatanmu disini',
                  style: TextStyle(fontSize: 12, color: Colors.white),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StatisticsScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Lihat Statistik'),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayTasksSection(ThemeData theme) {
    final sortedTodos = [..._todayTodos];
    sortedTodos.sort((a, b) {
      if (a.isDone == b.isDone) return 0;
      return a.isDone ? 1 : -1;
    });
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tugas hari ini: ${_todayTodos.length}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        FutureBuilder<List<_TodoProgress>>(
          future: Future.wait(
            sortedTodos.map((todo) async {
              final progress = await TodoDatabase.instance.getTodoProgress(
                todo.id!,
              );
              final isDoneFinal = progress == 1.0;
              return _TodoProgress(
                todo: todo,
                progress: progress,
                isDoneFinal: isDoneFinal,
              );
            }).toList(),
          ),
          builder: (context, snapshot) {
            if (_isLoading || !snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final todoProgressList = snapshot.data!;
            if (todoProgressList.isEmpty) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 28),
                  Center(child: Text('Tidak ada tugas hari ini')),
                  SizedBox(height: 28),
                ],
              );
            }
            return SizedBox(
              height: 220,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: todoProgressList.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final tp = todoProgressList[index];
                  return SizedBox(
                    width: 220,
                    child: TodayTaskCard(
                      todo: tp.todo,
                      theme: theme,
                      progress: tp.progress,
                      isDoneFinal: tp.isDoneFinal,
                      onToggle:
                          tp.isDoneFinal
                              ? null
                              : () async {
                                final updatedTodo = tp.todo.copyWith(
                                  isDone: true,
                                );
                                await TodoDatabase.instance.updateTodo(
                                  updatedTodo,
                                );
                                setState(() {
                                  final idx = _todayTodos.indexOf(tp.todo);
                                  if (idx != -1) _todayTodos[idx] = updatedTodo;
                                });
                              },
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildUpcomingTasksSection(ThemeData theme) {
    final sortedTodos = [..._upcomingTodos];
    sortedTodos.sort((a, b) {
      if (a.isDone == b.isDone) return 0;
      return a.isDone ? 1 : -1;
    });
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tugas Mendatang',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        FutureBuilder<List<_TodoProgress>>(
          future: Future.wait(
            sortedTodos.map((todo) async {
              final progress = await TodoDatabase.instance.getTodoProgress(
                todo.id!,
              );
              final isDoneFinal = progress == 1.0;
              return _TodoProgress(
                todo: todo,
                progress: progress,
                isDoneFinal: isDoneFinal,
              );
            }).toList(),
          ),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final todoProgressList = snapshot.data!;
            if (todoProgressList.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Text('Tidak ada tugas mendatang')),
              );
            }
            return Column(
              children: List.generate(todoProgressList.length, (index) {
                final tp = todoProgressList[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: UpcomingTaskCard(
                    todo: tp.todo,
                    theme: theme,
                    progress: tp.progress,
                    isDoneFinal: tp.isDoneFinal,
                    onToggle:
                        tp.isDoneFinal
                            ? null
                            : () async {
                              final updatedTodo = tp.todo.copyWith(
                                isDone: true,
                              );
                              await TodoDatabase.instance.updateTodo(
                                updatedTodo,
                              );
                              setState(() {
                                final idx = _upcomingTodos.indexOf(tp.todo);
                                if (idx != -1)
                                  _upcomingTodos[idx] = updatedTodo;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    'Berhasil menyelesaikan tugas!',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: Colors.green,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                  ),
                );
              }),
            );
          },
        ),
      ],
    );
  }

  // Tambahkan fungsi untuk warna border rank
  Color _getRankBorderColor(String asset) {
    switch (asset) {
      case 'assets/ranks/warrior.png':
        return Colors.brown;
      case 'assets/ranks/elite.png':
        return Colors.grey;
      case 'assets/ranks/master.png':
        return Color(0xFFFF9800); // Gold
      case 'assets/ranks/grandmaster.png':
        return Color.fromARGB(255, 57, 57, 55); // Purple
      case 'assets/ranks/epic.png':
        return Color.fromARGB(255, 2, 96, 114); // Deep Purple
      case 'assets/ranks/legend.png':
        return Colors.amber;
      case 'assets/ranks/mawi.png':
        return Colors.pink;
      case 'assets/ranks/glory.png':
        return Colors.red;
      default:
        return Colors.brown;
    }
  }
}

// Pisahkan widget card tugas hari ini
class TodayTaskCard extends StatelessWidget {
  final Todo todo;
  final ThemeData theme;
  final double progress;
  final bool isDoneFinal;
  final VoidCallback? onToggle;
  const TodayTaskCard({
    super.key,
    required this.todo,
    required this.theme,
    required this.progress,
    required this.isDoneFinal,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    IconData categoryIcon;
    switch (todo.category) {
      case 'Akademik':
        categoryIcon = Icons.school;
        break;
      case 'Pekerjaan':
        categoryIcon = Icons.work;
        break;
      case 'Olahraga':
        categoryIcon = Icons.sports_soccer;
        break;
      case 'Hiburan':
        categoryIcon = Icons.movie;
        break;
      default:
        categoryIcon = Icons.task_alt;
    }
    return Container(
      width: 220,
      height: 260,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.widget,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    categoryIcon,
                    size: 24,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                todo.category,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          // Title dan toggle dalam satu row, toggle di kiri judul
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: isDoneFinal ? null : onToggle,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: todo.isDone ? AppColors.primary : Colors.transparent,
                    border: Border.all(
                      color:
                          todo.isDone ? AppColors.primary : AppColors.primary,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child:
                      todo.isDone
                          ? Icon(Icons.check, color: Colors.white, size: 22)
                          : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  todo.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress bar dan label
          Row(
            children: [
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white24,
                  color: theme.colorScheme.primary,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
          SizedBox(height: 32),
          Text(
            todo.deadline != null
                ? '${todo.deadline!.hour}:${todo.deadline!.minute.toString().padLeft(2, '0')}'
                : '-',
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

// Pisahkan widget card tugas mendatang
class UpcomingTaskCard extends StatelessWidget {
  final Todo todo;
  final ThemeData theme;
  final double progress;
  final bool isDoneFinal;
  final VoidCallback? onToggle;
  const UpcomingTaskCard({
    super.key,
    required this.todo,
    required this.theme,
    required this.progress,
    required this.isDoneFinal,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: TodoDatabase.instance.readNotificationsByTodoId(todo.id!),
      builder: (context, snapshot) {
        final hasNotif = snapshot.hasData && (snapshot.data as List).isNotEmpty;
        return Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.widget,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.center, // ubah dari start ke center
                children: [
                  // Toggle di kiri
                  GestureDetector(
                    onTap: isDoneFinal ? null : onToggle,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color:
                            todo.isDone
                                ? AppColors.primary
                                : Colors.transparent,
                        border: Border.all(
                          color:
                              todo.isDone
                                  ? AppColors.primary
                                  : AppColors.primary,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child:
                          todo.isDone
                              ? Icon(Icons.check, color: Colors.white, size: 22)
                              : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Column info tugas di kanan
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nama tugas
                        Text(
                          todo.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        // Progress bar dan label
                        Row(
                          children: [
                            Text(
                              '${(progress * 100).toInt()}%',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: LinearProgressIndicator(
                                value: progress,
                                backgroundColor: Colors.white24,
                                color: theme.colorScheme.primary,
                                minHeight: 8,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Deadline
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            todo.deadline != null
                                ? '${todo.deadline!.hour}:${todo.deadline!.minute.toString().padLeft(2, '0')}, '
                                    '${_formatDeadline(todo.deadline!)}'
                                : '-',
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (hasNotif)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(6),
                  child: Icon(
                    Icons.notifications,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  String _formatDeadline(DateTime deadline) {
    // Format: Hari, Tanggal Bulan Tahun
    final weekDays = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];
    final monthNames = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${weekDays[deadline.weekday % 7]}, ${deadline.day} ${monthNames[deadline.month]} ${deadline.year}';
  }
}

// Tambahkan class helper
class _TodoProgress {
  final Todo todo;
  final double progress;
  final bool isDoneFinal;
  _TodoProgress({
    required this.todo,
    required this.progress,
    required this.isDoneFinal,
  });
}

// Tambahkan class _RankPhase agar tidak error
class _RankPhase {
  final String asset;
  final int points;
  final String name;
  const _RankPhase(this.asset, this.points, this.name);
}
