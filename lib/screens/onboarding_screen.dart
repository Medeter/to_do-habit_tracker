import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      icon: Icons.task_alt,
      title: 'จัดการงานของคุณ',
      description: 'สร้าง ติดตาม และจัดการงานต่างๆ ให้เสร็จตามเวลาที่กำหนด',
    ),
    OnboardingData(
      icon: Icons.repeat,
      title: 'สร้างนิสัยดีๆ',
      description: 'ติดตามนิสัยประจำวันและสร้างรูทีนที่ดีให้กับตัวเอง',
    ),
    OnboardingData(
      icon: Icons.analytics,
      title: 'ติดตามความคืบหน้า',
      description: 'ดูสถิติและความคืบหน้าของงานและนิสัยของคุณ',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_time', false);
    
    if (!mounted) return;
    
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _completeOnboarding,
                  child: const Text('ข้าม'),
                ),
              ),
              
              // Page view
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    final page = _pages[index];
                    return Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Icon
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(60),
                            ),
                            child: Icon(
                              page.icon,
                              size: 60,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          
                          const SizedBox(height: 40),
                          
                          // Title
                          Text(
                            page.title,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Description
                          Text(
                            page.description,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              
              // Page indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: _currentPage == index
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Bottom buttons
              Padding(
                padding: const EdgeInsets.all(24),
                child: _currentPage == _pages.length - 1
                    ? SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _completeOnboarding,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'เริ่มต้นใช้งาน',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: Text(
                              'ย้อนกลับ',
                              style: TextStyle(
                                color: _currentPage > 0 
                                    ? Theme.of(context).colorScheme.primary 
                                    : Colors.transparent,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('ถัดไป'),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OnboardingData {
  final IconData icon;
  final String title;
  final String description;

  OnboardingData({
    required this.icon,
    required this.title,
    required this.description,
  });
}