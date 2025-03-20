import 'package:air/widgets/notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';

class NavbarWidgets extends StatefulWidget {
  const NavbarWidgets({super.key});

  @override
  State<NavbarWidgets> createState() => _NavbarWidgetsState();
}

class _NavbarWidgetsState extends State<NavbarWidgets> {
  @override
  
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: currentPageNotififier,
      builder: (context, currentPage, child) {
        return NavigationBar(
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.speed),
              label: 'Readings',
            ),
            NavigationDestination(
              icon: Icon(Boxicons.bx_chart),
              label: 'Charts',
            ),
            NavigationDestination(
              icon: Icon(Boxicons.bx_list_check),
              label: 'Logs',
            ),
            NavigationDestination(
              icon: Icon(Boxicons.bx_devices),
              label: 'Devices',
            ),
          ],
          selectedIndex: currentPage,
          onDestinationSelected: (int value) {
            currentPageNotififier.value = value;
          },
        );
      },
    );
  }
}

