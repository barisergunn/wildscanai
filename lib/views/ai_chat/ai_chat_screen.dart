import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../core/design_system.dart';
import '../../core/language_service.dart';
import '../../core/config.dart';
import '../../services/admob_service.dart';

class AIChatScreen extends StatefulWidget {
  @override
  _AIChatScreenState createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  // Gemini AI model
  late GenerativeModel _model;
  late ChatSession _chatSession;

  @override
  void initState() {
    super.initState();
    
    // Initialize Gemini AI
    _model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: geminiApiKey,
    );
    _chatSession = _model.startChat();
    
    _initializeAnimations();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final languageService = Provider.of<LanguageService>(context, listen: false);
      _addBotMessage(languageService.getText('hello_message'));
    });
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
    _animationController.forward();
  }

  void _addBotMessage(String message) {
    _messages.add(ChatMessage(message, false));
  }

  void _addUserMessage(String message) {
    _messages.add(ChatMessage(message, true));
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final message = _messageController.text.trim();
    _addUserMessage(message);
    _messageController.clear();
    _scrollToBottom();

    // Show interstitial ad when user sends a message
    try {
      await AdMobService().showInterstitialAd();
    } catch (e) {
      print('Ad failed to show: $e');
    }

    // Show typing indicator
    setState(() {
      _isTyping = true;
    });

    try {
      // Get language for context
      final languageService = Provider.of<LanguageService>(context, listen: false);
      final currentLanguage = languageService.currentLanguage;
      
      // Create context-aware prompt
      String systemPrompt = _getSystemPrompt(currentLanguage);
      
      // Send message to Gemini AI
      final response = await _chatSession.sendMessage(
        Content.text('$systemPrompt\n\nUser: $message\n\nAssistant:'),
      );

      if (response.text != null) {
        _addBotMessage(response.text!);
      } else {
        _addBotMessage('Sorry, I could not generate a response. Please try again.');
      }
    } catch (e) {
      _addBotMessage('Sorry, an error occurred. Please try again.');
      print('Chat error: $e');
    } finally {
      setState(() {
        _isTyping = false;
      });
      _scrollToBottom();
    }
  }

  String _getSystemPrompt(String language) {
    String languageInstruction = '';
    
    switch (language) {
      case 'tr':
        languageInstruction = 'ÇOK ÖNEMLİ: Tüm yanıtlarınız Türkçe olmalı. Sadece Türkçe yanıt verin.';
        break;
      case 'es':
        languageInstruction = 'MUY IMPORTANTE: Todas tus respuestas deben ser en español. Responde SOLO en español.';
        break;
      case 'hi':
        languageInstruction = 'बहुत महत्वपूर्ण: आपके सभी जवाब हिंदी में होने चाहिए। केवल हिंदी में जवाब दें।';
        break;
      case 'ar':
        languageInstruction = 'مهم جداً: جميع إجاباتك يجب أن تكون باللغة العربية. أجب باللغة العربية فقط.';
        break;
      case 'id':
        languageInstruction = 'SANGAT PENTING: Semua jawaban Anda harus dalam bahasa Indonesia. Jawab HANYA dalam bahasa Indonesia.';
        break;
      case 'vi':
        languageInstruction = 'RẤT QUAN TRỌNG: Tất cả câu trả lời của bạn phải bằng tiếng Việt. Chỉ trả lời bằng tiếng Việt.';
        break;
      case 'ko':
        languageInstruction = '매우 중요: 모든 답변은 한국어여야 합니다. 한국어로만 답변하세요.';
        break;
      case 'ja':
        languageInstruction = '非常に重要：すべての回答は日本語でなければなりません。日本語でのみ回答してください。';
        break;
      default:
        languageInstruction = 'VERY IMPORTANT: All your responses must be in English. Respond ONLY in English.';
    }
    
    return '''You are an expert entomologist and herpetologist assistant. You help users identify insects, spiders, snakes, scorpions, and other small animals. You provide information about:

1. **Identification**: Help identify species based on descriptions or characteristics
2. **Danger Assessment**: Evaluate if an animal is dangerous, venomous, or harmful
3. **Habitat Information**: Explain where different species live and thrive
4. **Safety Tips**: Provide advice on how to safely interact with or avoid dangerous species
5. **Disease Information**: Explain what diseases certain insects can carry
6. **Behavior**: Describe typical behaviors and characteristics
7. **Prevention**: Tips for preventing encounters with dangerous species

Always prioritize safety and provide accurate, helpful information. If you're unsure about something, say so rather than guessing.

$languageInstruction Be friendly, informative, and safety-conscious.''';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context);
    
    return Scaffold(
      backgroundColor: ModernDesignSystem.backgroundColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(ModernDesignSystem.spacingM),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [ModernDesignSystem.secondaryColor.withOpacity(0.1), ModernDesignSystem.secondaryColor.withOpacity(0.05)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(ModernDesignSystem.radiusM),
                    ),
                    child: Icon(
                      Icons.psychology,
                      color: ModernDesignSystem.secondaryColor,
                      size: 28,
                    ),
                  ),
                  SizedBox(width: ModernDesignSystem.spacingM),
                  Expanded(
                    child: Text(
                      languageService.getText('ai_chat'),
                      style: ModernDesignSystem.headlineStyle,
                    ),
                  ),
                ],
              ),
              SizedBox(height: ModernDesignSystem.spacingL),
              
              // Messages
              Expanded(
                child: _messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.bug_report,
                              size: 64,
                              color: ModernDesignSystem.textSecondaryColor,
                            ),
                            SizedBox(height: 16),
                            Text(
                              languageService.getText('ask_anything'),
                              style: ModernDesignSystem.bodyStyle.copyWith(
                                color: ModernDesignSystem.textSecondaryColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.all(16),
                        itemCount: _messages.length + (_isTyping ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _messages.length && _isTyping) {
                            return _buildTypingIndicator();
                          }
                          return _buildMessage(_messages[index]);
                        },
                      ),
              ),
              
              // Input Section
              Container(
                padding: EdgeInsets.all(ModernDesignSystem.spacingM),
                decoration: ModernDesignSystem.modernCardDecoration,
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: ModernDesignSystem.backgroundColor,
                          borderRadius: BorderRadius.circular(ModernDesignSystem.radiusL),
                          border: Border.all(
                            color: ModernDesignSystem.textMuted.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: TextField(
                          controller: _messageController,
                          style: ModernDesignSystem.bodyStyle,
                          decoration: InputDecoration(
                            hintText: languageService.getText('type_message'),
                            hintStyle: ModernDesignSystem.bodyStyle.copyWith(
                              color: ModernDesignSystem.textSecondary,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: ModernDesignSystem.spacingM,
                              vertical: ModernDesignSystem.spacingS,
                            ),
                          ),
                          maxLines: null,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                    ),
                    SizedBox(width: ModernDesignSystem.spacingS),
                    Container(
                      decoration: BoxDecoration(
                        gradient: ModernDesignSystem.primaryGradient,
                        borderRadius: BorderRadius.circular(ModernDesignSystem.radiusM),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.send,
                          color: Colors.white,
                        ),
                        onPressed: _sendMessage,
                      ),
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

  Widget _buildMessage(ChatMessage message) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: ModernDesignSystem.primaryColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.bug_report,
                color: Colors.white,
                size: 18,
              ),
            ),
            SizedBox(width: 12),
          ],
          Expanded(
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: message.isUser 
                    ? ModernDesignSystem.primaryColor
                    : ModernDesignSystem.surfaceColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: ModernDesignSystem.bodyStyle.copyWith(
                  color: message.isUser ? Colors.white : ModernDesignSystem.textPrimaryColor,
                ),
              ),
            ),
          ),
          if (message.isUser) ...[
            SizedBox(width: 12),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: ModernDesignSystem.primaryColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: 18,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: ModernDesignSystem.primaryColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.bug_report,
              color: Colors.white,
              size: 18,
            ),
          ),
          SizedBox(width: 12),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ModernDesignSystem.surfaceColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      ModernDesignSystem.primaryColor,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  'Typing...',
                  style: ModernDesignSystem.bodyStyle.copyWith(
                    color: ModernDesignSystem.textSecondaryColor,
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

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage(this.text, this.isUser);
}
