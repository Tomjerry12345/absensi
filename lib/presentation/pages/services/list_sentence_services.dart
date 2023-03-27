// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter_application_1/models/user.dart';

// class ListUserServices {
//   CollectionReference indoBugisCollection =
//       FirebaseFirestore.instance.collection('user');

//   Future<List> fetchList() async {
//     try {
//       QuerySnapshot result = await indoBugisCollection.get();

//       List listnya = result.docs.map((e) {
//         return e.data();
//       }).toList();

//       List<user> listSentence = result.docs.map((e) {
//         return user.fromJson(e.id, e.data() as Map<String, dynamic>);
//       }).toList();

//       return listnya;
//     } catch (e) {
//       throw e;
//     }
//   }
// }
