// lib/features/expense/presentation/pages/onboarding_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense/core/routes/app_routes.dart';
import 'package:flutter_animate/flutter_animate.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      emoji: '💰',
      title: 'Track Every Expense',
      description:
          'Add your daily expenses in seconds. Just enter the amount, pick a category and optionally add a title. Your expense is saved instantly to the cloud.',
      color: const Color(0xFF6C63FF),
      steps: [
        'Tap the ➕ button at the bottom right',
        'Enter the amount',
        'Select a category',
        'Leave title empty — it auto-fills from category!',
        'Tap CREATE to save',
      ],
      tip: '💡 Tip: Leave the title empty and it auto-fills with the category name!',
    ),
    OnboardingData(
      emoji: '🏷️',
      title: 'Smart Categories',
      description:
          'Organise expenses with 8 colour-coded categories. Each category has its own icon and colour for quick identification.',
      color: const Color(0xFFFF6584),
      steps: [
        'Food 🍔 — Meals, groceries, dining',
        'Transport 🚗 — Fuel, cab, bus',
        'Entertainment 🎬 — Movies, games',
        'Bills 💡 — Electricity, phone, rent',
        'Shopping 🛍️ — Clothes, accessories',
        'Health ❤️ — Medicine, doctor',
        'Education 📚 — Books, courses',
        'Other 📦 — Everything else',
      ],
      tip: '💡 Tip: Categories help you understand where your money goes!',
    ),
    OnboardingData(
      emoji: '👆',
      title: 'Swipe to Edit or Delete',
      description:
          'Managing expenses is super easy with swipe gestures. No need to open any menu!',
      color: const Color(0xFF43E97B),
      steps: [
        'Swipe RIGHT on any expense → Edit it',
        'Swipe LEFT on any expense → Delete it',
        'Long press → View full details',
        'Changes are saved to cloud instantly',
      ],
      tip: '💡 Tip: Try swiping on any expense in your list!',
    ),
    OnboardingData(
      emoji: '🔔',
      title: 'Budget Limits & Warnings',
      description:
          'Set monthly and category-wise budget limits. Get instant warnings when you are close to or exceed your limits.',
      color: const Color(0xFFFA8231),
      steps: [
        'Tap ⋮ menu → Budget Settings',
        'Set your monthly spending limit',
        'Set limits per category (optional)',
        'Warning at 80% of budget used',
        'Alert when limit is exceeded',
      ],
      tip: '💡 Tip: Start with a monthly limit to control overall spending!',
    ),
    OnboardingData(
      emoji: '📊',
      title: 'Charts & Analytics',
      description:
          'Visualise your spending with beautiful interactive charts. Understand your spending patterns at a glance.',
      color: const Color(0xFF00C9FF),
      steps: [
        'Tap ⋮ menu → Charts',
        'Pie chart shows spending by category',
        'Bar chart shows last 6 months trend',
        'Tap any slice/bar for details',
        'Total expenses shown at top',
      ],
      tip: '💡 Tip: Check charts weekly to stay aware of your spending!',
    ),
    OnboardingData(
      emoji: '📄',
      title: 'Export PDF Reports',
      description:
          'Generate beautiful PDF reports of your expenses for any date range. Share or save them easily.',
      color: const Color(0xFF9B59B6),
      steps: [
        'Tap ⋮ menu → Export PDF',
        'Choose a quick range or custom dates',
        'Tap Generate PDF Report',
        'Open/Save to your device',
        'Share via WhatsApp, Email etc.',
      ],
      tip: '💡 Tip: Export monthly reports to track your financial progress!',
    ),
    OnboardingData(
      emoji: '🌙',
      title: 'Dark & Light Mode',
      description:
          'Switch between dark and light themes anytime to match your preference or save battery.',
      color: const Color(0xFF2C3E50),
      steps: [
        'Tap the ☀️/🌙 icon in the top bar',
        'Dark mode — easy on eyes at night',
        'Light mode — clear in bright daylight',
        'Your preference is saved automatically',
      ],
      tip: '💡 Tip: Dark mode saves battery on AMOLED screens!',
    ),
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.signup);
    }
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skipOnboarding() => _completeOnboarding();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Page View ──
          PageView.builder(
            controller: _controller,
            itemCount: _pages.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) =>
                _OnboardingPage(data: _pages[index]),
          ),

          // ── Skip button ──
          Positioned(
            top: 50,
            right: 20,
            child: TextButton(
              onPressed: _skipOnboarding,
              child: Text(
                'Skip',
                style: TextStyle(
                  color: _pages[_currentPage].color,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ),

          // ── Bottom controls ──
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Dot indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? _pages[_currentPage].color
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Next / Get Started button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _pages[_currentPage].color,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      onPressed: _nextPage,
                      child: Text(
                        _currentPage == _pages.length - 1
                            ? 'Get Started 🚀'
                            : 'Next →',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // Page counter
                  const SizedBox(height: 12),
                  Text(
                    '${_currentPage + 1} of ${_pages.length}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
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

// ── Individual Page Widget ──
class _OnboardingPage extends StatelessWidget {
  final OnboardingData data;

  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 80, 24, 220),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Emoji & Title ──
          Center(
            child: Column(
              children: [
                // Emoji circle
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: data.color.withOpacity(0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: data.color.withOpacity(0.3), width: 2),
                  ),
                  child: Center(
                    child: Text(
                      data.emoji,
                      style: const TextStyle(fontSize: 48),
                    ),
                  ),
                )
                    .animate()
                    .scale(duration: 600.ms, curve: Curves.elasticOut),

                const SizedBox(height: 20),

                // Title
                Text(
                  data.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: data.color,
                  ),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3),

                const SizedBox(height: 12),

                // Description
                Text(
                  data.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    height: 1.7,
                  ),
                ).animate().fadeIn(delay: 300.ms),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // ── Steps ──
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: data.color.withOpacity(0.06),
              borderRadius: BorderRadius.circular(16),
              border:
                  Border.all(color: data.color.withOpacity(0.2), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.list_alt_rounded,
                        color: data.color, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'How it works:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: data.color,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ...data.steps.asMap().entries.map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Step number circle
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: data.color,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${entry.key + 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                entry.value,
                                style: const TextStyle(
                                    fontSize: 13, height: 1.5),
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(
                            delay: Duration(
                                milliseconds: 300 + (entry.key * 80)),
                          ),
                    ),
              ],
            ),
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),

          const SizedBox(height: 16),

          // ── Tip ──
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: Colors.amber.withOpacity(0.4), width: 1),
            ),
            child: Text(
              data.tip,
              style: const TextStyle(
                fontSize: 13,
                height: 1.5,
                color: Colors.amber,
                fontWeight: FontWeight.w500,
              ),
            ),
          ).animate().fadeIn(delay: 600.ms),
        ],
      ),
    );
  }
}

// ── Data Model ──
class OnboardingData {
  final String emoji;
  final String title;
  final String description;
  final Color color;
  final List<String> steps;
  final String tip;

  OnboardingData({
    required this.emoji,
    required this.title,
    required this.description,
    required this.color,
    required this.steps,
    required this.tip,
  });
}