// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_application_1/presentation/pages/Check.dart';

import '../resources/warna.dart';

class Csan extends StatefulWidget {
  const Csan({Key? key}) : super(key: key);

  @override
  State<Csan> createState() => _CsanState();
}

class _CsanState extends State<Csan> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Text('Scan')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Scan",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              color: Warna.hijau2,
            ),
          ),
          Icon(
            Icons.fullscreen,
            color: Warna.hijau2,
            size: 500.0,
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CheckPage()),
              );
            },
            child: Text(
              "Back",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Warna.hijau2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
