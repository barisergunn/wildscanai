import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
class AdMobService {
  static final AdMobService _instance = AdMobService._internal();
  factory AdMobService() => _instance;
  AdMobService._internal();
  // Google AdMob Test Ad Unit IDs
  static String get _interstitialAdUnitId => Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/1033173712'  // Android Interstitial Test ID
      : 'ca-app-pub-3940256099942544/4411468910'; // iOS Interstitial Test ID
  static String get _appOpenAdUnitId => Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/3419835294'  // Android App Open Test ID
      : 'ca-app-pub-3940256099942544/5572853021'; // iOS App Open Test ID
  // Ad instances
  InterstitialAd? _interstitialAd;
  AppOpenAd? _appOpenAd;
  bool _isInterstitialAdReady = false;
  bool _isAppOpenAdReady = false;
  // Getters
  bool get isInterstitialAdReady => _isInterstitialAdReady;
  bool get isAppOpenAdReady => _isAppOpenAdReady;
  /// Load interstitial ad
  Future<void> loadInterstitialAd() async {
    print('AdMobService: Loading interstitial ad with ID: $_interstitialAdUnitId');
    await InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          print('AdMobService: Interstitial ad loaded successfully');
          _interstitialAd = ad;
          _isInterstitialAdReady = true;
        },
        onAdFailedToLoad: (error) {
          print('AdMobService: Interstitial ad failed to load: $error');
          _isInterstitialAdReady = false;
        },
      ),
    );
  }
  /// Show interstitial ad
  Future<void> showInterstitialAd() async {
    print('AdMobService: Attempting to show interstitial ad');
    print('AdMobService: _interstitialAd is null: ${_interstitialAd == null}');
    print('AdMobService: _isInterstitialAdReady: $_isInterstitialAdReady');
    
    if (_interstitialAd != null && _isInterstitialAdReady) {
      try {
        print('AdMobService: Showing existing ad');
        await _interstitialAd!.show();
        _isInterstitialAdReady = false;
        _interstitialAd = null;
        // Load next interstitial ad
        loadInterstitialAd();
      } catch (e) {
        print('AdMobService: Error showing existing ad: $e');
        _isInterstitialAdReady = false;
        _interstitialAd = null;
        // Load next interstitial ad
        loadInterstitialAd();
      }
    } else {
      // Try to load a new ad if current one is not ready
      if (!_isInterstitialAdReady) {
        print('AdMobService: Loading new ad');
        await loadInterstitialAd();
        // Wait a bit and try again
        await Future.delayed(Duration(seconds: 2));
        if (_interstitialAd != null && _isInterstitialAdReady) {
          try {
            print('AdMobService: Showing newly loaded ad');
            await _interstitialAd!.show();
            _isInterstitialAdReady = false;
            _interstitialAd = null;
            loadInterstitialAd();
          } catch (e) {
            print('AdMobService: Error showing newly loaded ad: $e');
            _isInterstitialAdReady = false;
            _interstitialAd = null;
            loadInterstitialAd();
          }
        } else {
          print('AdMobService: Failed to load new ad');
        }
      }
    }
  }
  /// Load app open ad
  Future<void> loadAppOpenAd() async {
    await AppOpenAd.load(
      adUnitId: _appOpenAdUnitId,
      request: const AdRequest(),
      orientation: AppOpenAd.orientationPortrait,
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          _isAppOpenAdReady = true;
        },
        onAdFailedToLoad: (error) {
          _isAppOpenAdReady = false;
        },
      ),
    );
  }
  /// Show app open ad
  Future<void> showAppOpenAd() async {
    if (_appOpenAd != null && _isAppOpenAdReady) {
      await _appOpenAd!.show();
      _isAppOpenAdReady = false;
      _appOpenAd = null;
      // Load next app open ad
      loadAppOpenAd();
    }
  }
  /// Dispose all ads
  void dispose() {
    _interstitialAd?.dispose();
    _appOpenAd?.dispose();
  }
  /// Initialize all ads
  Future<void> initializeAds() async {
    try {
      print('AdMobService: Initializing ads');
      // Set test device ID for development
      MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(
          testDeviceIds: ['A799A77A302906630D801BF242FBE58F'], // Test device ID from logs
        ),
      );
      print('AdMobService: Loading interstitial ad');
      await loadInterstitialAd();
      print('AdMobService: Loading app open ad');
      await loadAppOpenAd();
      print('AdMobService: Ads initialization completed');
    } catch (e) {
      print('AdMobService: Error initializing ads: $e');
    }
  }
} 
