import 'package:flutter/material.dart';

class MenuPage extends StatelessWidget {
  final String branchId;
  const MenuPage({required this.branchId, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Menu for $branchId')),
      body: Center(
        child: Text(
          'Menu page for branch: $branchId',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
