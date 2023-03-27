
import 'package:flutter/material.dart';

import 'package:flutter_application_1/presentation/resources/warna.dart';

class AttendanceCard extends StatelessWidget {
  final String date;
  final String checkIn;
  final String checkout;

  const AttendanceCard(
      {super.key,
      required this.date,
      required this.checkIn,
      required this.checkout});

  @override
  Widget build(BuildContext context) {

    return Container(
      alignment: Alignment.centerLeft,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25), //border corner radius
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5), //color of shadow
            spreadRadius: 1, //spread radius
            blurRadius: 7, // blur radius
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // ElevatedButton(
          //     onPressed: () async {
          //       QuerySnapshot<Map<String, dynamic>> object = await firestore
          //           .collection("users")
          //           .doc(uid)
          //           .collection('present')
          //           .get();

          //       // List<Attendance> list = object.docs
          //       //     .map((e) => Attendance.fromJson(e.data()))
          //       //     .toList();

          //       object.docs.forEach((e) {
          //         log(e.data()['gajiDay'].toString());
          //       });
          //     },
          //     child: const Text('test')),
          Row(
            children: [
              const Icon(Icons.date_range),
              const SizedBox(
                width: 10,
              ),
              Text(
                date,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Warna.abuabu,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
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
            const SizedBox(width: 38),
            Text(
              checkIn,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Warna.abuabu,
              ),
            ),
          ]),
          const SizedBox(
            height: 10,
          ),
          Row(children: [
            Text(
              "Check Out",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Warna.htam,
              ),
            ),
            const SizedBox(width: 38),
            Text(
              checkout,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Warna.abuabu,
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
