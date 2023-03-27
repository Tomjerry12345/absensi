// ignore_for_file: sized_box_for_whitespace, use_build_context_synchronously, file_names

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/Utils/Utils.dart';
import 'package:flutter_application_1/presentation/widgets/formcuxtom.dart';
import 'package:intl/intl.dart';
import '../resources/warna.dart';

class TambhKasbon extends StatefulWidget {
  const TambhKasbon({Key? key}) : super(key: key);

  @override
  State<TambhKasbon> createState() => _TambhKasbonState();
}

class _TambhKasbonState extends State<TambhKasbon> {
  DateTime selectedDate = DateTime.now();
  bool isSelected = false;
  bool showDate = false;
  final keteranganController = TextEditingController();
  final jumlahController = TextEditingController();

  Future<DateTime> _selectDate(BuildContext context) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (selected != null && selected != selectedDate) {
      setState(() {
        selectedDate = selected;
      });
    }
    return selectedDate;
  }

  String getDate() {
    // ignore: unnecessary_null_comparison
    if (!isSelected) {
      return '';
    } else {
      return DateFormat('dd MMMM yyyy').format(selectedDate);
    }
  }

  Future sendData() async {
    final user = FirebaseAuth.instance.currentUser;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final docUser = await FirebaseFirestore.instance
          .collection("users")
          .where("email", isEqualTo: user!.email)
          .get();

      String nama = docUser.docs[0]["nama"];

      final doc = FirebaseFirestore.instance.collection("pengajuan");
      final json = {
        "uid": user.uid,
        "email": user.email,
        "created_at": DateTime.now(),
        "biaya": jumlahController.text.trim(),
        "tanggal": selectedDate,
        "keterangan": keteranganController.text.trim(),
        "status": "0",
        "month": DateFormat("MMMM").format(DateTime.now()),
        "tipe_pengajuan": 'Kasbon',
        "tanggal_mulai": DateFormat("MMMM").format(DateTime.now()),
        "tanggal_selesai": DateFormat("MMMM").format(DateTime.now()),
        "jenis": '-',
        "image": '-',
        "nama": nama
      };

      await doc.add(json);
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      FirebaseAuth auth = FirebaseAuth.instance;
      String uid = auth.currentUser!.uid;

      CollectionReference<Map<String, dynamic>> cPresent =
          firestore.collection("users").doc(uid).collection("present");

      DateTime now = selectedDate;
      String todayDocID =
          DateFormat().add_yMd().format(now).replaceAll("/", "-");

      // ignore: unrelated_type_equality_checks

      await cPresent.doc(todayDocID).update({
        "uid": user.uid,
        "email": user.email,
        "created_at": DateTime.now(),
        "biaya": jumlahController.text.trim(),
        "tanggal": selectedDate,
        "keterangan": keteranganController.text.trim(),
        "status": "0",
        "month": DateFormat("MMMM").format(DateTime.now()),
        "tipe_pengajuan": 'Kasbon',
      });

      Utils.showSnackBar("Berhasil Tambah Kasbon.", Colors.green);
      keteranganController.clear();
      jumlahController.clear();
      setState(() {
        selectedDate = DateTime.now();
        isSelected = false;
      });
      Navigator.of(context, rootNavigator: true).pop('dialog');
      // navigatorKey.currentState!.pop();
    } on FirebaseAuthException catch (e) {
      Navigator.of(context, rootNavigator: true).pop('dialog');
      Utils.showSnackBar(e.message, Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Warna.hijau2,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 45),
          ),
          const SizedBox(
            height: 5,
          ),
        ],
        title: Text(
          "Pengajuan Kasbon",
          style: TextStyle(
              fontSize: 18, color: Warna.putih, fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.only(top: 20),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      child: const Text(
                        "Jumlah",
                        textAlign: TextAlign.left,
                      ),
                    ),
                    FormCustom(
                      text: 'Rp.',
                      controller: jumlahController,
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      child: const Text(
                        "Tanggal",
                        textAlign: TextAlign.left,
                      ),
                    ),
                    FormCustom(
                      suffixicon: const Icon(Icons.date_range),
                      text: 'Tanggal Kasbon',
                      readOnly: true,
                      onTap: () {
                        _selectDate(context);
                        showDate = true;
                        isSelected = true;
                      },
                      controller: TextEditingController(text: getDate()),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      child: const Text(
                        "Keterangan",
                        textAlign: TextAlign.left,
                      ),
                    ),
                    FormCustom(
                      text: 'Keterangan',
                      controller: keteranganController,
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                width: double.infinity,
                padding: const EdgeInsets.all(3),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Warna.hijau2,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                  ),
                  child: const Text("Kirim"),
                  onPressed: () {
                    sendData();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
