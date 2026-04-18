import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:smart_resource_alloc/theme/app_theme.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (v) => setState(() => _currentPage = v),
            children: [
              _buildSlide('Welcome', 'Join thousands of volunteers making data-driven impact.', LucideIcons.globe2),
              _buildSlide('Smart Matching', 'Our AI pairs you with tasks where your exact skills are needed most.', LucideIcons.cpu),
              _buildSkillPickerSlide(),
            ],
          ),
          Positioned(
            bottom: 48,
            left: 24,
            right: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: List.generate(3, (index) => 
                     Container(
                       margin: const EdgeInsets.symmetric(horizontal: 4),
                       width: _currentPage == index ? 24 : 8,
                       height: 8,
                       decoration: BoxDecoration(
                         color: _currentPage == index ? AppTheme.accentBlue : Colors.white24,
                         borderRadius: BorderRadius.circular(4)
                       ),
                     )
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_currentPage < 2) {
                      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                    } else {
                      context.go('/volunteer/feed');
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentBlue),
                  child: Text(_currentPage == 2 ? 'Get Started' : 'Next'),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSlide(String title, String subtitle, IconData icon) {
    return Padding(
      padding: const EdgeInsets.all(48.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 100, color: AppTheme.accentBlue),
          const SizedBox(height: 48),
          Text(title, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildSkillPickerSlide() {
    return Padding(
      padding: const EdgeInsets.all(48.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Build Your Profile', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          const Text('Select your skills so we can route critical needs to you properly.', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.white70)),
          const SizedBox(height: 48),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _buildSelectableChip('Medical / First Aid', true),
              _buildSelectableChip('Logistics / Driving', false),
              _buildSelectableChip('Cooking & Prep', false),
              _buildSelectableChip('Physical Labour', true),
              _buildSelectableChip('Translation', false),
              _buildSelectableChip('Blood Donor', false),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSelectableChip(String label, bool isSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (v) {},
      selectedColor: AppTheme.accentBlue.withOpacity(0.3),
      checkmarkColor: AppTheme.healthGreen,
    );
  }
}
