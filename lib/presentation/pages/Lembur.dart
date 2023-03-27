// ignore_for_file: await_only_futures, avoid_unnecessary_containers, sized_box_for_whitespace, file_names, unused_local_variable, prefer_is_empty

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:flutter_application_1/Utils/Utils.dart';

import 'package:flutter_application_1/presentation/pages/my_page.dart';
import 'package:flutter_application_1/presentation/resources/warna.dart';

import '../resources/gambar.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:intl/intl.dart';

class Lembur extends StatefulWidget {
  const Lembur({Key? key}) : super(key: key);

  @override
  State<Lembur> createState() => _CheckPageState();
}

class _CheckPageState extends State<Lembur> {
  Future<void> scanQR() async {
    // int _StatusGaji = 123456;
    // Platform messages may fail, so we use a try/catch PlatformException.

    // final user = await FirebaseAuth.instance.currentUser;

    // String uid = await user!.uid;'
    FirebaseAuth auth = FirebaseAuth.instance;
    String uid = auth.currentUser!.uid;

    FirebaseFirestore firestore = FirebaseFirestore.instance;

    CollectionReference<Map<String, dynamic>> cPresent =
        await firestore.collection("users").doc(uid).collection("present");

    CollectionReference<Map<String, dynamic>> usr =
        FirebaseFirestore.instance.collection("users");

    // print("fffffffff = ${usr.get()}");
    // Map<String, dynamic> data = cPresent.doc(uid).collection("users");

    // final data = userss.get();

    QuerySnapshot<Map<String, dynamic>> snapPrensent = await cPresent.get();
    // print("ffff");
    // print("masuk = ${snapPrensent.docs.length}");

    // print(uid);
    DateTime now = DateTime.now();
    String todayDocID = DateFormat().add_yMd().format(now).replaceAll("/", "-");

    String status = "";
    // int gajiDay = 150000;
    // int terLambat;
    // int lembur = 50000;

    if (now.hour >= 6 && now.hour <= 12) {
      status = "Normal";
    } else if (now.hour >= 8 && now.hour <= 5) {
      status = "terlambat";
    }

    if (snapPrensent.docs.isEmpty) {
      await cPresent.doc(todayDocID).set({
        "MulaiLembur": {
          "date": now.toIso8601String(),

          // "user": user!.email,
        }
      });
    } else {
      DocumentSnapshot<Map<String, dynamic>> absenn =
          await cPresent.doc(todayDocID).get();

      if (absenn.exists == true) {
        Map<String, dynamic>? dataPresentTod = absenn.data();

        if (dataPresentTod?["keluar"] != null) {
          Utils.showSnackBar(
              "Sukses Sudah Absen Masuk && Keluar.", Colors.green);
        } else {
          //absen Keluar
          await scanner.scan();
          await cPresent.doc(todayDocID).set({
            "keluarLmebur": {
              "date": now.toIso8601String(),
            }
          });
        }
      } else {
        //masuk
        await scanner.scan();
        await cPresent.doc(todayDocID).update({
          "masukLembur": {
            "date": now.toIso8601String(),
            "status": status,
          }
        });
      }
    }

    // showDialog(
    //   context: context,
    //   barrierDismissible: false,
    //   builder: (context) => Center(
    //     child: CircularProgressIndicator(),
    //   ),
    // );

    // DateTime now = DateTime.now();

    // String _status = "";

    // if (now.hour >= 6 && now.hour <= 8) {
    //   setState(() {
    //     _status = "Normal";
    //   });
    // } else if (now.hour >= 8 && now.hour <= 5) {
    //   setState(() {
    //     _status = "terlambat";
    //   });
    // }

    // await FirebaseFirestore.instance.collection('users').doc().update({
    //   "status": _status,
    // });

    // try {
    //   final docUser = await FirebaseFirestore.instance
    //       .collection("users")
    //       .where("email", isEqualTo: user!.email)
    //       .get();

    //   String nama = docUser.docs[0]["nama"];
    //   final doc = FirebaseFirestore.instance.collection("absen");

    //   await FirebaseFirestore.instance.collection('users').doc().update({
    //     "check_in": now,
    //   });

    // print(now);

    // final json = {
    //   "nama": nama,
    //   "email": user.email,
    //   "created_at": now,
    //   "check_in": now,
    //   "check_out": "",
    //   "month": DateFormat("MMMM").format(now),
    //   "tanggal": DateFormat("EEEE, dd MMMM yyyy").format(now),
    // };

    // await doc.add(json);

    //   Utils.showSnackBar("Berhasil Check In.", Colors.green);

    //   Navigator.of(context, rootNavigator: true).pop('dialog');
    //   // navigatorKey.currentState!.pop();
    // } on FirebaseAuthException catch (e) {
    //   Navigator.of(context, rootNavigator: true).pop('dialog');
    //   Utils.showSnackBar(e.message, Colors.red);
    // }
    // print(barcodeScanRes);,

    // print(barcodeScanRes);
  }

