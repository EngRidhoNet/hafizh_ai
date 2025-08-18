import 'package:flutter/material.dart';
import 'features/recorder/recorder_page.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hafizh AI',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.green),
      home: const RecorderPage(),
    );
  }
}
