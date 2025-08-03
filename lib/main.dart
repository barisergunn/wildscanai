import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'core/design_system.dart';
import 'core/language_service.dart';
import 'providers/bug_analyze.dart';
import 'providers/aicoach.dart';


import 'services/admob_service.dart';
import 'views/splash/splash_screen.dart';
import 'views/history/history_screen.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize AdMob with error handling
  try {
    await MobileAds.instance.initialize();
    // Initialize AdMobService
    await AdMobService().initializeAds();
  } catch (e) {
    // MobileAds initialization error
  }

  
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageService()),
        ChangeNotifierProvider(create: (_) => BugIdentificationProvider()),
        ChangeNotifierProvider(create: (_) => AICoachProvider()),

      ],
      child: Consumer<LanguageService>(
        builder: (context, languageService, child) {
          return MaterialApp(
            locale: languageService.currentLocale ?? Locale('en'),
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [
              Locale('en'),
              Locale('es'),
              Locale('hi'),
              Locale('ar'),
              Locale('id'),
              Locale('vi'),
              Locale('ko'),
              Locale('ja'),
              Locale('tr'),
            ],
        title: 'Bug Scanner - AI Insect & Reptile Identification',
        debugShowCheckedModeBanner: false,
        theme: ModernDesignSystem.lightTheme,
        darkTheme: ModernDesignSystem.darkTheme,
        themeMode: ThemeMode.system,
        home: SplashScreen(),
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaleFactor: 1.0,
            ),
            child: child!,
          );
        },
        // Custom page transitions
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/history':
              return PageRouteBuilder(
                settings: settings,
                pageBuilder: (context, animation, secondaryAnimation) {
                  return HistoryScreen();
                },
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  const begin = Offset(1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.easeInOut;
                  var tween = Tween(begin: begin, end: end).chain(
                    CurveTween(curve: curve),
                  );
                  return SlideTransition(
                    position: animation.drive(tween),
                    child: child,
                  );
                },
                transitionDuration: Duration(milliseconds: 300),
              );
            default:
              return PageRouteBuilder(
                settings: settings,
                pageBuilder: (context, animation, secondaryAnimation) {
                  return SplashScreen();
                },
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  const begin = Offset(1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.easeInOut;
                  var tween = Tween(begin: begin, end: end).chain(
                    CurveTween(curve: curve),
                  );
                  return SlideTransition(
                    position: animation.drive(tween),
                    child: child,
                  );
                },
                transitionDuration: Duration(milliseconds: 300),
              );
          }
        },
          );
        },
      ),
    );
  }
}
