import 'package:air/auth/login_page.dart';
import 'package:air/services/services.dart';
import 'package:air/widgets/avatar.dart';
import 'package:air/widgets/notifier.dart';
import 'package:air/widgets/themed_container.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> account = [
      {
        'title': "Email",
        'subtitle': "JamesHaller@example.com",
        'icon': Icons.email
      },
      {
        'title': "Phone",
        'subtitle': 250989089,
        'icon': Icons.phone,
      },
      {
        'title': "Theme",
        'subtitle': isDarkNotififier.value == null
            ? 'system'
            : isDarkNotififier.value!
                ? 'Dark'
                : 'light',
        'icon': isDarkNotififier.value == null
            ? Icons.brightness_auto_outlined
            : isDarkNotififier.value!
                ? Icons.dark_mode
                : Icons.light_mode,
      },
      {
        'title': "Logout",
        'subtitle': null,
        'icon': Icons.logout,
      },
    ];

    final items = const {'Devices': 2, 'Active': 7, 'Offline': 4};
    return Scaffold(
      body: SingleChildScrollView(
        child: DecoratedBox(
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
            Theme.of(context).colorScheme.onPrimaryFixed,
            Theme.of(context).colorScheme.onPrimaryFixedVariant,
          ])),
          child: Column(
            children: [
              ListView(
                shrinkWrap: true,
                children: [
                  Avatar(),
                  Center(
                    child: Text(
                      'James Haller',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Center(
                      child: Text(
                    'JamesHaller@example.com',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.white60,
                    ),
                  )),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: MediaQuery.sizeOf(context).width,
                      height: MediaQuery.sizeOf(context).height * 0.1,
                      margin: EdgeInsets.only(top: 16),
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color.fromARGB(255, 39, 147, 115),
                              const Color.fromARGB(255, 32, 69, 33),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        // crossAxisAlignment: CrossAxisAlignment.center,
                        children: List.generate(
                          items.length,
                          (index) => Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                items.keys.elementAt(index),
                                style: TextStyle(color: Colors.white),
                              ),
                              Text(
                                items.values.elementAt(index).toString(),
                                style: TextStyle(
                                    fontSize: 30.0,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  // color: Colors.white,
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: List.generate(
                    account.length,
                    (index) {
                      return ListTile(
                        onTap: () async {
                          try {
                            await FirebaseAuthMethod.auth.signOut();
                            // Navigate to home page or login page after sign out
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginPage()),
                              (route) => false,
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error signing out: $e')),
                            );
                          }
                        },
                        leading: Icon(account[index]['icon']),
                        title: Text(account[index]['title']),
                        subtitle: account[index]['title'] == 'Phone'
                            ? Text(
                                '+233${account[index]['subtitle'].toString()}')
                            : account[index]['subtitle'] != null
                                ? Text(account[index]['subtitle'])
                                : null,
                        trailing: account[index]['title'] != 'Theme'
                            ? Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                              )
                            : ValueListenableBuilder(
                                valueListenable: isDarkNotififier,
                                builder: (context, isDarkMode, child) {
                                  return Checkbox(
                                    tristate: true,
                                    value: isDarkMode,
                                    onChanged: (bool? value) {
                                      isDarkNotififier.value = value;
                                    },
                                  );
                                },
                              ),
                      );
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
