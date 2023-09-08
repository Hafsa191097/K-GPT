import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kgpt/pre_app.dart';
import 'package:kgpt/providers/chat_provider.dart';
import 'package:kgpt/providers/dark_theme_provider.dart';
import 'package:kgpt/providers/models_provider.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'constants/constants.dart';

Future<void> main() async {
  
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.leanBack,
    overlays: [],
  );
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(const MyApp());
 
  await Future.delayed(const Duration(seconds: 3));
  FlutterNativeSplash.remove();
  
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  DarkThemeProvider themeChangeProvider = new DarkThemeProvider();

  @override
  void initState(){
    super.initState();
    getCurrentAppTheme();
     SystemChrome.setSystemUIChangeCallback(
      (systemOverlaysAreVisisble) async{
        log("Changed: $systemOverlaysAreVisisble" );
      }
    );
  }

  void getCurrentAppTheme() async {
    themeChangeProvider.darkTheme =
        await themeChangeProvider.darkThemePreference.getTheme();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = themeChangeProvider.darkTheme;
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ModelsProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ChatProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) {
            return themeChangeProvider;
          },
        ),
      ],
      child: MaterialApp(
        title: 'Flutter ChatBOT',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor:
              isDark ? scaffoldBackgroundColorDark : scaffoldBackgroundColor,
          appBarTheme: AppBarTheme(
            color: isDark ? cardColorDark : cardColor,
          ),
        ),
        home: const PreApp(),
      ),
    );
  }
}
