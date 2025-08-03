import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/design_system.dart';
import '../../core/language_service.dart';
import '../../database/database_helper.dart';
import '../../widgets/bug_result_card.dart';
import 'dart:io';
import 'dart:convert';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> with TickerProviderStateMixin {
  List<Map<String, dynamic>> _identifications = [];
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadIdentifications();
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

  Future<void> _loadIdentifications() async {
    try {
      final dbHelper = DatabaseHelper.instance;
      final data = await dbHelper.getAllIdentifications();
      setState(() {
        _identifications = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading identifications: $e');
    }
  }

  Future<void> _deleteIdentification(int id) async {
    try {
      final dbHelper = DatabaseHelper.instance;
      await dbHelper.deleteIdentification(id);
      await _loadIdentifications();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Record deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting record: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildIdentificationCard(Map<String, dynamic> item) {
    final languageService = Provider.of<LanguageService>(context);
    
    // Parse the result JSON
    Map<String, dynamic> result = {};
    try {
      if (item['result'] != null) {
        result = jsonDecode(item['result']);
      }
    } catch (e) {
      print('Error parsing result JSON: $e');
    }

    final String bugName = result['name'] ?? result['species'] ?? item['name'] ?? 'Unknown Bug';
    final String imagePath = item['image_path'] ?? '';

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: ModernDesignSystem.modernCardDecoration,
      child: Column(
        children: [
          // Header with timestamp
          Container(
            padding: EdgeInsets.symmetric(horizontal: ModernDesignSystem.spacingM, vertical: ModernDesignSystem.spacingS),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [ModernDesignSystem.accentColor.withOpacity(0.1), ModernDesignSystem.accentColor.withOpacity(0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(ModernDesignSystem.radiusL)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: ModernDesignSystem.accentColor,
                ),
                SizedBox(width: ModernDesignSystem.spacingS),
                Text(
                  _formatTimestamp(item['timestamp']),
                  style: ModernDesignSystem.captionStyle.copyWith(
                    color: ModernDesignSystem.accentColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Spacer(),
                IconButton(
                  onPressed: () => _showDeleteDialog(item['id']),
                  icon: Icon(
                    Icons.delete_outline,
                    color: ModernDesignSystem.errorColor,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
          
          // Bug result card
          BugResultCard(
            bugName: bugName,
            imagePath: imagePath,
            result: result,
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  void _showDeleteDialog(int id) {
    final languageService = Provider.of<LanguageService>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Record'),
        content: Text(languageService.getText('confirm_delete')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(languageService.getText('cancel')),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteIdentification(id);
            },
            child: Text(
              languageService.getText('delete'),
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
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
            child: Column(
              children: [
                // Header
                Row(
                  children: [
                Container(
                      padding: EdgeInsets.all(ModernDesignSystem.spacingM),
                  decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [ModernDesignSystem.accentColor.withOpacity(0.1), ModernDesignSystem.accentColor.withOpacity(0.05)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(ModernDesignSystem.radiusM),
                  ),
                      child: Icon(
                        Icons.history,
                        color: ModernDesignSystem.accentColor,
                        size: 28,
                      ),
                    ),
                    SizedBox(width: ModernDesignSystem.spacingM),
                      Expanded(
                        child: Text(
                          languageService.getText('history'),
                          style: ModernDesignSystem.headlineStyle,
                          ),
                        ),
                    ],
                ),
                SizedBox(height: ModernDesignSystem.spacingL),
                
                // Content
                Expanded(
                  child: _isLoading
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  ModernDesignSystem.primaryColor,
                                ),
                              ),
                              SizedBox(height: 16),
                              Text(
                                languageService.getText('loading_bug_history'),
                                style: ModernDesignSystem.bodyStyle.copyWith(
                                  color: ModernDesignSystem.textSecondaryColor,
                                ),
                              ),
                            ],
                          ),
                        )
                      : _identifications.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.bug_report_outlined,
                                    size: 64,
                                    color: ModernDesignSystem.textSecondaryColor,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    languageService.getText('no_bugs_identified'),
                                    style: ModernDesignSystem.titleStyle.copyWith(
                                      color: ModernDesignSystem.textSecondaryColor,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    languageService.getText('start_photo'),
                                    style: ModernDesignSystem.bodyStyle.copyWith(
                                      color: ModernDesignSystem.textSecondaryColor,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _loadIdentifications,
                              child: ListView.builder(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                itemCount: _identifications.length,
                                itemBuilder: (context, index) {
                                  return _buildIdentificationCard(_identifications[index]);
                                },
                              ),
                            ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
