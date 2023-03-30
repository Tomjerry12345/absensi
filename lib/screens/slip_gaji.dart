// ignore_for_file: unused_element, prefer_typing_uninitialized_variables
import 'dart:async';
import 'dart:developer';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

// import 'package:fluttertoast/fluttertoast.dart';
import 'package:web_dashboard_app_tut/resources/warna.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
// ignore: depend_on_referenced_packages
import 'package:pdf/pdf.dart';
// ignore: depend_on_referenced_packages
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:web_dashboard_app_tut/utils/Utilitas.dart';
import '../models/present.dart';
import 'package:flutter/foundation.dart';
// import 'package:syncfusion_flutter_xlsio/xlsio.dart';

class Gaji extends StatefulWidget {
  const Gaji({Key? key}) : super(key: key);

  @override
  State<Gaji> createState() => _GajiState();
}

class _GajiState extends State<Gaji> {
  DateTime selectedPeriod = DateTime.now();
  bool show = false;

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  String search = "";
  late TextEditingController searchController =
      TextEditingController(text: search);

  List<Map<String, dynamic>> data = [];
  int index = 0;

  @override
  void initState() {
    super.initState();
    getUsers();
  }

  Future<DateTime> _selectPeriod(BuildContext context) async {
    final selected = await showDatePicker(
        context: context,
        initialDate: selectedPeriod,
        firstDate: DateTime(2000),
        lastDate: DateTime(2025));
    if (selected != null && selected != selectedPeriod) {
      setState(() {
        selectedPeriod = selected;
      });
    }
    return selectedPeriod;
  }

