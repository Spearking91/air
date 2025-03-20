import 'dart:async';
import 'package:air/Pages/bluetooth/bluetooth_selection_page.dart';
import 'package:air/Pages/bluetooth_scan_screen.dart';
import 'package:air/Pages/charts_page.dart';
import 'package:air/Pages/devices_page.dart';
import 'package:air/Pages/home_page.dart';
import 'package:air/Pages/logs_page.dart';
import 'package:air/Pages/profile_page.dart';
import 'package:air/widgets/avatar.dart';
import 'package:air/widgets/blue.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';

class DashBoardPage extends StatefulWidget {
  const DashBoardPage({super.key});

  @override
  State<StatefulWidget> createState() => _DashBoardPageState();
}

class _DashBoardPageState extends State<DashBoardPage> {
  bool isOnline = true;
  late StreamSubscription<List<ConnectivityResult>> subscription;

  @override
  void initState() {
    super.initState();
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
  }

  final List<Widget> pages = [
    Homepage(),
    // ChartsPage(),
    LogsPage(),
    DevicesPage(
      onDeviceSelected: (deviceId, deviceName) {},
    )
  ];
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: index != 2 && index != 3
          ? AppBar(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Project',
                    style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18),
                  ),
                  const Text(
                    'Air',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.notifications),
                ),
                Avatar(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return ProfilePage();
                        },
                      ),
                    );
                  },
                  radius: 20,
                )
              ],
              backgroundColor: Colors.black12,
              bottom: !isOnline
                  ? PreferredSize(
                      preferredSize: Size.fromHeight(20),
                      child: Container(
                        color: Colors.orange,
                        // height: 10,
                        child: Center(
                          child: Text(
                            'You Are Offline',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    )
                  : null)
          : !isOnline
              ? PreferredSize(
                  preferredSize: Size.fromHeight(20),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(
                          height: MediaQuery.maybePaddingOf(context)?.top,
                        ),
                        Container(
                          color: Colors.orange,
                          // height: 10,
                          child: Center(
                            child: Text(
                              'You Are Offline',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : null,
      body: IndexedStack(
        index: index,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.speed),
            label: 'Readings',
          ),
          // NavigationDestination(
          //   icon: Icon(Boxicons.bx_chart),
          //   label: 'Charts',
          // ),
          NavigationDestination(
            icon: Icon(Boxicons.bx_list_check),
            label: 'Logs',
          ),
          NavigationDestination(
            icon: Icon(Boxicons.bx_devices),
            label: 'Devices',
          ),
        ],
        selectedIndex: index,
        onDestinationSelected: (int value) {
          setState(() {
            index = value;
          });
        },
      ),
      floatingActionButton: index == 3
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return BluetoothSelectionPage();
                    },
                  ),
                );
              },
              child: Icon(Icons.add),
            )
          : null,
    );
  }
}
