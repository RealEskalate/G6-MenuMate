import 'package:flutter/material.dart';

class Item extends StatelessWidget {
  const Item({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadiusGeometry.circular(10),
        child: Image.network('src'),
      ),
      title: const Text('Item Name'),
      subtitle: const Text('description'),
      trailing: const Text('Price'),
    );
  }
}
