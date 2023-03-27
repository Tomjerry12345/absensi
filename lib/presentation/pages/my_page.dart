import 'package:flutter/material.dart';
import 'package:flutter_application_1/presentation/pages/Check.dart';
import 'package:flutter_application_1/presentation/pages/Izin.dart';

import 'package:flutter_application_1/presentation/pages/check_lembur.dart';
import 'package:flutter_application_1/presentation/pages/kasbon.dart';

import 'data_presensi.dart';

import '../resources/warna.dart';

class MyPages extends StatefulWidget {
  const MyPages({Key? key}) : super(key: key);

  @override
  MyPagesState createState() => MyPagesState();
}

class MyPagesState extends State<MyPages> {
  int _selectedIndex = 0;
  final List<Widget> _widgetOptions = <Widget>[
    DataPresensi(),
    const check_lemburPage(),
    const Kasbon(),
    const Izin()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CheckPage()),
          );
        },
        backgroundColor: Warna.hijau2,
        child: const Icon(Icons.qr_code_scanner),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Warna.hijau2,
        selectedIconTheme: IconThemeData(color: Warna.kuning),
        unselectedIconTheme: IconThemeData(
          color: Warna.putih,
          size: 24,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.wysiwyg,
            ),
            label: 'Data',
            //backgroundColor: Colors.red,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timer),
            label: 'Lembur',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.monetization_on),
            label: 'Kasbon',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_add),
            label: 'Izin',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Warna.kuning,
        unselectedItemColor: Warna.putih,
        onTap: _onItemTapped,
      ),
    );
  }
}
