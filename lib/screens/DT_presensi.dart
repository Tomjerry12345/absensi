import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:web_dashboard_app_tut/resources/warna.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
// ignore: depend_on_referenced_packages

// ignore: depend_on_referenced_packages
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:web_dashboard_app_tut/utils/Utilitas.dart';
import '../models/present.dart';

// import 'package:syncfusion_flutter_xlsio/xlsio.dart';
class Presensi extends StatefulWidget {
  const Presensi({Key? key}) : super(key: key);
  @override
  State<Presensi> createState() => _PresensiState();
}

class _PresensiState extends State<Presensi> {
  List<Object> _historyList = [];
  List<String> gajiDayList = [];
  String? _selectedUserId;
  String? dropDownValue = "Izin";
  List<String> citylist = [
    'Izin',
    'Kasbon',
  ];
  void didChangeDependencies() {
    super.didChangeDependencies();
    retrieveSubcol();
  }

  _exportToExcel() {
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

  DateTime selectedPeriod = DateTime.now();
  bool show = false;

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  String search = "";
  late TextEditingController searchController =
      TextEditingController(text: search);

  String nama = "";
  String email = "";
  String jenis = "";
  String createdat = "";
  // ignore: non_constant_identifier_names
  String tanggal_mulai = "";
  // ignore: non_constant_identifier_names
  String tanggal_selesai = "";
  String keterangan = "";
  String jumlah = "";
  bool loading = false;

  int rowNumber = 0;

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

  Future submit(String? status, String? id, BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    try {
      final doc = FirebaseFirestore.instance.collection("pengajuan").doc(id);
      final json = {
        "status": status,
      };
      await doc.update(json);
      Navigator.of(this.context).pop('dialog');
    } on FirebaseException {
      Navigator.of(this.context).pop('dialog');
    }
  }

  void retrieveSubcol() async {
    // var data = await FirebaseFirestore.instance
    //     .collection("users")
    //     .get()
    //     .then((value) => {
    //           value.docs.forEach((result) {
    //             FirebaseFirestore.instance
    //                 .collection("users")
    //                 .doc(result.id)
    //                 .collection("present")
    //                 .get()
    //                 .then((subCol) => {
    //                       subCol.docs.forEach((element) {
    //                         setState(() {
    //                           myList.add(element.data());
    //                         });
    //                       })
    //                     });
    //           })
    //         });
  }

  List<Map<String, dynamic>> myList = [];

  List<Map<String, dynamic>> searchResultList = [];

  Stream<QuerySnapshot<Map<String, dynamic>>> streamAllPresent() async* {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    yield* firestore.collection("present").snapshots();
  }

  @override
  Widget build(BuildContext context) {
    DateTime waktuHarusDatang = DateTime.parse('2022-03-03 08:00:00');
    DateTime waktuHarusPulang = DateTime.parse('2022-03-03 17:00:00');
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
                  "Data Presensi",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Container(
            margin:
                const EdgeInsets.only(bottom: 10, top: 10, right: 20, left: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Warna.hijauht,
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                  ),
                  onPressed: () {
                    print(myList.toString());
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
                        backgroundColor: Color.fromARGB(255, 88, 104, 103),
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                      ),
                      child: const Text("Download"),
                      // onPressed: _createPDF,
                      onPressed: () {},
                    )
                  ],
                ),
              ],
            ),
          ),
          Container(
            // margin: EdgeInsets.only(top: 10),
            // margin: EdgeInsets.symmetric(horizontal: 30),
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  DateFormat('yMMMM').format(selectedPeriod),
                  style: TextStyle(
                      color: Warna.hijau2, fontWeight: FontWeight.bold),
                ),
                IconButton(
                    icon: Icon(Icons.keyboard_arrow_down),
                    color: Warna.hijau2,
                    onPressed: () {
                      _selectPeriod(context);
                      show = true;
                    }),
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
                  setState(() {
                    search = value.toLowerCase();
                  });
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
          SizedBox(
            height: 30,
          ),
          StreamBuilder<QuerySnapshot>(
              stream: streamAllPresent(),
              builder: (context, snap) {
                logO("snap.data?.docs", snap.data?.size);
                if (snap.hasData) {
                  var l = snap.data?.docs;
                  return SingleChildScrollView(
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
                          DataColumn(label: Text('Tanggal')),
                          DataColumn(label: Text('Waktu Datang')),
                          DataColumn(label: Text('Waktu Pulang')),
                          DataColumn(
                              label: Text('Keterangan')), //Normal datang cepat
                          DataColumn(label: Text('Durasi')),
                          DataColumn(label: Text('Lembur')),
                          // DataColumn(label: Text('Keterlambatan')),
                        ],
                        rows: l!.map((e) {
                          var t = e["tanggal"];
                          var wd = e["waktu_datang"];
                          var wp = e["waktu_pulang"];
                          var date = "${t["hari"]}/${t["bulan"]}/${t["tahun"]}";
                          rowNumber++;
                          return DataRow(cells: [
                            DataCell(Text(rowNumber.toString())),
                            DataCell(Text(e["nama"])),
                            DataCell(Text(date)),
                            DataCell(Text(wd.toString() == "{}"
                                ? "-"
                                : "${wd["jam"]}:${wd["menit"]}")),
                            DataCell(Text(wp.toString() == "{}"
                                ? "-"
                                : "${wp["jam"]}:${wp["menit"]}")),
                            DataCell(Text(e["keterangan_waktu_pulang"])),
                            DataCell(Text(e["durasi"].toString())),
                            DataCell(Text(e["lembur"].toString())),
                          ]);
                        }).toList(),
                      ));
                }

                return Text("No Data");
              }),
        ],
      ),
    );
  }
}
