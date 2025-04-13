import 'package:flutter/material.dart';
import 'file_explorer/screens/file_explorer_screen.dart';
import 'util.dart';
import 'theme.dart';



void main() {
  runApp(const MyApp());

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final brightness = View.of(context).platformDispatcher.platformBrightness;

    TextTheme textTheme = createTextTheme(context, "Ubuntu", "Ubuntu");

    MaterialTheme theme = MaterialTheme(textTheme);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: theme.light(),
      home: FileExplorerScreen(),
    );
  }
}
