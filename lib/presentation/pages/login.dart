// ignore_for_file: avoid_unnecessary_containers, sized_box_for_whitespace, sort_child_properties_last, use_build_context_synchronously, unused_local_variable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/Utils/Utils.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/presentation/widgets/formcuxtom.dart';
import 'regis.dart';
import '../resources/warna.dart';
import 'package:platform_device_id/platform_device_id.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final emailController = TextEditingController();
  final passworController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 30),
                width: double.infinity,
                height: 100,
                child: Image.asset("assets/logo.png"),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Welcome",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 24,
                    color: Warna.abuTr,
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      child: const Text(
                        "Email",
                        textAlign: TextAlign.left,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    FormCustom(
                      text: 'Email',
                      controller: emailController,
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      child: const Text(
                        "Password",
                        textAlign: TextAlign.left,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    FormCustom(
                      text: 'Password',
                      controller: passworController,
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                alignment: Alignment.centerRight,
                child: TextButton(
                  child: const Text("Lupa Password ?"),
                  style: TextButton.styleFrom(foregroundColor: Warna.borderside),
                  onPressed: () {},
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Warna.hijau2,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                  ),
                  child: const Text("Masuk"),
                  onPressed: () {
                    signIn();
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
                      "Tidak Punya Akun ?",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15, color: Warna.noaccount),
                    ),
                    TextButton(
                      //untuk tombol kembali di lembur
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Regis()),
                        );
                      },
                      child: Text(
                        "Daftar",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: Warna.hijau2,
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future signIn() async {
    final user = await FirebaseFirestore.instance
        .collection("users")
        .where("email", isEqualTo: emailController.text.trim())
        .get();

    if (user.docs.isNotEmpty) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      String? e = user.docs[0]["email"];
      String? id = user.docs[0]["device_id"];
      String? deviceId = await PlatformDeviceId.getDeviceId;

      if (id != deviceId) {
        Navigator.of(context, rootNavigator: true).pop('dialog');
        Utils.showSnackBar(
            "Device yang digunakan untuk login tidak sama dengan device untuk register.",
            Colors.red);
      } else {
        try {
          final res = await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passworController.text.trim(),
          );

          Utils.showSnackBar("Berhasil Login.", Colors.green);
          navigatorKey.currentState!.popUntil((route) => route.isFirst);
        } on FirebaseAuthException catch (e) {
          Navigator.of(context, rootNavigator: true).pop('dialog');
          Utils.showSnackBar(e.message, Colors.red);
        }
      }
    } else {
      // Navigator.of(context, rootNavigator: true).pop('dialog');
      Utils.showSnackBar("User tidak ditemukan.", Colors.red);
    }
  }
}