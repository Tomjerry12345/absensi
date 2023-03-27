import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/Utils/Utilitas.dart';
import 'package:flutter_application_1/Utils/Utils.dart';
import 'package:flutter_application_1/presentation/pages/my_page.dart';
import 'package:flutter_application_1/presentation/resources/warna.dart';
import 'package:get/get.dart';

import '../resources/gambar.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:intl/intl.dart';

import '../widgets/attendance_card.dart';

class CheckPage extends StatefulWidget {
  const CheckPage({Key? key}) : super(key: key);

  @override
  State<CheckPage> createState() => _CheckPageState();
}

class _CheckPageState extends State<CheckPage> {
  Future<void> scanQR() async {
    String? result = await scanner.scan();
    if (result != null) {
      FirebaseAuth auth = FirebaseAuth.instance;
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      String uid = auth.currentUser!.uid;
      DateTime now = DateTime.now();
      String todayDocID =
          DateFormat().add_yMd().format(now).replaceAll("/", "-");

      var date = todayDocID.split("-");

      DocumentSnapshot<Map<String, dynamic>> getUser =
          await firestore.collection("users").doc(uid).get();
      CollectionReference cPresent = firestore.collection("present");
      QuerySnapshot<Object?> getPresent = await cPresent
          .where("idUser", isEqualTo: uid)
          .where("tanggal.hari", isEqualTo: date[1])
          .get();

      var time = now.hour * 60 + now.minute;
      var tambahData = false;

      if (getPresent.size == 0) {
        var user = getUser.data();
        var keterangan = "";

        if (time >= 450 && time <= 500) {
          keterangan = "Tepat Waktu";
          tambahData = true;
        } else if (time > 500 && time <= 550) {
          keterangan = "Terlambat";
          tambahData = true;
        }

        if (tambahData) {
          cPresent.add({
            "idUser": uid,
            "nama": user!["nama"],
            "tanggal": {"hari": date[1], "bulan": date[0], "tahun": date[2]},
            "waktu_datang": {"jam": now.hour, "menit": now.minute},
            "keterangan_waktu_datang": keterangan,
            "waktu_pulang": {},
            "keterangan_waktu_pulang": "-",
            "durasi": 0,
            "lembur": 0,
            "gaji_pokok": 0,
            "gaji_terlambat": 0,
            "gaji_lembur": 0
          });
          Utils.showSnackBar("Berhasil mengabsen", Colors.green);
        } else {
          Utils.showSnackBar("Anda tidak bisa mengisi absen", Colors.red);
        }
      } else {
        var keterangan = "";
        var gajiLembur = 0;
        var lembur = 0;
        var dataP = getPresent.docs.first;

        // if (dataP["waktu_pulang"]["jam"] == null) {
        if (time >= 960 && time <= 990) {
          keterangan = "Pulang Cepat";
          tambahData = true;
        } else if (time >= 1000 && time <= 1020) {
          keterangan = "Pulang tepat waktu";
          tambahData = true;
        } else if (time >= 1140 && time <= 1380) {
          var wLembur = (now.hour - 19) + 1;
          keterangan = "Lembur";
          tambahData = true;
          lembur = wLembur;
          gajiLembur = 25000 * lembur;
        }
        // }

        if (tambahData) {
          var doc = getPresent.docs.first.id;
          var waktuDatang = dataP.get("waktu_datang");
          var durasi = now.hour - waktuDatang["jam"];
          var ketWaktuDatang = dataP.get("keterangan_waktu_datang");
          var gajiTerlambat = 0;

          if (ketWaktuDatang == "Terlambat") {
            var waktuTerlambat =
                (waktuDatang["jam"] * 60) + waktuDatang["menit"];

            var min = 550 - waktuTerlambat;
            var s = min.toString().split("");

            if (int.parse(s[1]) > 5) {
              s[0] = (int.parse(s[0]) + 1).toString();
            }

            int cS = int.parse(s[0]);

            gajiTerlambat = cS * 5000;
          }

          cPresent.doc(doc).update({
            "waktu_pulang": {"jam": now.hour, "menit": now.minute},
            "keterangan_waktu_pulang": keterangan,
            "durasi": durasi,
            "lembur": lembur,
            "gaji_pokok": 100000,
            "gaji_terlambat": gajiTerlambat,
            "gaji_lembur": gajiLembur
          });

          Utils.showSnackBar("Berhasil mengabsen", Colors.green);
        } else {
          Utils.showSnackBar("Anda tidak bisa mengisi absen", Colors.red);
        }
      }
    } else {
      // Jika result bernilai null, Anda bisa menampilkan pesan kesalahan atau melakukan tindakan lain
      print('Tidak berhasil membaca QR code');
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

  Stream<QuerySnapshot<Map<String, dynamic>>> streamPresent() async* {
    FirebaseAuth auth = FirebaseAuth.instance;
    String uid = auth.currentUser!.uid;
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DateTime now = DateTime.now();
    String todayDocID = DateFormat().add_yMd().format(now).replaceAll("/", "-");

    var date = todayDocID.split("-");

    yield* firestore
        .collection("present")
        .where("idUser", isEqualTo: uid)
        .where("tanggal.hari", isEqualTo: date[1])
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamAllPresent() async* {
    FirebaseAuth auth = FirebaseAuth.instance;
    String uid = auth.currentUser!.uid;
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    yield* firestore
        .collection("present")
        .where("idUser", isEqualTo: uid)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    // final user = FirebaseAuth.instance.currentUser;
    FirebaseAuth auth = FirebaseAuth.instance;
    // String uid = auth.currentUser!.uid;

    return Scaffold(
        body: SingleChildScrollView(
      // scrollDirection: Axis.vertical,
      child: Column(
        children: [
          Container(
            child: StreamBuilder<QuerySnapshot>(
                stream: streamPresent(),
                builder: (context, snap) {
                  var _isCheckIn = snap.data!.size > 0 ? false : true;
                  Map<String, dynamic>? data;

                  if (!_isCheckIn) {
                    data = snap.data!.docs[0].data() as Map<String, dynamic>?;
                  }

                  // print(data);
                  return Stack(
                    children: [
                      Container(
                          child: Image.asset(
                        Gambar.lmbur,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height * 0.4,
                      )),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 20),
                        width: double.infinity,
                        padding: const EdgeInsets.only(),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  IconButton(
                                      icon: const Icon(Icons.arrow_back),
                                      color: Warna.putih,
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const MyPages()));
                                      }),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Title(
                              color: Warna.putih,
                              child: Text(
                                (DateFormat('KK:mm').format(DateTime.now())),
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
                          margin: const EdgeInsets.only(top: 180, bottom: 10),
                          width: double.infinity,
                          padding: const EdgeInsets.all(25),
                          child: data?["waktu_pulang"].toString() == "{}" ||
                                  data == null
                              ? ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _isCheckIn
                                        ? Warna.kuning
                                        : Warna.hijau2,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 20),
                                  ),
                                  child: Text(
                                      _isCheckIn ? "Check In" : "Check Out"),
                                  onPressed: () {
                                    setState(() {
                                      _isCheckIn = false;
                                    });
                                    scanQR();
                                  },
                                )
                              : null)
                    ],
                  );
                }),
          ),
          const SizedBox(
            height: 10,
          ),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: streamAllPresent(),
            builder: ((context, snapPresent) {
              if (snapPresent.data?.docs.length == 0 ||
                  snapPresent.data == null) {
                return const SizedBox(
                  height: 400,
                  child: Center(
                    child: Text("Maaf, History absen anda belum ada!!!"),
                  ),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: snapPresent.data!.docs.length,
                itemBuilder: (context, index) {
                  Map<String, dynamic> data =
                      snapPresent.data!.docs[index].data();

                  var date =
                      "${data["tanggal"]["hari"]}/${data["tanggal"]["bulan"]}/${data["tanggal"]["tahun"]}";

                  return AttendanceCard(
                    date: date,
                    checkIn:
                        "${data["waktu_datang"]["jam"]}:${data["waktu_datang"]["menit"]}",
                    checkout: data["waktu_pulang"]["jam"] == null
                        ? "-"
                        : "${data["waktu_pulang"]["jam"]}:${data["waktu_pulang"]["menit"]}",
                  );
                },
              );
            }),
          )
        ],
      ),
    ));
  }
}
