import 'package:flutter/material.dart';
import 'package:taskhub/features/crud/crud.dart';

void main() {
  runApp(const TaskApp());
}

class TaskApp extends StatelessWidget {
  const TaskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1A1A1A),
        primaryColor: const Color(0xFF4A90E2),
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Guten Morgen!',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Ayo ganyang fufufafa',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: const Color(0xFF87CEEB),
                    child: Icon(
                      Icons.person,
                      color: Colors.red[400],
                      size: 30,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),


              SearchBar(
                // controller: _searchController,
                hintText: 'Cari...',
                leading: Icon(Icons.search, color: Colors.grey[600]),
                backgroundColor: MaterialStateProperty.all(Colors.white),
                elevation: MaterialStateProperty.all(0),
                padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 16)),
                textStyle: MaterialStateProperty.all(
                  TextStyle(color: Colors.black), // Teks berwarna hitam
                ),
                hintStyle: MaterialStateProperty.all(
                  TextStyle(color: Colors.grey[600]), // Hint text berwarna abu-abu
                ),
                // onChanged: (value) => _filterResults(value),
              ),
              // Search Bar
              // Container(
              //   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              //   decoration: BoxDecoration(
              //     color: Colors.grey[800],
              //     borderRadius: BorderRadius.circular(25),
              //   ),
              //   child: Row(
              //     children: [
              //       Icon(Icons.search, color: Colors.grey[500]),
              //       const SizedBox(width: 10),
              //       Text(
              //         'Search',
              //         style: TextStyle(
              //           color: Colors.grey[500],
              //           fontSize: 16,
              //         ),
              //       ),
              //     ],
              //   ),
              // ),

              const SizedBox(height: 30),

              // Statistics Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    // Circular Progress
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: Stack(
                        children: [
                          Center(
                            child: CircularProgressIndicator(
                              value: 0.75,
                              strokeWidth: 8,
                              backgroundColor: Colors.grey[700],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                const Color(0xFF4A90E2),
                              ),
                            ),
                          ),
                          Center(
                            child: Text(
                              '75%',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 20),

                    // Statistics Text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Statistik Mingguan',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Pantau statistik\nkegiatanmu disini',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[400],
                            ),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4A90E2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Text(
                              'Lihat Statistik',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Today's Tasks
              Text(
                'Tugas hari ini: 3',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 20),

              // Task Cards
              Row(
                children: [
                  Expanded(
                    child: TaskCard(
                      icon: Icons.school,
                      title: 'Akademik',
                      subtitle: 'Tugas Basis\nData',
                      progress: 0.8,
                      time: '10:30',
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: TaskCard(
                      icon: Icons.fitness_center,
                      title: 'Olahraga',
                      subtitle: 'Jogging',
                      progress: 0.8,
                      time: '12:45',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Upcoming Tasks
              Text(
                'Tugas Mendatang',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 15),

              // Upcoming Task Item
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4A90E2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.assignment, color: Colors.white),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tugas Basis Data',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '80%',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Icon(Icons.notifications, color: Colors.grey[400]),
                        const SizedBox(height: 5),
                        Text(
                          '10:30 Senin, 12 Mei 2025',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TodoFormPage()),
          );
        },
        backgroundColor: const Color(0xFF4A90E2),
        child: Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // Bottom Navigation
      bottomNavigationBar: BottomAppBar(
        color: Colors.grey[900],
        shape: CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBottomNavItem(Icons.home, 'Home', 0),
            _buildBottomNavItem(Icons.calendar_today, 'Jadwal', 1),
            const SizedBox(width: 40), // Space for FAB
            _buildBottomNavItem(Icons.assignment, 'Tugas', 2),
            _buildBottomNavItem(Icons.person, 'Profil', 3),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon, String label, int index) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFF4A90E2) : Colors.grey[600],
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? const Color(0xFF4A90E2) : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

class TaskCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final double progress;
  final String time;

  const TaskCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Text(
            subtitle,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[400],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[700],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    const Color(0xFF4A90E2),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          Text(
            time,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
