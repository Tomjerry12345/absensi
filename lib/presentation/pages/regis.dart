import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/Utils/Utils.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/presentation/pages/login.dart';
import 'package:platform_device_id/platform_device_id.dart';
import '../widgets/formcuxtom.dart';

import '../resources/warna.dart';

class Regis extends StatefulWidget {
  const Regis({Key? key}) : super(key: key);

  @override
  State<Regis> createState() => RegisState();
}

class RegisState extends State<Regis> {
  final namaController = TextEditingController();
  final alamatController = TextEditingController();
  final hpController = TextEditingController();
  final rekController = TextEditingController();
  final emailController = TextEditingController();
  final passworController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 35),
                width: double.infinity,
                child: Text(
                  "Registrasi",
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 24, color: Warna.abuTr),
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              FormCustom(
                text: "Nama",
                controller: namaController,
              ),
              FormCustom(text: "Alamat", controller: alamatController),
              FormCustom(
                text: "No Hp",
                controller: hpController,
              ),
              FormCustom(
                text: "No Rekening",
                controller: rekController,
              ),
              FormCustom(
                text: "Email",
                controller: emailController,
              ),
              FormCustom(
                text: "Password",
                controller: passworController,
              ),
              const SizedBox(
                height: 20,
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
                  child: const Text("Daftar"),
                  onPressed: () {
                    signUp();
                  },
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Sudah Punya Akun ?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Warna.abuabu,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Login()),
                        );
                      },
                      child: Text(
                        "Login",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: Warna.hijau2,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future signUp() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final res = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passworController.text.trim(),
      );

      String? deviceId = await PlatformDeviceId.getDeviceId;

      final docUser =
          FirebaseFirestore.instance.collection("users").doc(res.user!.uid);
      final json = {
        "email": emailController.text.trim(),
        "nama": namaController.text.trim(),
        "no_rekening": rekController.text.trim(),
        "alamat": alamatController.text.trim(),
        "no_hp": hpController.text.trim(),
        "uid": res.user!.uid,
        "created_at": DateTime.now(),
        "device_id": deviceId,
        "url_gambar": ""
      };

      await docUser.set(json);

      // final doc = FirebaseFirestore.instance
      //     .collection("users")
      //     .doc()
      //     .collection("present")
      //     .doc();

      // final jsonn = {
      //   "email": emailController.text.trim(),
      //   "nama": namaController.text.trim(),
      // };

      // await doc.set(jsonn);

      Utils.showSnackBar("Berhasil Daftar.", Colors.green);
      navigatorKey.currentState!.popUntil((route) => route.isFirst);
    } on FirebaseAuthException catch (e) {
      Navigator.of(context, rootNavigator: true).pop('dialog');
      Utils.showSnackBar(e.message, Colors.red);
    }
  }
}
