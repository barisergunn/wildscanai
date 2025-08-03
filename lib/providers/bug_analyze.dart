import 'package:flutter/material.dart';
import '../models/bug_analysis_result.dart';
import '../services/bug_analysis_service.dart';
import '../database/database_helper.dart';
import '../core/language_service.dart';
import 'dart:io';
import 'dart:convert';

class BugIdentificationProvider extends ChangeNotifier {
  BugAnalysisResult? _currentResult;
  bool _isAnalyzing = false;
  String? _errorMessage;
  List<BugAnalysisResult> _history = [];

  BugAnalysisResult? get currentResult => _currentResult;
  bool get isAnalyzing => _isAnalyzing;
  String? get errorMessage => _errorMessage;
  List<BugAnalysisResult> get history => _history;

  Future<void> analyzeBug(File imageFile, String languageCode) async {
    _isAnalyzing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Convert image to base64
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      // Analyze with Gemini AI
      final bugAnalysisService = BugAnalysisService();
      final result = await bugAnalysisService.analyzeBugWithGemini(base64Image, languageCode);

      // Set the result
      _currentResult = result;

      // Save to database
      await _saveToDatabase(imageFile.path);

      // Add to history
      _history.insert(0, _currentResult!);

    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isAnalyzing = false;
      notifyListeners();
    }
  }

  Future<void> _saveToDatabase(String imagePath) async {
    if (_currentResult == null) return;

    final dbHelper = DatabaseHelper.instance;
    await dbHelper.insertIdentification({
      'name': _currentResult!.name,
      'image_path': imagePath,
      'result': jsonEncode(_currentResult!.toJson()),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'species': _currentResult!.species,
      'danger_level': _currentResult!.dangerLevel,
      'venomous': _currentResult!.venomous,
      'diseases': _currentResult!.diseases,
      'habitat': _currentResult!.habitat,
      'safety_tips': _currentResult!.safetyTips,
    });
  }

  Future<void> loadHistory() async {
    try {
      final dbHelper = DatabaseHelper.instance;
      final data = await dbHelper.getAllIdentifications();
      
      _history = data.map((item) {
        final resultData = jsonDecode(item['result']);
        return BugAnalysisResult.fromJson(resultData);
      }).toList();
      
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load history: $e';
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearCurrentResult() {
    _currentResult = null;
    notifyListeners();
  }
}
