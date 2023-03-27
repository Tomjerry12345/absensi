// ignore_for_file: file_names

import 'package:flutter/material.dart';

class ItemPresensi extends StatelessWidget {
  final String text1;
  final String text2;
  const ItemPresensi({
    required this.text1,
    required this.text2,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
      decoration: const BoxDecoration(
          border: Border(
              top: BorderSide(
                  width: 2, color: Color.fromARGB(255, 129, 129, 129)))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(text1),
          Text(text2),
        ],
      ),
    );
  }
}
