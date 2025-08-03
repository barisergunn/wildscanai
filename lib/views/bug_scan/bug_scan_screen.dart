import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/design_system.dart';
import '../../core/language_service.dart';
import '../../services/bug_analysis_service.dart';
import '../../models/bug_analysis_result.dart';
import '../../providers/bug_analyze.dart';
import '../../services/admob_service.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

class BugScanScreen extends StatefulWidget {
  @override
  _BugScanScreenState createState() => _BugScanScreenState();
}

class _BugScanScreenState extends State<BugScanScreen> with TickerProviderStateMixin {
  File? _selectedImage;
  bool _isAnalyzing = false;
  BugAnalysisResult? _analysisResult;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _analysisResult = null;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _analyzeImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isAnalyzing = true;
    });

    try {
      // Get selected language
      final languageService = Provider.of<LanguageService>(context, listen: false);
      final currentLanguage = await languageService.getCurrentLanguage();
      
      // Debug language code
      print('Current Language Code: $currentLanguage');
      
      // Get bug identification provider
      final bugProvider = Provider.of<BugIdentificationProvider>(context, listen: false);
      
      // Analyze the bug with current language
      await bugProvider.analyzeBug(_selectedImage!, currentLanguage);
      
      // Get the result
      _analysisResult = bugProvider.currentResult;
      
      // Show interstitial ad after successful analysis
      try {
        await AdMobService().showInterstitialAd();
      } catch (e) {
        print('Ad failed to show: $e');
      }
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Analysis failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  Color _getDangerLevelColor(String dangerLevel) {
    switch (dangerLevel.toLowerCase()) {
      case 'high':
      case 'yüksek':
      case 'high danger':
      case 'yüksek tehlike':
        return Colors.red;
      case 'medium':
      case 'orta':
      case 'medium danger':
      case 'orta tehlike':
        return Colors.orange;
      case 'low':
      case 'düşük':
      case 'low danger':
      case 'düşük tehlike':
        return Colors.green;
      default:
        return Colors.grey;
    }
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
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(ModernDesignSystem.spacingM),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [ModernDesignSystem.primaryColor.withOpacity(0.1), ModernDesignSystem.primaryColor.withOpacity(0.05)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(ModernDesignSystem.radiusM),
                        ),
                        child: Icon(
                          Icons.bug_report,
                          color: ModernDesignSystem.primaryColor,
                          size: 28,
                        ),
                      ),
                      SizedBox(width: ModernDesignSystem.spacingM),
                      Expanded(
                        child: Text(
                          languageService.getText('scan_bug'),
                          style: ModernDesignSystem.headlineStyle,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: ModernDesignSystem.spacingL),
                  
                  // Image Selection Section
                  if (_selectedImage == null) ...[
                    Container(
                      width: double.infinity,
                      height: 300,
                      decoration: ModernDesignSystem.modernCardDecoration,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(ModernDesignSystem.spacingL),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [ModernDesignSystem.primaryColor.withOpacity(0.1), ModernDesignSystem.primaryColor.withOpacity(0.05)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(ModernDesignSystem.radiusL),
                            ),
                            child: Icon(
                              Icons.camera_alt_outlined,
                              size: 64,
                              color: ModernDesignSystem.primaryColor,
                            ),
                          ),
                          SizedBox(height: ModernDesignSystem.spacingM),
                          Text(
                            languageService.getText('capture_photo'),
                            style: ModernDesignSystem.bodyStyle.copyWith(
                              color: ModernDesignSystem.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: ModernDesignSystem.spacingL),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _pickImage(ImageSource.camera),
                                  icon: Icon(Icons.camera_alt),
                                  label: Text(languageService.getText('take_photo')),
                                  style: ModernDesignSystem.primaryButtonStyle,
                                ),
                              ),
                              SizedBox(width: ModernDesignSystem.spacingM),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _pickImage(ImageSource.gallery),
                                  icon: Icon(Icons.photo_library),
                                  label: Text(languageService.getText('gallery')),
                                  style: ModernDesignSystem.primaryButtonStyle.copyWith(
                                    backgroundColor: MaterialStateProperty.all(Colors.transparent),
                                    foregroundColor: MaterialStateProperty.all(ModernDesignSystem.primaryColor),
                                    side: MaterialStateProperty.all(BorderSide(
                                      color: ModernDesignSystem.primaryColor,
                                      width: 2,
                                    )),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // Selected Image
                    Container(
                      width: double.infinity,
                      height: 300,
                      decoration: ModernDesignSystem.modernCardDecoration,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(ModernDesignSystem.radiusL),
                        child: Image.file(
                          _selectedImage!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(height: ModernDesignSystem.spacingM),
                    
                    // Analyze Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isAnalyzing ? null : _analyzeImage,
                        style: ModernDesignSystem.primaryButtonStyle.copyWith(
                          backgroundColor: MaterialStateProperty.all(
                            _isAnalyzing 
                              ? ModernDesignSystem.textLight 
                              : ModernDesignSystem.primaryColor,
                          ),
                        ),
                        child: _isAnalyzing
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: ModernDesignSystem.spacingS),
                                  Text(
                                    languageService.getText('analyzing'),
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              )
                            : Text(
                                languageService.getText('identify_bugs'),
                                style: TextStyle(color: Colors.white),
                              ),
                      ),
                    ),
                    
                    // Change Image Button
                    SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _selectedImage = null;
                            _analysisResult = null;
                          });
                        },
                        style: ModernDesignSystem.outlinedButtonStyle,
                        child: Text(languageService.getText('choose_gallery')),
                      ),
                    ),
                  ],
                  
                  // Analysis Result
                  if (_analysisResult != null) ...[
                    SizedBox(height: ModernDesignSystem.spacingL),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(ModernDesignSystem.spacingL),
                      decoration: ModernDesignSystem.modernCardDecoration,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header with success indicator
                          Container(
                            padding: EdgeInsets.all(ModernDesignSystem.spacingM),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [ModernDesignSystem.successColor.withOpacity(0.1), ModernDesignSystem.successColor.withOpacity(0.05)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(ModernDesignSystem.radiusM),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(ModernDesignSystem.spacingS),
                                  decoration: BoxDecoration(
                                    color: ModernDesignSystem.successColor,
                                    borderRadius: BorderRadius.circular(ModernDesignSystem.radiusS),
                                  ),
                                  child: Icon(
                                    Icons.check_circle,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                SizedBox(width: ModernDesignSystem.spacingM),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        languageService.getText('analysis_complete'),
                                        style: ModernDesignSystem.subtitleStyle.copyWith(
                                          color: ModernDesignSystem.successColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        'AI-powered identification',
                                        style: ModernDesignSystem.captionStyle.copyWith(
                                          color: ModernDesignSystem.successColor.withOpacity(0.8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: ModernDesignSystem.spacingL),
                          
                          // Bug Name with icon
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(ModernDesignSystem.spacingS),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [ModernDesignSystem.primaryColor.withOpacity(0.1), ModernDesignSystem.primaryColor.withOpacity(0.05)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(ModernDesignSystem.radiusS),
                                ),
                                child: Icon(
                                  Icons.bug_report,
                                  color: ModernDesignSystem.primaryColor,
                                  size: 20,
                                ),
                              ),
                              SizedBox(width: ModernDesignSystem.spacingM),
                              Expanded(
                                child: Text(
                                  _analysisResult!.name,
                                  style: ModernDesignSystem.headlineStyle.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: ModernDesignSystem.spacingM),
                          
                          // Quick Info Cards
                          Row(
                            children: [
                              // Species Card
                              if (_analysisResult!.species.isNotEmpty) ...[
                                Expanded(
                                  child: _buildInfoCard(
                                    icon: Icons.category,
                                    title: languageService.getText('species'),
                                    value: _analysisResult!.species,
                                    color: ModernDesignSystem.primaryColor,
                                  ),
                                ),
                                SizedBox(width: ModernDesignSystem.spacingS),
                              ],
                              
                              // Danger Level Card
                              if (_analysisResult!.dangerLevel.isNotEmpty) ...[
                                Expanded(
                                  child: _buildDangerCard(_analysisResult!.dangerLevel),
                                ),
                              ],
                            ],
                          ),
                          SizedBox(height: ModernDesignSystem.spacingM),
                          
                          // Venomous Card
                          if (_analysisResult!.venomous.isNotEmpty) ...[
                            _buildDetailCard(
                              icon: Icons.warning,
                              title: languageService.getText('venomous'),
                              content: _analysisResult!.venomous,
                              color: ModernDesignSystem.warningColor,
                            ),
                            SizedBox(height: ModernDesignSystem.spacingM),
                          ],
                          
                          // Habitat Card
                          if (_analysisResult!.habitat.isNotEmpty) ...[
                            _buildDetailCard(
                              icon: Icons.location_on,
                              title: languageService.getText('habitat'),
                              content: _analysisResult!.habitat,
                              color: ModernDesignSystem.infoColor,
                            ),
                            SizedBox(height: ModernDesignSystem.spacingM),
                          ],
                          
                          // Description Card
                          if (_analysisResult!.description.isNotEmpty) ...[
                            _buildDetailCard(
                              icon: Icons.description,
                              title: languageService.getText('description'),
                              content: _analysisResult!.description,
                              color: ModernDesignSystem.secondaryColor,
                            ),
                            SizedBox(height: ModernDesignSystem.spacingM),
                          ],
                          
                          // Diseases Card
                          if (_analysisResult!.diseases.isNotEmpty) ...[
                            _buildDetailCard(
                              icon: Icons.medical_services,
                              title: languageService.getText('diseases'),
                              content: _analysisResult!.diseases,
                              color: ModernDesignSystem.errorColor,
                            ),
                            SizedBox(height: ModernDesignSystem.spacingM),
                          ],
                          
                          // Safety Tips Card
                          if (_analysisResult!.safetyTips.isNotEmpty) ...[
                            _buildDetailCard(
                              icon: Icons.security,
                              title: languageService.getText('safety_tips'),
                              content: _analysisResult!.safetyTips,
                              color: ModernDesignSystem.successColor,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                  
                  // Error Message
                  if (Provider.of<BugIdentificationProvider>(context).errorMessage != null) ...[
                    SizedBox(height: ModernDesignSystem.spacingL),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(ModernDesignSystem.spacingL),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [ModernDesignSystem.errorColor.withOpacity(0.1), ModernDesignSystem.errorColor.withOpacity(0.05)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(ModernDesignSystem.radiusL),
                        border: Border.all(
                          color: ModernDesignSystem.errorColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: ModernDesignSystem.errorColor,
                                size: 24,
                              ),
                              SizedBox(width: ModernDesignSystem.spacingS),
                              Text(
                                'Analysis Error',
                                style: ModernDesignSystem.subtitleStyle.copyWith(
                                  color: ModernDesignSystem.errorColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: ModernDesignSystem.spacingS),
                          Text(
                            Provider.of<BugIdentificationProvider>(context).errorMessage!,
                            style: ModernDesignSystem.bodyStyle.copyWith(
                              color: ModernDesignSystem.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: ModernDesignSystem.spacingS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: ModernDesignSystem.bodyStyle.copyWith(
              fontWeight: FontWeight.w600,
              color: ModernDesignSystem.textSecondary,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: ModernDesignSystem.bodyStyle.copyWith(
                color: ModernDesignSystem.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(ModernDesignSystem.spacingM),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(ModernDesignSystem.radiusM),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: ModernDesignSystem.spacingS),
          Text(
            title,
            style: ModernDesignSystem.bodyStyle.copyWith(
              fontWeight: FontWeight.w600,
              color: ModernDesignSystem.textSecondary,
            ),
          ),
          SizedBox(height: ModernDesignSystem.spacingS),
          Text(
            value,
            style: ModernDesignSystem.headlineStyle.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDangerCard(String dangerLevel) {
    final languageService = Provider.of<LanguageService>(context);
    return Container(
      padding: EdgeInsets.all(ModernDesignSystem.spacingM),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_getDangerLevelColor(dangerLevel), _getDangerLevelColor(dangerLevel).withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(ModernDesignSystem.radiusM),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning, color: Colors.white, size: 24),
          SizedBox(height: ModernDesignSystem.spacingS),
          Text(
            languageService.getText('danger_level'),
            style: ModernDesignSystem.bodyStyle.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(height: ModernDesignSystem.spacingS),
          Text(
            dangerLevel,
            style: ModernDesignSystem.headlineStyle.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(ModernDesignSystem.spacingM),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(ModernDesignSystem.radiusM),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: ModernDesignSystem.spacingS),
          Text(
            title,
            style: ModernDesignSystem.bodyStyle.copyWith(
              fontWeight: FontWeight.w600,
              color: ModernDesignSystem.textSecondary,
            ),
          ),
          SizedBox(height: ModernDesignSystem.spacingS),
          Text(
            content,
            style: ModernDesignSystem.bodyStyle,
          ),
        ],
      ),
    );
  }
}
