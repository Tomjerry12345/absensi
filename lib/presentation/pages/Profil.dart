// ignore_for_file: camel_case_types, avoid_print, non_constant_identifier_names, avoid_unnecessary_containers, unused_local_variable

import 'dart:developer';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/Utils/Utils.dart';
import 'package:flutter_application_1/presentation/pages/edit_Profil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as s;
// import 'package:month_picker_dialog/month_picker_dialog.dart';
import '../resources/gambar.dart';
import '../resources/warna.dart';

import 'package:image_picker/image_picker.dart';

// import 'package:month_year_picker/month_year_picker.dart';

class Profil extends StatefulWidget {
  const Profil({Key? key}) : super(key: key);

  @override
  State<Profil> createState() => _ProfilState();
}

class _ProfilState extends State<Profil> {
  DateTime selectedPeriod = DateTime.now();
  bool show = false;
  File? image;
  String? imageUrl;

  s.FirebaseStorage storage = s.FirebaseStorage.instance;

  Future pikcImage() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    final user = FirebaseAuth.instance.currentUser;
    FirebaseAuth auth = FirebaseAuth.instance;
    String uid = auth.currentUser!.uid;
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;

      final imgTmp = File(image.path);

      // Upload gambar ke Firebase Storage
      final Reference storageReference =
          FirebaseStorage.instance.ref().child('nama_folder/gambar.jpg');
      final UploadTask uploadTask = storageReference.putFile(imgTmp);
      final TaskSnapshot taskSnapshot =
          await uploadTask.whenComplete(() => null);

      // Perbarui URL gambar di Firestore atau database lainnya
      final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      imageUrl = downloadUrl;
      FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'url_gambar': downloadUrl});

      // Perbarui status widget dengan gambar yang dipilih
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
      builder: (context) => Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final docUser = await FirebaseFirestore.instance
          .collection("users")
          .where("email", isEqualTo: user!.email)
          .get();

      String nama = docUser.docs[0]["nama"];

      var snapshot = await FirebaseStorage.instance
          .ref()
          .child("images")
          .child('${DateTime.now()}-bukti.jpg')
          .putFile(image!);
      var downloadUrl = await snapshot.ref.getDownloadURL();

      Navigator.of(context, rootNavigator: true).pop('dialog');
      // navigatorKey.currentState!.pop();
    } on FirebaseAuthException catch (e) {
      Navigator.of(context, rootNavigator: true).pop('dialog');
      Utils.showSnackBar(e.message, Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    final user = FirebaseAuth.instance.currentUser;
    return StreamBuilder<QuerySnapshot>(
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
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot data = snapshot.data!.docs[index];
                  return ItemCard(
                    nama: data['nama'],
                    url_gambar: data['url_gambar'],
                    email: data['email'],
                    noHp: data['no_hp'],
                    alamat: data['alamat'],
                    noRekening: data['no_rekening'],
                    deviceId: data['device_id'],
                  );
                },
              );
      },
    );
  }

  Container ItemCard({
    String? nama,
    String? url_gambar,
    String? email,
    String? noHp,
    String? alamat,
    String? noRekening,
    String? deviceId,
  }) {
    return Container(
      child: Column(
        children: <Widget>[
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.3,
                child: Image.asset(Gambar.home1),
              ),
              Container(
                padding: const EdgeInsets.only(
                  bottom: 30,
                ),
                alignment: Alignment.center,
                width: double.infinity,
                child: Stack(
                  children: [
                    ClipOval(
                      child: CircleAvatar(
                        radius: 45,
                        child: imageUrl != null
                            ? Image.network(
                                url_gambar.toString(),
                                height: 150,
                                width: 150,
                                fit: BoxFit.cover,
                              )
                            : Image.network(
                                url_gambar.toString(),
                                height: 150,
                                width: 150,
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                    imageUrl != null
                        ? InkWell(
                            onTap: () {
                              pikcImage();
                            },
                            child: ClipOval(
                              child: CircleAvatar(
                                  radius: 45,
                                  child: Image.network(
                                    imageUrl!,
                                    height: 150,
                                    width: 150,
                                    fit: BoxFit.cover,
                                  )),
                            ))
                        : Container(
                            padding: const EdgeInsets.only(top: 50, left: 60),
                            child: IconButton(
                                icon: const Icon(Icons.add_a_photo),
                                iconSize: 25,
                                color: Warna.htam,
                                onPressed: () {
                                  pikcImage();
                                }),
                          ),
                  ],
                ),
              ),
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.only(
                  top: 100,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const EditProfil()));
                          },
                          child: Text(
                            nama ?? "",
                            style: TextStyle(
                              fontSize: 25,
                              color: Warna.putih,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Karyawan",
                          style: TextStyle(
                            fontSize: 20,
                            color: Warna.kuning,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
          Padding(
            padding: EdgeInsets.all(8),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8))),
              borderOnForeground: true,
              child: SizedBox(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Center(
                          child: Text(
                        "Data Lengkap",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      )),
                      SizedBox(
                        height: 24,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 16,
                          ),
                          Text(
                            "Email",
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(
                            width: 46,
                          ),
                          Text(
                            ":",
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(
                            width: 16,
                          ),
                          Text(
                            email.toString(),
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 16,
                          ),
                          Text(
                            "No Hp",
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(
                            width: 40,
                          ),
                          Text(
                            ":",
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(
                            width: 16,
                          ),
                          Text(
                            noHp.toString(),
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 16,
                          ),
                          Text(
                            "Alamat",
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(
                            width: 32,
                          ),
                          Text(
                            ":",
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(
                            width: 16,
                          ),
                          Text(
                            alamat.toString(),
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 16,
                          ),
                          Text(
                            "No.Rekening",
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(
                            width: 12,
                          ),
                          Text(
                            ":",
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(
                            width: 12,
                          ),
                          Text(
                            noRekening.toString(),
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 16,
                          ),
                          Text(
                            "Device Id",
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(
                            width: 16,
                          ),
                          Text(
                            ":",
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(
                            width: 16,
                          ),
                          Text(
                            deviceId.toString(),
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 16,
                      ),
                    ],
                  ),
                ),
                width: double.infinity,
              ),
            ),
          )
        ],
      ),
    );
  }
}