  void _exportToExcel() {
    final excel = Excel.createExcel();
    final sheet = excel.sheets[excel.getDefaultSheet() as String];
    sheet!.setColWidth(2, 50);
    sheet.setColAutoFit(0);

    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).value =
        'No';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0)).value =
        'Nama';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0)).value =
        'Tanggal Pengajuan';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0)).value =
        'Jenis';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 0)).value =
        'Keterangan';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: 0)).value =
        'Biaya';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: 0)).value =
        'Tanggal Mulai';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: 0)).value =
        'Tanggal Selesai';

    excel.save();
  }

  // // ignore: non_constant_identifier_names
  // void getData() async {
  //   FirebaseFirestore firestore = FirebaseFirestore.instance;
  //   QuerySnapshot<Map<String, dynamic>> users =
  //       await firestore.collection("users").get();

  //   for (var user in users.docs) {
  //     absen.add({
  //       "id": user.id,
  //       "nama": user['nama'],
  //       "bulan": null,
  //       "gajiPokok": 0,
  //       "totalLembur": 0,
  //       "totalP": 0,
  //       "totalKeterlabatan": 0,
  //       "totalKeseluruhan": 0,
  //     });
  //   }

  //   QuerySnapshot<Map<String, dynamic>> present =
  //       await firestore.collectionGroup('present').get();
  //   int index = 0;
  //   // Memperbarui nilai gajiPokok dan totalLembur untuk setiap pengguna berdasarkan bulan
  //   absen.forEach((user) {
  //     for (var doc in present.docs) {
  //       if (doc.reference.parent.parent!.id == user['id']) {
  //         absen[index]['gajiPokok'] =
  //             absen[index]['gajiPokok'] + doc['gajiDay'];
  //         // absen[index]['totalP'] = absen[index]['totalP'] + doc['biaya'];

  //         // absen[index]['totalPinjaman'] =
  //         //     absen[index]['totalPinjaman'] + doc['biaya'];
  //         // absen[index]['totalLembur'] =
  //         //     absen[index]['totalLembur'] + doc['waktuLembur'];
  //       }
  //     }
  //     index++;
  //   });

  //   setState(() {
  //     data = absen;
  //   });
  // }

  void getUsers() async {
    List<Map<String, dynamic>> l = [];
    String todayDocID =
        DateFormat().add_yMd().format(selectedPeriod).replaceAll("/", "-");
    var date = todayDocID.split("-");

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot<Map<String, dynamic>> users =
        await firestore.collection("users").get();
    QuerySnapshot<Map<String, dynamic>> present = await firestore
        .collection("present")
        .where("tanggal.bulan", isEqualTo: date[0])
        .get();
    QuerySnapshot<Map<String, dynamic>> pengajuan = await firestore
        .collection("pengajuan")
        .where("tanggal_mulai", isEqualTo: monthName(int.parse(date[0])))
        .where("tipe_pengajuan", isEqualTo: "Kasbon")
        .get();

    logO("pengajuan", pengajuan.size);

    users.docs.forEach((u) {
      final uData = u.data();
      String uNama = uData["nama"];
      int tGajiPokok = 0;
      int tPinjaman = 0;
      int tGajiLembur = 0;
      int tGajiTerlambat = 0;
      int tGaji = 0;

      present.docs.forEach((p) {
        Map<String, dynamic> pData = p.data();
        String pNama = pData["nama"];

        if (uNama == pNama) {
          int gp = pData["gaji_pokok"];
          int gl = pData["gaji_lembur"];
          int gt = pData["gaji_terlambat"];
          tGajiPokok += gp;
          tGajiLembur += gl;
          tGajiTerlambat += gt;
        }
      });

      pengajuan.docs.forEach((pa) {
        Map<String, dynamic> paData = pa.data();
        String paNama = paData["nama"];
        String paStatus = paData["status"];

        if (uNama == paNama && paStatus == "1") {
          int biaya = int.parse(paData["biaya"]);
          tPinjaman += biaya;
        }
      });

      tGaji = (tGajiPokok + tGajiLembur) - tGajiTerlambat - tPinjaman;

      l.add({
        "nama": uNama,
        "total_gaji_pokok": tGajiPokok,
        "total_gaji_lembur": tGajiLembur,
        "total_pinjaman": tPinjaman,
        "total_gaji_keterlambatan": tGajiTerlambat,
        "total_gaji_keseluruhan": tGaji
      });
    });

    setState(() {
      data = l;
    });
  }

  // Stream<QuerySnapshot<Map<String, dynamic>>> getData() async* {
  //   FirebaseFirestore firestore = FirebaseFirestore.instance;
  //   yield* firestore.collection("present").snapshots();
  // }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 40),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: const [
                Text(
                  "Slip Gaji",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 10, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  DateFormat('MMMM yyyy').format(selectedPeriod),
                  style: TextStyle(
                      color: Warna.hijau2,
                      fontSize: 17,
                      fontWeight: FontWeight.bold),
                ),
                IconButton(
                    icon: const Icon(Icons.keyboard_arrow_down),
                    color: Warna.hijau2,
                    onPressed: () {}),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(
                bottom: 10, right: 14, left: 1100, top: 10),
            child: Row(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Warna.hijauht,
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                  ),
                  onPressed: () {
                    print(data.toString());
                  },
                  child: const Text("Cetak"),
                ),
                const SizedBox(
                  width: 5,
                ),
                Row(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 88, 104, 103),
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                      ),
                      onPressed: () {},
                      child: const Text("Download"),
                    )
                  ],
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 900, right: 20),
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
                color: Warna.putih, borderRadius: BorderRadius.circular(5)),
            child: Center(
                child: TextField(
              controller: searchController,
              onChanged: (value) {
                setState(() {
                  setState(() {});
                });
              },
              decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Warna.hijau2,
                      width: 1.0,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Warna.hijau2,
                      width: 1.0,
                    ),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {},
                  )),
            )),
          ),
          const SizedBox(
            height: 20,
          ),
          SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 70,
                horizontalMargin: 70,
                showCheckboxColumn: false,
                dataRowHeight: 48,
                headingRowColor:
                    MaterialStateProperty.all(Colors.grey.shade200),
                columns: const [
                  DataColumn(label: Text('No')),
                  DataColumn(label: Text('Nama')),
                  DataColumn(label: Text('Gaji Pokok')),
                  DataColumn(label: Text('Total Gaji Lembur')),
                  DataColumn(label: Text('Total Pinjaman(-)')),
                  DataColumn(label: Text('Total Keterlambatan(-)')),
                  DataColumn(label: Text('Total Keseluruhan')),
                ],
                rows: data.map((e) {
                  index++;
                  return DataRow(cells: [
                    DataCell(Text(index.toString())),
                    DataCell(Text(e['nama']?.toString() ?? '')),
                    DataCell(Text(e['total_gaji_pokok']?.toString() ?? " ")),
                    DataCell(Text(e['total_gaji_lembur']?.toString() ?? " ")),
                    DataCell(Text(e['total_pinjaman']?.toString() ?? " ")),
                    DataCell(
                        Text(e['total_gaji_keterlambatan']?.toString() ?? " ")),
                    DataCell(
                        Text(e['total_gaji_keseluruhan']?.toString() ?? " ")),
                  ]);
                }).toList(),
              ))
        ],
      ),
    );
  }
}
