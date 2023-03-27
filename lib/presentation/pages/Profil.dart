// ignore_for_file: camel_case_types, avoid_print, use_build_context_synchronously, unused_local_variable, non_constant_identifier_names, file_names

import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/Utils/Utils.dart';
import 'package:intl/intl.dart';
import '../widgets/formcuxtom.dart';
import 'package:flutter_application_1/presentation/pages/login.dart';
import 'package:flutter_application_1/presentation/resources/warna.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';

class Profil extends StatefulWidget {
  const Profil({Key? key}) : super(key: key);

  @override
  State<Profil> createState() => _profilState();
}

class _profilState extends State<Profil> {
  bool isSelected = false;
  File? image;

  // var _nama = "";
  // var _email = "";
  // var _alamat = "";
  // var _noHp = "";
  // var _noRek = "";

  final _nama = TextEditingController();
  final _email = TextEditingController();
  final _alamat = TextEditingController();
  final _noHp = TextEditingController();
  final _noRek = TextEditingController();

  // void dispose() {
  //   _nama.dispose();

  //   super.dispose();
  // }

  Future pikcImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;

      final imgTmp = File(image.path);
      setState(() => this.image = imgTmp);
    } on PlatformException {
      print("failed pick image.");
    }
  }

  Future sendData() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    try {
      var snapshot = await FirebaseStorage.instance
          .ref()
          .child("images")
          .child('${DateTime.now()}-bukti.jpg')
          .putFile(image!);
      var downloadUrl = await snapshot.ref.getDownloadURL();

      final doc = FirebaseFirestore.instance.collection("profil");
      final json = {
        "image": downloadUrl,
      };

      await doc.add(json);

      setState(() {
        image = null;
      });
      Navigator.of(context, rootNavigator: true).pop('dialog');
    } on FirebaseAuthException catch (e) {
      Navigator.of(context, rootNavigator: true).pop('dialog');
      Utils.showSnackBar(e.message, Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Warna.hijau2,
        actions: [
          Container(
            margin: const EdgeInsets.all(13),
            padding: const EdgeInsets.symmetric(horizontal: 139),
            child: Text(
              "Profil",
              style: TextStyle(
                color: Warna.putih,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.only(bottom: 5),
        child: StreamBuilder<QuerySnapshot>(
          stream: firestore
              .collection("users")
              .where("email", isEqualTo: user!.email)
              .snapshots(),
          builder: (context, snapshot) {
            return !snapshot.hasData
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : ListView.builder(
                    itemCount: 1,
                    itemBuilder: (context, index) {
                      TextEditingController controller =
                          TextEditingController();
                      DocumentSnapshot data = snapshot.data!.docs[index];

                      return ItemCard(
                          uid: data.id,
                          nama: data['nama'],
                          email: data['email'],
                          alamat: data['alamat'],
                          no_hp: data['no_hp'],
                          no_rekening: data['no_rekening']);
                    },
                  );
          },
        ),
      ),
    );
  } // SizedBox(

  Container ItemCard(
      {String? uid,
      String? nama,
      String? email,
      String? alamat,
      String? no_hp,
      String? no_rekening}) {
    return Container(
      padding: const EdgeInsets.only(right: 6, left: 6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Nama",
            style: TextStyle(
              fontSize: 15,
              color: Warna.htam,
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          FormCustom(
            text: nama.toString(),
            controller: _nama,
          ),
          const SizedBox(
            height: 5,
          ),
          const SizedBox(
            height: 5,
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            "Alamat",
            style: TextStyle(
              fontSize: 15,
              color: Warna.htam,
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          FormCustom(
            text: alamat.toString(),
            controller: _alamat,
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            "No Hp",
            style: TextStyle(
              fontSize: 15,
              color: Warna.htam,
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          FormCustom(
            text: no_hp.toString(),
            controller: _noHp,
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            "No Rekening",
            style: TextStyle(
              fontSize: 15,
              color: Warna.htam,
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          FormCustom(
            text: no_rekening.toString(),
            controller: _noRek,
          ),
          const SizedBox(
            height: 5,
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 5),
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Warna.hijau2,
                padding: const EdgeInsets.symmetric(vertical: 17),
              ),
              child: const Text("Update"),
              onPressed: () {
                DateTime now = DateTime.now();
                String todayDocID =
                    DateFormat().add_yMd().format(now).replaceAll("/", "-");
                FirebaseFirestore firestore = FirebaseFirestore.instance;

                firestore.collection('users').doc(uid).set({
                  'nama': _nama.text.isNotEmpty ? _nama.text : nama.toString(),
                  'alamat': _alamat.text.isNotEmpty
                      ? _alamat.text
                      : alamat.toString(),
                  'no_hp':
                      _noHp.text.isNotEmpty ? _noHp.text : no_hp.toString(),
                  'no_rekening': _noRek.text.isNotEmpty
                      ? _noRek.text
                      : no_rekening.toString(),
                }, SetOptions(merge: true));
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 5),
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Warna.mrah,
                padding: const EdgeInsets.symmetric(vertical: 17),
              ),
              child: const Text("Logout"),
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => const Login()));
                Utils.showSnackBar("Berhasil Logout.", Colors.red);
              },
            ),
          )
        ],
      ),
    );
  }
}
