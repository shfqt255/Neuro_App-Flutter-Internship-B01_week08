import 'package:flutter/material.dart';

class DetailScreen extends StatelessWidget {
  final String info;

  const DetailScreen({super.key, required this.info});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Screen'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(padding: const EdgeInsets.all(8.0), child: Text(info)),
      ),
    );
  }
}
