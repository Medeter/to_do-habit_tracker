import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../widgets/add_edit_task_dialog.dart';
import 'task_list_screen.dart';
import 'calendar_screen.dart';
import 'statistics_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late final PageController _pageController;

  final List<Widget> _screens = [
    const TaskListScreen(),
    const CalendarScreen(),
    const StatisticsScreen(),
    const SettingsScreen(),
  ];

  final List<String> _titles = [
    'งาน & นิสัย',
    'ปฏิทิน',
    'สถิติ',
    'ตั้งค่า',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().loadTasks();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titles[_currentIndex],
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primaryContainer.withOpacity(0.8),
                Theme.of(context).colorScheme.surface,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: _screens,
      ),
      floatingActionButton: _currentIndex == 0 
          ? FloatingActionButton.extended(
              onPressed: _addNewTask,
              tooltip: 'เพิ่มงานหรือนิสัย',
              icon: const Icon(Icons.add_rounded),
              label: const Text('เพิ่มงาน'),
              elevation: 8,
            )
          : null,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 11,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.task_alt_rounded),
              activeIcon: Icon(Icons.task_alt_rounded),
              label: 'งาน',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_rounded),
              activeIcon: Icon(Icons.calendar_today_rounded),
              label: 'ปฏิทิน',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics_rounded),
              activeIcon: Icon(Icons.analytics_rounded),
              label: 'สถิติ',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_rounded),
              activeIcon: Icon(Icons.settings_rounded),
              label: 'ตั้งค่า',
            ),
          ],
        ),
      ),
    );
  }

  void _addNewTask() {
    showDialog(
      context: context,
      builder: (context) => AddEditTaskDialog(
        onSave: (task) {
          context.read<TaskProvider>().addTask(task);
        },
      ),
    );
  }
}