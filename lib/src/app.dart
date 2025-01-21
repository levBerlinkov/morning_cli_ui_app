import 'package:flutter/material.dart';
import 'package:morning_cli_ui_app/src/split_view_page/split_view_page.dart';

import 'home_page/home_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'morning-cli app',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ).copyWith(
        scrollbarTheme: const ScrollbarThemeData().copyWith(
          thumbColor: MaterialStateProperty.all(Colors.cyanAccent),
        ),
      ),
      home: const MyHomePage(),
    );
  }
}