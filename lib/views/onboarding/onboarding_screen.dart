import 'package:flutter/material.dart';
import '../../core/design_system.dart';
import '../language_selection/language_selection_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Welcome to Bug Scanner!',
      description: 'Discover the world of insects and reptiles with AI-powered identification and expert guidance.',
      icon: Icons.bug_report,
      color: ModernDesignSystem.primaryColor,
      features: ['AI Bug Recognition', 'Safety Assessment', 'Expert Guidance'],
    ),
    OnboardingPage(
      title: 'Smart Bug Identification',
      description: 'Simply take a photo of any insect, spider, snake, or scorpion and get instant identification with detailed information.',
      icon: Icons.camera_alt,
      color: ModernDesignSystem.secondaryColor,
      features: ['Instant Analysis', 'Danger Assessment', 'Habitat Info'],
    ),
    OnboardingPage(
      title: 'Bug Collection History',
      description: 'Keep track of all your identified insects and reptiles with detailed analysis history and safety tips.',
      icon: Icons.history,
      color: ModernDesignSystem.accentColor,
      features: ['History Tracking', 'Safety Tips', 'Disease Info'],
    ),
    OnboardingPage(
      title: 'AI Bug Expert',
      description: 'Get personalized advice and answers to all your entomology questions from our AI assistant.',
      icon: Icons.psychology,
      color: ModernDesignSystem.primaryColor,
      features: ['Expert Advice', 'Safety Guidance', '24/7 Support'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: ModernDesignSystem.animationDuration,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: ModernDesignSystem.animationCurve,
    ));
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: ModernDesignSystem.animationCurve,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_first_launch', false);
    
    if (!mounted) return;
    
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => LanguageSelectionScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ModernDesignSystem.backgroundColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              children: [
                // Skip button
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: TextButton(
                      onPressed: _completeOnboarding,
                      child: Text(
                        'Skip',
                        style: ModernDesignSystem.bodyStyle.copyWith(
                          color: ModernDesignSystem.textSecondaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Page content
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      return _buildPage(_pages[index]);
                    },
                  ),
                ),
                
                // Navigation
                _buildNavigation(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: page.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(60),
              border: Border.all(
                color: page.color.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              page.icon,
              size: 60,
              color: page.color,
            ),
          ),
          
          SizedBox(height: 40),
          
          // Title
          Text(
            page.title,
            style: ModernDesignSystem.headlineStyle.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: ModernDesignSystem.textPrimaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: 16),
          
          // Description
          Text(
            page.description,
            style: ModernDesignSystem.bodyStyle.copyWith(
              fontSize: 16,
              color: ModernDesignSystem.textSecondaryColor,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: 32),
          
          // Features
          ...page.features.map((feature) => _buildFeatureItem(feature)).toList(),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String feature) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(width: 50),
          Icon(
            Icons.check_circle,
            size: 20,
            color: ModernDesignSystem.primaryColor,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              feature,
              style: ModernDesignSystem.bodyStyle.copyWith(
                color: ModernDesignSystem.textPrimaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(width: 50),
        ],
      ),
    );
  }

  Widget _buildNavigation() {
    return Container(
      padding: EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous button
          if (_currentPage > 0)
            IconButton(
              onPressed: _previousPage,
              icon: Icon(
                Icons.arrow_back,
                color: ModernDesignSystem.textSecondaryColor,
              ),
            )
          else
            SizedBox(width: 48),
          
          // Page indicators
          Row(
            children: List.generate(
              _pages.length,
              (index) => Container(
                margin: EdgeInsets.symmetric(horizontal: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index == _currentPage
                      ? ModernDesignSystem.primaryColor
                      : ModernDesignSystem.textSecondaryColor.withOpacity(0.3),
                ),
              ),
            ),
          ),
          
          // Next/Get Started button
          ElevatedButton(
            onPressed: _nextPage,
            style: ElevatedButton.styleFrom(
              backgroundColor: ModernDesignSystem.primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 8),
                Icon(
                  _currentPage == _pages.length - 1 ? Icons.rocket_launch : Icons.arrow_forward,
                  size: 18,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final List<String> features;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.features,
  });
}

