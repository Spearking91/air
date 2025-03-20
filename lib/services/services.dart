import 'package:air/models/upload.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class FirebaseDatabaseMethods {
  FirebaseDatabaseMethods._();
  static final _database = FirebaseDatabase.instance;

  //As stream
  static Stream<UploadModel> getDataAsStream() {
    final databaseRef =
        _database.ref().child("${Constants.firebasePath}/devices.json");
    return databaseRef.orderByKey().limitToLast(1).onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      final latestData = data.values.first;
      final reading = Map<String, dynamic>.from(latestData as Map);
      Text("Future: $reading");

      return UploadModel.fromJson(reading);
    });
  }

  //As future
  static Future<UploadModel> getDataAsFuture() async {
    final databaseRef = _database.ref().child(Constants.firebasePath);
    final data = await databaseRef.orderByKey().limitToLast(1).get();
    final latestReading = data.value as Map<dynamic, dynamic>;
    final latestData = latestReading.values.first;
    final reading = Map<String, dynamic>.from(latestData as Map);
    Text("future: $reading");
    return UploadModel.fromJson(reading);
  }

  // static Future<List<UploadModel>> getListDataAsFuture() async {
  //   final databaseRef = _database.ref().child(Constants.firebasePath);
  //   final data = await databaseRef.orderByKey().limitToLast(1)  .get();
  //   final latestReading = data.value as Map<dynamic, dynamic>;
  //   final latestData = latestReading.values.first;
  //   final reading = Map<String, dynamic>.from(latestData as Map);
  //   Text("future: $reading");
  //   return UploadModel.fromJson(reading);
  // }

  // Add this to your Firebase database methods class
  static Stream<List<UploadModel>> getLogsAsStream() {
    final databaseRef = FirebaseDatabase.instance.ref('readings');
    return databaseRef
        .limitToLast(10) // Adjust this number to control how many logs to show
        .onValue
        .map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];

      return data.entries.map((e) {
        final value = e.value as Map<dynamic, dynamic>;
        return UploadModel.fromJson(Map<String, dynamic>.from(value));
      }).toList();
    });
  }
}

class FirebaseAuthMethod {
  const FirebaseAuthMethod._();
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static FirebaseAuth get auth => _auth;

  static final User? _user = _auth.currentUser;

  static User? get user => _user;

  static Future<User?> signIn(
      {required String email, required String password}) async {
    try {
      final user = await auth.signInWithEmailAndPassword(
          email: email, password: password);

      return user.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<User?> signUp(
      {required String email, required String password}) async {
    try {
      final user = await auth.createUserWithEmailAndPassword(
          email: email, password: password);

      return user.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}

class Constants {
  Constants._();
  static const firebaseUrl = 'https://air-esp32-default-rtdb.firebaseio.com/';
  static const firebasePath = 'firsTestSystem/';
}








// import 'package:air/models/upload.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class FirebaseDatabaseMethods {
//   FirebaseDatabaseMethods._();
//   static final _database = FirebaseDatabase.instance;
//   static final _firestore = FirebaseFirestore.instance;

//   // Get device IDs for current user
//   static Stream<List<String>> getUserDeviceIds() {
//     final userId = FirebaseAuthMethod.user?.uid;
//     if (userId == null) return Stream.value([]);

//     return _firestore
//         .collection('users')
//         .doc(userId)
//         .snapshots()
//         .map((snapshot) {
//       if (!snapshot.exists) return [];
//       final data = snapshot.data();
//       if (data == null || !data.containsKey('deviceIds')) return [];

//       return List<String>.from(data['deviceIds'] as List);
//     });
//   }

//   // Modified to handle multiple devices
//   static Stream<List<UploadModel>> getDataAsStream() {
//     return getUserDeviceIds().asyncMap((deviceIds) async {
//       final allData = await Future.wait(
//         deviceIds.map((deviceId) {
//           final databaseRef = _database
//               .ref()
//               .child("${Constants.firebasePath}/$deviceId/devices.json");
//           return databaseRef.orderByKey().limitToLast(1).once().then((event) {
//             if (event.snapshot.value == null) return null;
//             final data = event.snapshot.value as Map<dynamic, dynamic>;
//             final latestData = data.values.first;
//             final reading = Map<String, dynamic>.from(latestData as Map);
//             return UploadModel.fromJson(reading);
//           });
//         }),
//       );

//       return allData.whereType<UploadModel>().toList();
//     });
//   }

//   // Modified future version
//   static Future<List<UploadModel>> getDataAsFuture() async {
//     final deviceIds = await getUserDeviceIds().first;
//     final allData = await Future.wait(
//       deviceIds.map((deviceId) async {
//         final databaseRef =
//             _database.ref().child("${Constants.firebasePath}/$deviceId");
//         final data = await databaseRef.orderByKey().limitToLast(1).get();
//         if (data.value == null) return null;

//         final latestReading = data.value as Map<dynamic, dynamic>;
//         final latestData = latestReading.values.first;
//         final reading = Map<String, dynamic>.from(latestData as Map);
//         return UploadModel.fromJson(reading);
//       }),
//     );

//     return allData.whereType<UploadModel>().toList();
//   }

//   // Add this to your Firebase database methods class
//   static Stream<List<UploadModel>> getLogsAsStream() {
//     final databaseRef = FirebaseDatabase.instance.ref('readings');
//     return databaseRef
//         .limitToLast(10) // Adjust this number to control how many logs to show
//         .onValue
//         .map((event) {
//       final data = event.snapshot.value as Map<dynamic, dynamic>?;
//       if (data == null) return [];

//       return data.entries.map((e) {
//         final value = e.value as Map<dynamic, dynamic>;
//         return UploadModel.fromJson(Map<String, dynamic>.from(value));
//       }).toList();
//     });
//   }
// }

// class FirebaseAuthMethod {
//   const FirebaseAuthMethod._();
//   static final FirebaseAuth _auth = FirebaseAuth.instance;
//   static FirebaseAuth get auth => _auth;

//   static final User? _user = _auth.currentUser;

//   static User? get user => _user;

//   static Future<User?> signIn(
//       {required String email, required String password}) async {
//     try {
//       final user = await auth.signInWithEmailAndPassword(
//           email: email, password: password);

//       return user.user;
//     } on FirebaseAuthException catch (e) {
//       throw Exception(e.message);
//     } catch (e) {
//       throw Exception(e.toString());
//     }
//   }

//   static Future<User?> signUp(
//       {required String email, required String password}) async {
//     try {
//       final user = await auth.createUserWithEmailAndPassword(
//           email: email, password: password);

//       return user.user;
//     } on FirebaseAuthException catch (e) {
//       throw Exception(e.message);
//     } catch (e) {
//       throw Exception(e.toString());
//     }
//   }
// }

// class Constants {
//   Constants._();
//   static const firebaseUrl = 'https://air-esp32-default-rtdb.firebaseio.com/';
//   static const firebasePath = 'firsTestSystem/';
// }
