import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo/Providers/theme_changer_provider.dart';
import 'package:todo/constants/colors.dart';
import 'package:todo/screens/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ThemeChangerProvider>(
      create: (_) => ThemeChangerProvider(),
      child: Builder(builder: (context) {
        return MaterialApp(
          title: 'Task App',
          themeMode: Provider.of<ThemeChangerProvider>(context).getTheme()
              ? ThemeMode.dark
              : ThemeMode.light,
          theme: ThemeData(
            brightness: Brightness.light,
            appBarTheme: const AppBarTheme(
              backgroundColor: tBGColor,
            ),
            scaffoldBackgroundColor: tBGColor,
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            useMaterial3: true,
          ),
          home: const HomePage(),
        );
      }),
    );
  }
}
