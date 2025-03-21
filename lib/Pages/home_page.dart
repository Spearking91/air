import 'dart:async';
import 'package:air/widgets/meter.dart';
import 'package:air/widgets/progress_bar.dart';
import 'package:air/models/upload.dart';
import 'package:air/widgets/themed_container.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import '../services/services.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  late Timer _timer;
  late Future<UploadModel> reading;
  late Future<UploadModel> timeStamp;
  bool isOnline = true;
  late StreamSubscription<List<ConnectivityResult>> subscription;

  @override
  void initState() {
    super.initState();
    reading = FirebaseDatabaseMethods.getDataAsFuture();
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      if (result.contains(ConnectivityResult.none)) {
        setState(() {
          isOnline = false;
        });
      } else {
        setState(() {
          isOnline = true;
        });
      }
    });
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      setState(() {
        reading = FirebaseDatabaseMethods.getDataAsFuture();
        timeStamp = FirebaseDatabaseMethods.getDataAsFuture();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            CContainer(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      // mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Reading',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.info),
                          color: Colors.white60,
                        ),
                      ],
                    ),
                  ),
                  Divider(),
                  Container(
                    height: MediaQuery.sizeOf(context).height * 0.4,
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                    child: StreamBuilder<UploadModel>(
                      stream: FirebaseDatabaseMethods.getDataAsStream(''),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Meter(
                            value: snapshot.data?.pms ?? 0,
                            index: snapshot.data?.pms ?? 0,
                          );
                        } else if (snapshot.hasError) {
                          return Text(snapshot.error.toString());
                        } else {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  Theme.of(context).colorScheme.onSecondary,
                  Theme.of(context).colorScheme.inversePrimary,
                ]),
                borderRadius: BorderRadius.circular(15),
              ),
              width: MediaQuery.sizeOf(context).width,
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Parameters',
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 20),
                      ),
                    ],
                  ),
                  Divider(),
                  FutureBuilder<UploadModel>(
                      future: reading,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Column(
                            children: [
                              ProgressBar(
                                value: snapshot.data?.pms ?? 0,
                                title: 'PMS 2.5',
                              ),
                              if (snapshot.data?.timestamp != null) ...[
                                SizedBox(height: 8),
                                Text(
                                  'Last Update: ${snapshot.data!.timestamp!.toString().split('.')[0]}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ],
                          );
                        } else if (snapshot.hasError) {
                          return Text(snapshot.error.toString());
                        } else {
                          return const CircularProgressIndicator();
                        }
                      }),
                  SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

      // body: Center(
      //   child: Column(
      //     spacing: 20,
      //     children: [
      
      //       StreamBuilder<UploadModel>(
      //         stream: FirebaseDatabaseMethods.getDataAsStream(),
      //         builder: (context, snapshot) {
      //           if (snapshot.hasData) {
      //             return Text('PMS Value: ${snapshot.data?.pms ?? 0}');
      //           } else if (snapshot.hasError) {
      //             return Text(snapshot.error.toString());
      //           } else {
      //             return const CircularProgressIndicator();
      //           }
      //         },
      //       ),
      //       FutureBuilder<UploadModel>(
      //         future: reading,
      //         builder: (context, snapshot) {
      //           if (snapshot.hasData) {
      //             return Text('PMS Value: ${snapshot.data?.pms ?? 0}');
      //           } else if (snapshot.hasError) {
      //             return Text(snapshot.error.toString());
      //           } else {
      //             return const CircularProgressIndicator();
      //           }
      //         },
      //       ),
      //     ],
      //   ),
      // ),


//       FutureBuilder<UploadModel>(
//   future: reading,
//   builder: (context, snapshot) {
//     if (snapshot.hasData) {
//       return Column(
//         children: [
//           ProgressBar(
//             value: snapshot.data?.pms ?? 0,
//             percent: 30,
//             title: 'PMS 2.5',
//           ),
//           if (snapshot.data?.timestamp != null) ...[
//             SizedBox(height: 8),
//             Text(
//               'Last Update: ${snapshot.data!.timestamp!.toString().split('.')[0]}',
//               style: TextStyle(
//                 fontSize: 12,
//                 color: Colors.grey[600],
//               ),
//             ),
//           ],
//         ],
//       );
//     } else if (snapshot.hasError) {
//       return Text(snapshot.error.toString());
//     } else {
//       return const CircularProgressIndicator();
//     }
//   }
// ),