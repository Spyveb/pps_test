import 'package:flutter/material.dart';

class FullScreenProgress extends StatelessWidget {
  const FullScreenProgress({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black45,
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
