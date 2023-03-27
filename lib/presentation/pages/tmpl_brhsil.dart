// ignore_for_file: avoid_unnecessary_containers

import 'package:flutter/material.dart';
import '../resources/warna.dart';

class Berhasil extends StatefulWidget {
  const Berhasil({Key? key}) : super(key: key);

  @override
  State<Berhasil> createState() => _BerhasilState();
}

class _BerhasilState extends State<Berhasil> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(
              Icons.done,
              color: Warna.hijau2,
              size: 50.0,
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              "Presensi Berhasil",
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 24,
                color: Warna.htam,
              ),
            ),
            const SizedBox(
              height: 300,
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Warna.daftar,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                ),
                child: const Text("Masuk"),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
