import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/design_system.dart';
import '../../core/language_service.dart';
import '../home/home_screen.dart';
import '../onboarding/onboarding_screen.dart';
import '../language_selection/language_selection_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _mainAnimationController;
  late AnimationController _floatingAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _floatingAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkFirstLaunch();
  }

  void _initializeAnimations() {
    _mainAnimationController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );

    _floatingAnimationController = AnimationController(
      duration: Duration(milliseconds: 3000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainAnimationController,
      curve: Interval(0.0, 0.5, curve: Curves.easeInOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainAnimationController,
      curve: Interval(0.2, 0.7, curve: Curves.elasticOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _mainAnimationController,
      curve: Interval(0.3, 0.8, curve: Curves.easeOut),
    ));

    _floatingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _floatingAnimationController,
      curve: Curves.easeInOut,
    ));

    _mainAnimationController.forward();
    _floatingAnimationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _mainAnimationController.dispose();
    _floatingAnimationController.dispose();
    super.dispose();
  }

  Future<void> _checkFirstLaunch() async {
    await Future.delayed(Duration(seconds: 3));
    
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final isFirstLaunch = prefs.getBool('is_first_launch') ?? true;
    final hasSelectedLanguage = prefs.getString('selected_language') != null;

    if (isFirstLaunch) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => OnboardingScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: Duration(milliseconds: 500),
        ),
      );
    } else if (!hasSelectedLanguage) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => LanguageSelectionScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: Duration(milliseconds: 500),
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context);
    
    return Scaffold(
      backgroundColor: ModernDesignSystem.backgroundColor,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  ModernDesignSystem.backgroundColor,
                  ModernDesignSystem.surfaceColor.withOpacity(0.3),
                ],
              ),
            ),
          ),
          
          // Floating bugs only
          Positioned(
            top: 100,
            left: 50,
            child: AnimatedBuilder(
              animation: _floatingAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _floatingAnimation.value * 20),
                  child: _buildFloatingBug(Icons.bug_report, Color(0xFF8B4513).withOpacity(0.3)),
                );
              },
            ),
          ),
          Positioned(
            top: 200,
            right: 80,
            child: AnimatedBuilder(
              animation: _floatingAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, -_floatingAnimation.value * 15),
                  child: _buildFloatingBug(Icons.bug_report_outlined, Color(0xFF708090).withOpacity(0.2)),
                );
              },
            ),
          ),
          Positioned(
            bottom: 150,
            left: 100,
            child: AnimatedBuilder(
              animation: _floatingAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(_floatingAnimation.value * 10, 0),
                  child: _buildFloatingBug(Icons.bug_report, Color(0xFF228B22).withOpacity(0.2)),
                );
              },
            ),
          ),
          Positioned(
            top: 300,
            left: 80,
            child: AnimatedBuilder(
              animation: _floatingAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(-_floatingAnimation.value * 8, _floatingAnimation.value * 12),
                  child: _buildFloatingBug(Icons.bug_report_outlined, Color(0xFF8B0000).withOpacity(0.25)),
                );
              },
            ),
          ),
          Positioned(
            top: 150,
            right: 40,
            child: AnimatedBuilder(
              animation: _floatingAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(_floatingAnimation.value * 5, -_floatingAnimation.value * 8),
                  child: _buildFloatingBug(Icons.bug_report, Color(0xFF654321).withOpacity(0.2)),
                );
              },
            ),
          ),
          Positioned(
            bottom: 200,
            right: 60,
            child: AnimatedBuilder(
              animation: _floatingAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(-_floatingAnimation.value * 6, _floatingAnimation.value * 10),
                  child: _buildFloatingBug(Icons.bug_report_outlined, Color(0xFFFFD700).withOpacity(0.3)),
                );
              },
            ),
          ),
          
          // Main content
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // App icon
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              ModernDesignSystem.primaryColor,
                              ModernDesignSystem.primaryColor.withOpacity(0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: ModernDesignSystem.primaryColor.withOpacity(0.3),
                              blurRadius: 20,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.bug_report,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                      
                      SizedBox(height: 40),
                      
                      // App title
                      Text(
                        languageService.getText('bug_scanner'),
                        style: ModernDesignSystem.headlineStyle.copyWith(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: ModernDesignSystem.textPrimaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      SizedBox(height: 16),
                      
                      // App subtitle
                      Text(
                        languageService.getText('discover_world_of_insects'),
                        style: ModernDesignSystem.bodyStyle.copyWith(
                          fontSize: 16,
                          color: ModernDesignSystem.textSecondaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      SizedBox(height: 60),
                      
                      // Loading indicator
                      Column(
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              ModernDesignSystem.primaryColor,
                            ),
                            strokeWidth: 3,
                          ),
                          SizedBox(height: 16),
                          Text(
                            languageService.getText('initializing'),
                            style: ModernDesignSystem.bodyStyle.copyWith(
                              color: ModernDesignSystem.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingBug(IconData icon, Color color) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 20,
      ),
    );
  }
}
