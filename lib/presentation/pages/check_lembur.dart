// ignore_for_file: camel_case_types, unused_local_variable, prefer_is_empty, no_leading_underscores_for_local_identifiers
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/Utils/Utils.dart';
import 'package:flutter_application_1/presentation/pages/my_page.dart';
import 'package:flutter_application_1/presentation/resources/warna.dart';
import '../resources/gambar.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:intl/intl.dart';

class check_lemburPage extends StatefulWidget {
  const check_lemburPage({Key? key}) : super(key: key);

  @override
  State<check_lemburPage> createState() => _check_lemburPageState();
}

class _check_lemburPageState extends State<check_lemburPage> {
  String _scanResult = "true";
  Future<void> scanQR() async {
    int lembur = 0;

    FirebaseAuth auth = FirebaseAuth.instance;
    String uid = auth.currentUser!.uid;

    FirebaseFirestore firestore = FirebaseFirestore.instance;

    CollectionReference<Map<String, dynamic>> cPresent =
        firestore.collection("users").doc(uid).collection("present");

    QuerySnapshot<Map<String, dynamic>> snapPrensent = await cPresent.get();

    DateTime now = DateTime.now();
    String todayDocID = DateFormat().add_yMd().format(now).replaceAll("/", "-");

    DateTime jamm = DateTime.now();

    String jam = DateFormat().add_yMd().format(jamm).replaceAll("/", "-");

    DocumentSnapshot<Map<String, dynamic>> absenn =
        await cPresent.doc(todayDocID).get();
    Map<String, dynamic>? dataPresentTod = absenn.data();

    Future<void> _scanQRU() async {
      String? result = await scanner.scan();

      if (result != null) {
        setState(() {
          _scanResult = result;
        });
      } else {
        // Jika result bernilai null, Anda bisa menampilkan pesan kesalahan atau melakukan tindakan lain
        print('Tidak berhasil membaca QR code');
      }
    }

    // if (jamm.hour >= 19 && jamm.hour <= 00) {
    if (dataPresentTod?["OutLembur"] != null &&
        dataPresentTod?["starLembur"] != null) {
      Utils.showSnackBar("Sukses Sudah Absen Masuk && Keluar.", Colors.green);
    } else if (dataPresentTod?["starLembur"] == null) {
      _scanQRU();
      if (_scanResult.toString() == "https://me-qr.com/ZGQ3b5Re") {
        await cPresent.doc(todayDocID).set({
          "date": now.toIso8601String(),
          "starLembur": {
            "jamSLembur": jamm.toIso8601String(),
          }
        });
      }
    } else {
      _scanQRU();
      if (_scanResult.toString() == "https://me-qr.com/ZGQ3b5Re") {
        await cPresent.doc(todayDocID).update({
          "OutLembur": {
            "JamOLembur": jamm.toIso8601String(),
          }
        });
      }
    }
    // } else {
    //   Utils.showSnackBar("Maaf Anda Belum Bisa Absen Lembur.", Colors.green);
    // }//ppp

    if (dataPresentTod?["OutLembur"] != null &&
        dataPresentTod?["starLembur"] != null) {
      DateTime jamMulai =
          DateTime.parse(dataPresentTod!["starLembur"]["jamSLembur"]);

      DateTime jamAkhir =
          DateTime.parse(dataPresentTod["OutLembur"]["JamOLembur"]);

      var jamLembur = jamAkhir.difference(jamMulai).inHours.round();

      lembur = jamLembur;

      await cPresent.doc(todayDocID).update({
        "waktuLembur": lembur,
      });
      // }
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamUser() async* {
    FirebaseAuth auth = FirebaseAuth.instance;
    String uid = auth.currentUser!.uid;
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    yield* firestore
        .collection("users")
        .doc(uid)
        .collection("present")
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    final user = FirebaseAuth.instance.currentUser;
    FirebaseAuth auth = FirebaseAuth.instance;
    String uid = auth.currentUser!.uid;
    bool isCheckIn = false;

    print("test");

    return Scaffold(
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: streamUser(),
          builder: (context, snapPresence) {
            return SingleChildScrollView(
              // scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  StreamBuilder(
                      stream: streamUser(),
                      builder: (context, snap) {
                        return Stack(
                          children: [
                            Image.asset(
                              Gambar.lmbur,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: MediaQuery.of(context).size.height * 0.4,
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.4,
                              child: Container(),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 20),
                              width: double.infinity,
                              padding: const EdgeInsets.only(),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  const SizedBox(
                                    height: 23,
                                  ),
                                  const Center(
                                    child: Text(
                                      "Lembur",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Title(
                                    color: Warna.putih,
                                    child: Text(
                                      (DateFormat('KK:mm')
                                          .format(DateTime.now())),
                                      style: TextStyle(
                                        color: Warna.putih,
                                        fontSize: 32,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Title(
                                    color: Warna.hijau2,
                                    child: Text(
                                      (DateFormat('dd MMMM yyyy')
                                          .format(DateTime.now())),
                                      style: TextStyle(
                                        color: Warna.putih,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 2,
                            ),
                            Container(
                                margin:
                                    const EdgeInsets.only(top: 180, bottom: 10),
                                width: double.infinity,
                                padding: const EdgeInsets.all(25),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        isCheckIn ? Warna.hijau2 : Warna.kuning,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 20),
                                  ),
                                  child: Text(
                                      isCheckIn ? "Check In" : "Check Out"),
                                  onPressed: () async {
                                    await scanQR();
                                    setState(() {
                                      isCheckIn = !isCheckIn;
                                    });
                                  },
                                ))
                          ],
                        );
                      }
                      // batass
                      ),
                  const SizedBox(
                    height: 10,
                  ),

                  StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: streamUser(),
                    builder: ((context, snapPresent) {
                      if (snapPresence.data?.docs.length == 0 ||
                          snapPresence.data == null) {
                        return const SizedBox(
                          height: 400,
                          child: Center(
                            child:
                                Text("Maaf, History absen anda belum ada!!!"),
                          ),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: snapPresence.data!.docs.length,
                        itemBuilder: (context, index) {
                          Map<String, dynamic> data =
                              snapPresence.data!.docs[index].data();

                          return Container(
                            alignment: Alignment.centerLeft,
                            margin: const EdgeInsets.all(20),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            height: 150,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(
                                  25), //border corner radius
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey
                                      .withOpacity(0.5), //color of shadow
                                  spreadRadius: 1, //spread radius
                                  blurRadius: 7, // blur radius
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.date_range,
                                      color: Warna.htam,
                                      size: 20.0,
                                    ),
                                    Text(
                                      data['date'] != null
                                          ? DateFormat.yMMMEd().format(
                                              DateTime.parse(
                                                  data['date'].toString()))
                                          : '',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Warna.abuabu,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Row(children: [
                                  Text(
                                    "Check In",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Warna.htam,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 38,
                                  ),
                                  Text(
                                    data['starLembur']?['jamSLembur'] == null
                                        ? "-"
                                        : DateFormat.jms().format(
                                            DateTime.parse(data['starLembur']
                                                    ['jamSLembur']
                                                .toString())),
                                    // data["check_out"] != ""
                                    //     ? DateFormat("HH mm")
                                    //         .format(data["date"].toDate())
                                    //     : "-",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Warna.abuabu,
                                    ),
                                  ),
                                ]),
                                const SizedBox(
                                  height: 7,
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "Check out",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Warna.htam,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 30,
                                    ),
                                    Text(
                                      data['OutLembur']?['JamOLembur'] == null
                                          ? "-"
                                          : DateFormat.jms().format(
                                              DateTime.parse(data['OutLembur']
                                                      ['JamOLembur']
                                                  .toString())),
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Warna.abuabu,
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          );
                          //btasss
                        },
                      );
                    }),
                  )

                  // batsss ko
                ],
              ),
            );

            //Builderrr
          }),
    );
  }

  //dd
}
