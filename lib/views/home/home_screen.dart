import 'package:flutter/material.dart';
import 'package:water_drop_nav_bar/water_drop_nav_bar.dart';
import 'package:provider/provider.dart';
import '../../core/design_system.dart';
import '../../core/language_service.dart';
import '../bug_scan/bug_scan_screen.dart';
import '../ai_chat/ai_chat_screen.dart';
import '../history/history_screen.dart';

import 'dart:io';
import '../../database/database_helper.dart';
import '../history/history_screen.dart';
import '../../widgets/nature_bottom_navbar.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    HomeContent(onTabChange: null),
    BugScanScreen(),
    AIChatScreen(),
    HistoryScreen(),
  ];

  void _onTabChange(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeContent(onTabChange: _onTabChange),
      BugScanScreen(),
      AIChatScreen(),
      HistoryScreen(),
    ];
    return Scaffold(
      backgroundColor: ModernDesignSystem.backgroundColor,
      body: screens[_selectedIndex],
      bottomNavigationBar: NatureBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          NatureNavBarItem(
            icon: Icons.home,
            label: 'Home',
          ),
          NatureNavBarItem(
            icon: Icons.camera_alt,
            label: 'Scan',
          ),
          NatureNavBarItem(
            icon: Icons.psychology,
            label: 'AI',
          ),
          NatureNavBarItem(
            icon: Icons.history,
            label: 'History',
          ),
        ],
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  final void Function(int)? onTabChange;
  HomeContent({Key? key, this.onTabChange}) : super(key: key);

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

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
    _pulseController = AnimationController(
      duration: Duration(seconds: 2),
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
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
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
            child: CustomScrollView(
              slivers: [
                // Hero Section
                SliverToBoxAdapter(
                  child: _buildHeroSection(),
                ),
                
                // Spacing between Hero and Action Cards
                SliverToBoxAdapter(
                  child: SizedBox(height: ModernDesignSystem.spacingL),
                ),
                
                // Floating Action Cards
                SliverToBoxAdapter(
                  child: _buildFloatingActions(),
                ),
                
                // Spacing between Action Cards and Bug Fact
                SliverToBoxAdapter(
                  child: SizedBox(height: ModernDesignSystem.spacingXL),
                ),
                
                // Bug Fact Section
                SliverToBoxAdapter(
                  child: _buildBugFactSection(),
                ),
                
                // Bottom Spacing
                SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      height: 240,
      margin: EdgeInsets.all(ModernDesignSystem.spacingM),
      child: Stack(
        children: [
          // Background Card
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    ModernDesignSystem.primaryColor,
                    ModernDesignSystem.secondaryColor,
                  ],
                ),
                borderRadius: BorderRadius.circular(ModernDesignSystem.radiusXL),
                boxShadow: [
                  BoxShadow(
                    color: ModernDesignSystem.primaryColor.withOpacity(0.3),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
            ),
          ),
          
          // Floating Elements
          Positioned(
            top: 20,
            right: 20,
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Icon(
                      Icons.bug_report,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Content
          Positioned(
            bottom: 25,
            left: 25,
            right: 25,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Consumer<LanguageService>(
                  builder: (context, languageService, child) {
                    return Text(
                      languageService.getText('bug_identifier'),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    );
                  },
                ),
                SizedBox(height: 6),
                Consumer<LanguageService>(
                  builder: (context, languageService, child) {
                    return Text(
                      languageService.getText('discover_world_of_bugs'),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w400,
                      ),
                    );
                  },
                ),
                SizedBox(height: 15),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        color: Colors.white,
                        size: 14,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'AI Powered',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActions() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: ModernDesignSystem.spacingM),
      child: Row(
        children: [
          Expanded(
            child: _buildActionCard(
              icon: Icons.camera_alt,
              title: Provider.of<LanguageService>(context, listen: false).getText('scan_bug'),
              subtitle: Provider.of<LanguageService>(context, listen: false).getText('capture_photo'),
              gradient: LinearGradient(
                colors: [ModernDesignSystem.primaryColor, ModernDesignSystem.primaryColor.withOpacity(0.8)],
              ),
              onTap: () => widget.onTabChange?.call(1),
            ),
          ),
          SizedBox(width: ModernDesignSystem.spacingM),
          Expanded(
            child: _buildActionCard(
              icon: Icons.psychology,
              title: Provider.of<LanguageService>(context, listen: false).getText('ai_chat'),
              subtitle: Provider.of<LanguageService>(context, listen: false).getText('ask_anything'),
              gradient: LinearGradient(
                colors: [ModernDesignSystem.secondaryColor, ModernDesignSystem.secondaryColor.withOpacity(0.8)],
              ),
              onTap: () => widget.onTabChange?.call(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(ModernDesignSystem.radiusL),
          boxShadow: [
            BoxShadow(
              color: ModernDesignSystem.primaryColor.withOpacity(0.2),
              blurRadius: 15,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(ModernDesignSystem.spacingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 9,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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



  Widget _buildBugFactSection() {
    final languageService = Provider.of<LanguageService>(context);
    
    return Container(
      margin: EdgeInsets.all(ModernDesignSystem.spacingM),
      padding: EdgeInsets.all(ModernDesignSystem.spacingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ModernDesignSystem.accentColor.withOpacity(0.1),
            ModernDesignSystem.accentColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(ModernDesignSystem.radiusL),
        border: Border.all(
          color: ModernDesignSystem.accentColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(ModernDesignSystem.spacingM),
            decoration: BoxDecoration(
              color: ModernDesignSystem.accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(ModernDesignSystem.radiusM),
            ),
            child: Icon(
              Icons.lightbulb_outline,
              color: ModernDesignSystem.accentColor,
              size: 24,
            ),
          ),
          SizedBox(width: ModernDesignSystem.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  languageService.getText('bug_fact_of_day'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ModernDesignSystem.accentColor,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  languageService.getText('bug_fact_14'),
                  style: TextStyle(
                    fontSize: 14,
                    color: ModernDesignSystem.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
