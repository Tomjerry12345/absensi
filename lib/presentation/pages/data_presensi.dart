import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/Utils/Utilitas.dart';
import 'package:flutter_application_1/presentation/pages/profil.dart';
import 'package:flutter_application_1/presentation/resources/warna.dart';
import 'package:intl/intl.dart';
import '../widgets/ItemPresensi.dart';

class DataPresensi extends StatefulWidget {
  DataPresensi({Key? key}) : super(key: key);

  @override
  State<DataPresensi> createState() => _DataPresensiState();
}

class _DataPresensiState extends State<DataPresensi> {
  DateTime selectedPeriod = DateTime.now();
  bool show = false;

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

  Stream<QuerySnapshot<Map<String, dynamic>>> streamSpecifictPresent(
      DateTime d) async* {
    FirebaseAuth auth = FirebaseAuth.instance;
    String uid = auth.currentUser!.uid;
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    final collectionReference = FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("present");

    // DateTime now = DateTime.now();
    String todayDocID = DateFormat().add_yMd().format(d).replaceAll("/", "-");

    var date = todayDocID.split("-");

    yield* firestore
        .collection("present")
        .where("idUser", isEqualTo: uid)
        .where("tanggal.bulan", isEqualTo: date[0])
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Warna.hijau2,
        title: Text("Data"),
      ),
      body: ListView(
        children: [
          Container(
              width: double.infinity,
              child: StreamBuilder<QuerySnapshot>(
                  stream: streamSpecifictPresent(selectedPeriod),
                  builder: (context, snap) {
                    var data = snap.data?.docs;
                    int tGajiPokok = 0;
                    int tGajiLembur = 0;
                    int tGajiTerlambat = 0;
                    int tGaji = 0;

                    data?.forEach(
                      (e) {
                        int gp = e["gaji_pokok"];
                        int gl = e["gaji_lembur"];
                        int gt = e["gaji_terlambat"];
                        tGajiPokok += gp;
                        tGajiLembur += gl;
                        tGajiTerlambat += gt;
                      },
                    );

                    tGaji = (tGajiPokok + tGajiLembur) - tGajiTerlambat;

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Container(
                        //   height: 250,
                        //   child: home(),
                        // ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  DateFormat("yMMMM").format(selectedPeriod),
                                  style: TextStyle(
                                      color: Warna.hijau2,
                                      fontWeight: FontWeight.bold),
                                ),
                                IconButton(
                                    icon: const Icon(Icons.keyboard_arrow_down),
                                    color: Warna.hijau2,
                                    onPressed: () {
                                      _selectPeriod(context);
                                      show = true;
                                    }),
                              ],
                            ),
                          ),
                        ),

                        ItemPresensi(
                            text1: 'Gaji Pokok', text2: 'Rp. ${tGajiPokok}'),
                        ItemPresensi(
                          text1: 'Lembur',
                          text2: 'Rp. ${tGajiLembur}',
                        ),
                        ItemPresensi(
                            text1: 'Keterlambatan',
                            text2: "Rp. ${tGajiTerlambat}"),
                        ItemPresensi(
                            text1: 'Gaji Bulan ini', text2: 'Rp. ${tGaji}'),
                      ],
                    );
                  }))
        ],
      ),
    );
  }
}
