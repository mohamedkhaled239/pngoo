import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:video_downloud_app/l10n/app_localizations.dart';
import 'package:video_downloud_app/providers/video_editor_provider.dart';
import 'package:video_downloud_app/providers/app_config_provider.dart';
import 'package:video_downloud_app/providers/video_download_provider.dart';
import 'package:video_downloud_app/providers/locale_provider.dart';
import 'package:video_downloud_app/screens/main_screen.dart';
import 'package:video_downloud_app/services/ad_service.dart';
import 'package:video_downloud_app/utils/app_colors.dart';

import 'firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint("--- إشعار جديد في الخلفية ---");
  debugPrint("ID: ${message.messageId}");
  debugPrint("Title: ${message.notification?.title}");
  debugPrint("Body: ${message.notification?.body}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  } catch (error, stackTrace) {
    debugPrint('Firebase startup failed: $error');
    debugPrintStack(stackTrace: stackTrace);
  }

  runApp(const MyApp());

  // Optional services must never prevent the first Flutter frame from loading.
  unawaited(_initializeOptionalServices());
}

Future<void> _initializeOptionalServices() async {
  try {
    await AdService.initialize();
  } catch (error, stackTrace) {
    debugPrint('AdMob startup failed: $error');
    debugPrintStack(stackTrace: stackTrace);
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AppLifecycleListener _listener;

  @override
  void initState() {
    super.initState();
    _listener = AppLifecycleListener(
      onStateChange: (state) {
        if (state == AppLifecycleState.resumed) {
          AdService.showAppOpenAdIfAvailable();
        }
      },
    );
  }

  @override
  void dispose() {
    _listener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => AppConfigProvider()),
        ChangeNotifierProvider(create: (_) => VideoEditorProvider()),
        ChangeNotifierProvider(create: (_) => VideoDownloadProvider()),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, child) {
          return MaterialApp(
            title: 'الذئب',
            debugShowCheckedModeBanner: false,
            builder: (context, child) {
              final mediaQuery = MediaQuery.of(context);
              return MediaQuery(
                data: mediaQuery.copyWith(
                  textScaler: const TextScaler.linear(1),
                ),
                child: child ?? const SizedBox.shrink(),
              );
            },

            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en'), Locale('ar')],
            locale: localeProvider.locale,
            theme: ThemeData(
              brightness: Brightness.dark,
              scaffoldBackgroundColor: AppColors.background,
              colorScheme: const ColorScheme.dark(
                primary: AppColors.primary,
                secondary: AppColors.secondary,
                surface: AppColors.surface,
                error: Color(0xFFFF7168),
              ),
              useMaterial3: true,
              fontFamily: 'Cairo',
              splashColor: AppColors.primary.withValues(alpha: .10),
              highlightColor: AppColors.primary.withValues(alpha: .05),
            ),
            home: const MainScreen(),
          );
        },
      ),
    );
  }
}
