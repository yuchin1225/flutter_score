import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_score/score.dart';
import 'package:flutter_guest/report.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // 這行很重要
  await getApplicationDocumentsDirectory();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: '問卷調查', initialRoute: "/", routes: {
      // 首頁
      "/": (context) => Score(),
      // 報表
      "/report": (context) => Report()
    });
  }
}
