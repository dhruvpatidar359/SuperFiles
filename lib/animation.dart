import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class FileLoadingAnimation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Loading Files"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Lottie animation for file loading
            Lottie.asset(
              'assets/animation.json', // Path to the Lottie animation file
              // width: 200,
              // height: 200,
              // fit: BoxFit.fill,
            ),
            SizedBox(height: 20),
            Text(
              "Loading Files...",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: FileLoadingAnimation(),
  ));
}
