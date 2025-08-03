import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/design_system.dart';
import '../core/language_service.dart';
import 'dart:io';

class BugResultCard extends StatefulWidget {
  final String bugName;
  final String imagePath;
  final Map<String, dynamic> result;
  final VoidCallback? onTap;

  const BugResultCard({
    Key? key,
    required this.bugName,
    required this.imagePath,
    required this.result,
    this.onTap,
  }) : super(key: key);

  @override
  _BugResultCardState createState() => _BugResultCardState();
}

class _BugResultCardState extends State<BugResultCard> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    if (_isExpanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  Color _getDangerLevelColor(String? dangerLevel) {
    if (dangerLevel == null) return Colors.grey;
    
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
    return GestureDetector(
      onTap: _toggleExpanded,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: ModernDesignSystem.modernCardDecoration,
              child: Column(
                children: [
                  _buildBugImage(),
                  _buildBugInfo(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBugImage() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(ModernDesignSystem.radiusL)),
        gradient: LinearGradient(
          colors: [ModernDesignSystem.primaryColor.withOpacity(0.1), ModernDesignSystem.primaryColor.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(ModernDesignSystem.radiusL)),
        child: widget.imagePath.isNotEmpty
            ? Image.file(
                File(widget.imagePath),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [ModernDesignSystem.primaryColor.withOpacity(0.1), ModernDesignSystem.primaryColor.withOpacity(0.05)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bug_report,
                          size: 48,
                          color: ModernDesignSystem.primaryColor,
                        ),
                        SizedBox(height: ModernDesignSystem.spacingS),
                        Text(
                          'Bug Image',
                          style: ModernDesignSystem.bodyStyle.copyWith(
                            color: ModernDesignSystem.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              )
            : Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [ModernDesignSystem.primaryColor.withOpacity(0.1), ModernDesignSystem.primaryColor.withOpacity(0.05)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bug_report,
                      size: 48,
                      color: ModernDesignSystem.primaryColor,
                    ),
                    SizedBox(height: ModernDesignSystem.spacingS),
                    Text(
                      'No Image',
                      style: ModernDesignSystem.bodyStyle.copyWith(
                        color: ModernDesignSystem.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildBugInfo() {
    final languageService = Provider.of<LanguageService>(context);
    
    return Container(
      padding: EdgeInsets.all(ModernDesignSystem.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with name and danger level
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
                  widget.bugName,
                  style: ModernDesignSystem.titleStyle.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (widget.result['danger_level'] != null)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: ModernDesignSystem.spacingS, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_getDangerLevelColor(widget.result['danger_level']), _getDangerLevelColor(widget.result['danger_level']).withOpacity(0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(ModernDesignSystem.radiusS),
                  ),
                  child: Text(
                    widget.result['danger_level'],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
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
              if (widget.result['species'] != null && widget.result['species'].isNotEmpty) ...[
                Expanded(
                  child: _buildInfoCard(
                    icon: Icons.category,
                    title: languageService.getText('species'),
                    value: widget.result['species'],
                    color: ModernDesignSystem.primaryColor,
                  ),
                ),
                SizedBox(width: ModernDesignSystem.spacingS),
              ],
              
              // Venomous Card
              if (widget.result['venomous'] != null && widget.result['venomous'].isNotEmpty) ...[
                Expanded(
                  child: _buildInfoCard(
                    icon: Icons.warning,
                    title: languageService.getText('venomous'),
                    value: widget.result['venomous'].split('.').first + '.',
                    color: ModernDesignSystem.warningColor,
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: ModernDesignSystem.spacingM),
          
          // Habitat Card
          if (widget.result['habitat'] != null && widget.result['habitat'].isNotEmpty) ...[
            _buildDetailCard(
              icon: Icons.location_on,
              title: languageService.getText('habitat'),
              content: widget.result['habitat'],
              color: ModernDesignSystem.infoColor,
            ),
            SizedBox(height: ModernDesignSystem.spacingM),
          ],
          
          // Expandable details
          if (_isExpanded) ...[
            // Description Card
            if (widget.result['description'] != null && widget.result['description'].isNotEmpty) ...[
              _buildDetailCard(
                icon: Icons.description,
                title: languageService.getText('description'),
                content: widget.result['description'],
                color: ModernDesignSystem.secondaryColor,
              ),
              SizedBox(height: ModernDesignSystem.spacingM),
            ],
            
            // Diseases Card
            if (widget.result['diseases'] != null && widget.result['diseases'].isNotEmpty) ...[
              _buildDetailCard(
                icon: Icons.medical_services,
                title: languageService.getText('diseases'),
                content: widget.result['diseases'],
                color: ModernDesignSystem.errorColor,
              ),
              SizedBox(height: ModernDesignSystem.spacingM),
            ],
            
            // Safety Tips Card
            if (widget.result['safety_tips'] != null && widget.result['safety_tips'].isNotEmpty) ...[
              _buildDetailCard(
                icon: Icons.security,
                title: languageService.getText('safety_tips'),
                content: widget.result['safety_tips'],
                color: ModernDesignSystem.successColor,
              ),
            ],
          ],
          
          // Expand/Collapse button
          SizedBox(height: ModernDesignSystem.spacingS),
          Center(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [ModernDesignSystem.primaryColor.withOpacity(0.1), ModernDesignSystem.primaryColor.withOpacity(0.05)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(ModernDesignSystem.radiusM),
              ),
              child: IconButton(
                onPressed: _toggleExpanded,
                icon: Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: ModernDesignSystem.primaryColor,
                ),
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
          Icon(icon, color: color, size: 20),
          SizedBox(height: ModernDesignSystem.spacingS),
          Text(
            title,
            style: ModernDesignSystem.captionStyle.copyWith(
              fontWeight: FontWeight.w600,
              color: ModernDesignSystem.textSecondary,
            ),
          ),
          SizedBox(height: ModernDesignSystem.spacingXS),
          Text(
            value,
            style: ModernDesignSystem.bodyStyle.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
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
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              SizedBox(width: ModernDesignSystem.spacingS),
              Text(
                title,
                style: ModernDesignSystem.bodyStyle.copyWith(
                  fontWeight: FontWeight.w600,
                  color: ModernDesignSystem.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: ModernDesignSystem.spacingS),
          Text(
            content,
            style: ModernDesignSystem.bodyStyle.copyWith(
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
} 
