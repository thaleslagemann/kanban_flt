import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:kanban_flt/test_page.dart';
import 'package:provider/provider.dart';
import 'package:kanban_flt/config.dart';

Future main() async {
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  sqfliteFfiInit();

  databaseFactory = databaseFactoryFfi;
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  AppState createState() => AppState();
}

class AppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    globalAppTheme.addListener(() {
      print('And the theme changes!');
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ConfigState(),
      child: MaterialApp(
        title: 'Kanban Flutter',
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        themeMode: globalAppTheme.currentTheme(),
        home: TestScreen(),
      ),
    );
  }
}