  // Future scanQROut(String? id) async {
  //   String barcodeScanRes;
  //   int absen;
  //   // Platform messages may fail, so we use a try/catch PlatformException.
  //   try {
  //     barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
  //         '#ff6666', 'Cancel', true, ScanMode.QR);
  //     await scanner.scan();
  //     final user = FirebaseAuth.instance.currentUser;

  //     // showDialog(
  //     //   context: context,
  //     //   barrierDismissible: false,
  //     //   builder: (context) => Center(
  //     //     child: CircularProgressIndicator(),
  //     //   ),
  //     // );

  //     try {
  //       final doc = FirebaseFirestore.instance.collection("users").doc(id);
  //       DateTime now = DateTime.now();
  //       // String _StatusC = "";

  //       final user = FirebaseAuth.instance.currentUser;

  //       // if (now.hour >= 16 && now.hour <= 17) {
  //       //   _StatusC = "Pulang tepat waktu";
  //       // } else {
  //       //   _StatusC = "Lembur";
  //       // }

  //       // await FirebaseFirestore.instance.collection('users').doc().update({
  //       //   "statusD": _StatusC,
  //       // });

  //       final json = {
  //         "check_out": now,
  //         // "statusOut": _StatusC,
  //         // 'gaji': _StatusGaji,
  //       };

  //       await doc.set(json);

  //       // final docUser = FirebaseFirestore.instance.collection('users').doc(id);

  //       // final jsonn = {
  //       //   'gaji': _StatusGaji,
  //       // };

  //       // await docUser.set(jsonn);

  //       Utils.showSnackBar("Berhasil Check Out.", Colors.green);

  //       Navigator.of(context, rootNavigator: true).pop('dialog');
  //       // navigatorKey.currentState!.pop();
  //     } on FirebaseAuthException catch (e) {
  //       Navigator.of(context, rootNavigator: true).pop('dialog');
  //       Utils.showSnackBar(e.message, Colors.red);
  //     }
  //     // print(barcodeScanRes);
  //   } on PlatformException {
  //     barcodeScanRes = 'Failed to get platform version.';
  //   }

  //   // If the widget was removed from the tree while the asynchronous platform
  //   // message was in flight, we want to discard the reply rather than calling
  //   // setState to update our non-existent appearance.
  //   if (!mounted) return;

  //   //print(barcodeScanRes);
  // }
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
                            Container(
                                child: Image.asset(
                              Gambar.lmbur,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: MediaQuery.of(context).size.height * 0.4,
                            )),
                            Container(
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
                                  Row(
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
                                  const SizedBox(
                                    height: 20,
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
                                    backgroundColor: Warna.kuning,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 20),
                                  ),
                                  child: const Text("Check In"),
                                  onPressed: () {
                                    scanQR();
                                    // Navigator.push(context,
                                    //     MaterialPageRoute(builder: (context) => Csan()));
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
                        itemCount: snapPresence.data!.docs.length,
                        itemBuilder: (context, index) {
                          Map<String, dynamic> data =
                              snapPresence.data!.docs[index].data();

                          // totalGaji = ambil gaji yang bulan 1 lalu jumlahkan (tG)
                          //total lembur (tL)
                          //total bonus (tB)
                          //mines keterlambatan (mK)

                          //gaji bulan ini.bulan =  tG + tL + tb - mK

                          return SingleChildScrollView(
                            child: Container(
                              alignment: Alignment.centerLeft,
                              margin: const EdgeInsets.all(20),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
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
                                        "  ${DateFormat.yMMMEd().format(DateTime.parse(data['date']))}",
                                        // data!["tanggal"],
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
                                      data['masuk']?['date'] == null
                                          ? "-"
                                          : DateFormat.jms().format(
                                              DateTime.parse(
                                                  data['masuk']['date'])),
                                      // DateFormat("HH mm")
                                      //     .format(data["date"].toDate()),
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
                                        data['keluar']?['date'] == null
                                            ? "-"
                                            : DateFormat.jms().format(
                                                DateTime.parse(
                                                    data['keluar']['date'])),
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
                                    ],
                                  )
                                ],
                              ),
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
}
