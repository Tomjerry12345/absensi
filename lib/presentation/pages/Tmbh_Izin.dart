// ignore_for_file: file_names, use_build_context_synchronously, sized_box_for_whitespace, avoid_print

import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart'
    show CollectionReference, FirebaseFirestore;
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/Utils/Utils.dart';
import 'package:flutter_application_1/presentation/widgets/formcuxtom.dart';
import 'package:image_picker/image_picker.dart';
import '../resources/warna.dart';
import 'package:intl/intl.dart';

class TambhIzin extends StatefulWidget {
  const TambhIzin({Key? key}) : super(key: key);

  @override
  State<TambhIzin> createState() => _TambhIzinState();
}

class _TambhIzinState extends State<TambhIzin> {
  String? dropDownValue;
  List<String> citylist = [
    'Izin',
    'Cuti',
  ];

  DateTime selectedDate = DateTime.now();
  bool isSelected = false;
  bool showDate = false;
  DateTime selectedDate1 = DateTime.now();
  bool isSelected1 = false;
  File? image;
  final keteranganController = TextEditingController();

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

  Future<DateTime> _selectDate1(BuildContext context) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: selectedDate1,
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (selected != null && selected != selectedDate1) {
      setState(() {
        selectedDate1 = selected;
      });
    }
    return selectedDate1;
  }

  String getDate() {
    // ignore: unnecessary_null_comparison
    if (!isSelected) {
      return '';
    } else {
      return DateFormat('dd MMMM yyyy').format(selectedDate);
    }
  }

  String getDate1() {
    // ignore: unnecessary_null_comparison
    if (!isSelected1) {
      return '';
    } else {
      return DateFormat('dd MMMM yyyy').format(selectedDate1);
    }
  }

  Future pikcImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.camera);
      if (image == null) return;

      final imgTmp = File(image.path);
      setState(() => this.image = imgTmp);
    } on PlatformException {
      print("failed pick image.");
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

      // var snapshot = await FirebaseStorage.instance
      //     .ref()
      //     .child("images")
      //     .child('${DateTime.now()}-bukti.jpg')
      //     .putFile(image!);
      // var downloadUrl = await snapshot.ref.getDownloadURL();

      final doc = FirebaseFirestore.instance.collection("pengajuan");
      final json = {
        "email": user.email,
        "created_at": DateTime.now(),
        "jenis": dropDownValue,
        "tanggal_mulai": selectedDate,
        "tanggal_selesai": selectedDate1,
        "keterangan": keteranganController.text.trim(),
        "status": "0",
        // "image": downloadUrl,
        "month": DateFormat("MMMM").format(DateTime.now()),
        "tipe_pengajuan": 'Izin',
        "biaya": "-",
        "tanggal": '-',
        "nama": nama
      };

      await doc.add(json);

     
      Utils.showSnackBar("Berhasil Tambah Izin.", Colors.green);
      keteranganController.clear();
      setState(() {
        selectedDate = DateTime.now();
        isSelected = false;
        selectedDate1 = DateTime.now();
        isSelected1 = false;
        image = null;
        dropDownValue = null;
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
    //
    return Scaffold(
      appBar: AppBar(
        // leading: Icon(Icons.abc),
        backgroundColor: Warna.hijau2,
        actions: const [
          SizedBox(
            height: 5,
          ),
        ],

        title: Text(
          "Pengajuan Izin",
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
                        "Izin",
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Column(
                        children: <Widget>[
                          DropdownButtonFormField(
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
                                filled: true,
                                hintStyle: TextStyle(color: Warna.abuabu),
                                hintText: "Izin / Cuti",
                                fillColor: Warna.putih),
                            value: dropDownValue,
                            // ignore: non_constant_identifier_names
                            onChanged: (String? Value) {
                              setState(() {
                                dropDownValue = Value ?? "";
                              });
                            },
                            items: citylist
                                .map((cityTitle) => DropdownMenuItem(
                                    value: cityTitle, child: Text(cityTitle)))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            child: const Text(
                              "Mulai Tanggal Izin",
                              textAlign: TextAlign.left,
                            ),
                          ),
                          FormCustom(
                            suffixicon: const Icon(Icons.date_range),
                            text: 'Mulai Tanggal Izin',
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
                      height: 2,
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            child: const Text(
                              "Sampai Tanggal Izin",
                              textAlign: TextAlign.left,
                            ),
                          ),
                          FormCustom(
                            suffixicon: const Icon(Icons.date_range),
                            text: 'Sampai Tanggal Izin',
                            readOnly: true,
                            onTap: () {
                              _selectDate1(context);
                              showDate = true;
                              isSelected1 = true;
                            },
                            controller: TextEditingController(text: getDate1()),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 2,
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
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            child: const Text(
                              "Foto",
                              textAlign: TextAlign.left,
                            ),
                          ),
                          image != null
                              ? InkWell(
                                  onTap: () {
                                    pikcImage();
                                  },
                                  child: Image.file(
                                    image!,
                                    height: 150,
                                    width: 150,
                                    fit: BoxFit.cover,
                                  ))
                              : Container(
                                  alignment: Alignment.topLeft,
                                  child: IconButton(
                                      icon: const Icon(Icons.add_a_photo),
                                      iconSize: 50,
                                      color: Warna.abuabu,
                                      onPressed: () {
                                        pikcImage();
                                      }),
                                ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 2,
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 5),
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
