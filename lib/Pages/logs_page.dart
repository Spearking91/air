import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/upload.dart';
import '../services/services.dart';

class LogsPage extends StatefulWidget {
  const LogsPage({super.key});

  @override
  State<LogsPage> createState() => _LogsPageState();
}

class _LogsPageState extends State<LogsPage> {
  List<Map<String, dynamic>> days = [
    {"Day": "MON", "Long": 15.toDouble(), "short": 8.toDouble()},
    {"Day": "TUE", "Long": 8.toDouble(), "short": 2.toDouble()},
    {"Day": "WED", "Long": 18.toDouble(), "short": 10.toDouble()},
    {"Day": "THU", "Long": 35.toDouble(), "short": 6.toDouble()},
    {"Day": "FRI", "Long": 25.toDouble(), "short": 3.toDouble()},
    {"Day": "SAT", "Long": 23.toDouble(), "short": 7.toDouble()},
    {"Day": "SUN", "Long": 15.toDouble(), "short": 5.toDouble()},
  ];

  late Stream<List<UploadModel>> _uploadsStream;

  @override
  void initState() {
    super.initState();
    _uploadsStream = FirebaseDatabaseMethods.getLogsAsStream();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            height: MediaQuery.sizeOf(context).height * 0.45,
            width: MediaQuery.sizeOf(context).width,
            padding: EdgeInsets.only(top: 25),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color.fromARGB(255, 39, 147, 115),
                  const Color.fromARGB(255, 32, 69, 33),
                ],
              ),
            ),
            child: Column(
              children: [
                ListTile(
                  title: Text(
                    'Good Morning',
                    style: TextStyle(color: Colors.white70),
                  ),
                  subtitle: Text(
                    'Unknown',
                    style: TextStyle(color: Colors.white),
                  ),
                  contentPadding: EdgeInsets.only(right: 0, left: 16),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton.filled(
                        icon: Icon(
                          Icons.search,
                        ),
                        color: Colors.white70,
                        onPressed: () {},
                      ),
                      IconButton.filled(
                        icon: Icon(
                          Icons.notifications,
                        ),
                        color: Colors.white70,
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
                AspectRatio(
                  aspectRatio: 1.6,
                  child: Center(
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceEvenly,
                        barGroups: [
                          ...List.generate(
                            days.length,
                            (index) {
                              return BarChartGroupData(
                                x: index,
                                barRods: [
                                  BarChartRodData(
                                    width: 15,
                                    borderRadius: BorderRadius.zero,
                                    color: Colors.red,
                                    toY: days[index]["Long"],
                                  ),
                                  BarChartRodData(
                                    color: Colors.greenAccent,
                                    toY: days[index]["short"],
                                  ),
                                ],
                              );
                            },
                          )
                        ],
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            axisNameWidget: Text(
                              'Days Of the week',
                            ),
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                // Convert the value (index) to an integer and get the corresponding day
                                final index = value.toInt();
                                if (index >= 0 && index < days.length) {
                                  return SideTitleWidget(
                                    meta: meta,
                                    child: Text(
                                      days[index][
                                          "Day"], // Get the "Day" value from the map
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                  );
                                }
                                return SideTitleWidget(
                                  meta: meta,
                                  child: Text(''),
                                );
                              },
                            ),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
          ListTile(
            title: Text(
              'Daily Logs',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: Text('View All', style: TextStyle(fontSize: 12)),
          ),
          StreamBuilder<List<UploadModel>>(
            stream: _uploadsStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              final uploads = snapshot.data!;

              return Column(
                children: [
                  ...List.generate(
                    uploads.length,
                    (index) {
                      final upload = uploads[index];
                      return Container(
                        height: MediaQuery.sizeOf(context).height * 0.1,
                        width: MediaQuery.sizeOf(context).width,
                        margin: EdgeInsets.only(bottom: 10.0),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.inversePrimary,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          leading: Icon(Icons.speed),
                          title: Text('PMS 2.5'),
                          subtitle: Text(
                            upload.timestamp != null
                                ? '${upload.timestamp!.hour}:${upload.timestamp!.minute}, ${upload.timestamp!.day} ${_getMonth(upload.timestamp!.month)} ${upload.timestamp!.year}'
                                : 'No timestamp',
                          ),
                          trailing: Text(
                            '${upload.pms.toStringAsFixed(1)} µg/m³',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  )
                ],
              );
            },
          )
        ],
      ),
    );
  }

  String _getMonth(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }
}
