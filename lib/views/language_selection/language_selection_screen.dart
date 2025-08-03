import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/design_system.dart';
import '../../core/language_service.dart';
import '../home/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageSelectionScreen extends StatefulWidget {
  @override
  _LanguageSelectionScreenState createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  String? _selectedLanguage;

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
    super.dispose();
  }

  Future<void> _selectLanguage(String languageCode) async {
    setState(() {
      _selectedLanguage = languageCode;
    });

    final languageService = Provider.of<LanguageService>(context, listen: false);
    await languageService.setLanguage(languageCode);

    // Save language preference
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language', languageCode);

    // Navigate to home screen
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

  @override
  Widget build(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context);
    
    return Scaffold(
      backgroundColor: ModernDesignSystem.backgroundColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          ModernDesignSystem.primaryColor,
                          ModernDesignSystem.primaryColor.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: ModernDesignSystem.primaryColor.withOpacity(0.3),
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // App icon
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.bug_report,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 20),
                        
                        // Title
                        Text(
                          languageService.getText('bug_scanner'),
                          style: ModernDesignSystem.headlineStyle.copyWith(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8),
                        
                        // Subtitle
                        Text(
                          languageService.getText('discover_world_of_insects'),
                          style: ModernDesignSystem.bodyStyle.copyWith(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.9),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 40),
                  
                  // Language selection title
                  Text(
                    languageService.getText('select_language'),
                    style: ModernDesignSystem.titleStyle.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: ModernDesignSystem.textPrimaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  SizedBox(height: 8),
                  
                  Text(
                    languageService.getText('choose_your_language'),
                    style: ModernDesignSystem.bodyStyle.copyWith(
                      color: ModernDesignSystem.textSecondaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  SizedBox(height: 32),
                  
                  // Language grid
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: LanguageService.supportedLanguages.length,
                      itemBuilder: (context, index) {
                        final languageCode = LanguageService.supportedLanguages.keys.elementAt(index);
                        final language = LanguageService.supportedLanguages[languageCode]!;
                        
                        return _buildLanguageCard(
                          languageCode: languageCode,
                          language: language,
                          isSelected: _selectedLanguage == languageCode,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageCard({
    required String languageCode,
    required Map<String, String> language,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => _selectLanguage(languageCode),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected 
              ? ModernDesignSystem.primaryColor 
              : ModernDesignSystem.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
                ? ModernDesignSystem.primaryColor 
                : ModernDesignSystem.borderColor,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected 
                  ? ModernDesignSystem.primaryColor.withOpacity(0.3)
                  : Colors.black.withOpacity(0.05),
              blurRadius: isSelected ? 10 : 5,
              offset: Offset(0, isSelected ? 5 : 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Flag emoji
            Text(
              language['flag']!,
              style: TextStyle(fontSize: 32),
            ),
            SizedBox(height: 12),
            
            // Language name
            Text(
              language['name']!,
              style: ModernDesignSystem.bodyStyle.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : ModernDesignSystem.textPrimaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: 4),
            
            // Native name
            Text(
              language['nativeName']!,
              style: ModernDesignSystem.captionStyle.copyWith(
                color: isSelected 
                    ? Colors.white.withOpacity(0.8)
                    : ModernDesignSystem.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            
            if (isSelected) ...[
              SizedBox(height: 8),
              Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 20,
              ),
            ],
          ],
        ),
      ),
    );
  }
} 
