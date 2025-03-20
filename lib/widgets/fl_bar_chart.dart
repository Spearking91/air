import 'dart:async';
import 'package:air/models/upload.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart'; // Add this import
import '../services/services.dart';

class FlBarChart extends StatefulWidget {
  const FlBarChart({super.key});

  @override
  State<FlBarChart> createState() => _FlBarChartState();
}

class _FlBarChartState extends State<FlBarChart> {
  late Timer _timer;
  late Future<UploadModel> reading;
  List<FlSpot> dataPoints = [];
  List<DateTime> timeStamps = []; // Add this list to store timestamps

  @override
  void initState() {
    super.initState();
    reading = FirebaseDatabaseMethods.getDataAsFuture();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      setState(() {
        reading = FirebaseDatabaseMethods.getDataAsFuture();
      });
    });
  }

  String _getTimeString(double value) {
    if (value.toInt() >= 0 && value.toInt() < timeStamps.length) {
      return DateFormat('HH:mm:ss').format(timeStamps[value.toInt()]);
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FlBarChart'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<UploadModel>(
              stream: FirebaseDatabaseMethods.getDataAsStream(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  // Add new data point with current timestamp
                  if (dataPoints.length > 20) {
                    dataPoints.removeAt(0);
                    timeStamps.removeAt(0);
                  }
                  timeStamps.add(DateTime.now());
                  dataPoints.add(FlSpot((dataPoints.length).toDouble(),
                      snapshot.data?.pms.toDouble() ?? 0));

                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: LineChart(
                      LineChartData(
                        minY: 0,
                        maxY: 1000,
                        minX: 0,
                        maxX: 20,
                        lineBarsData: [
                          LineChartBarData(
                            spots: dataPoints,
                            isCurved: true,
                            gradient: const LinearGradient(
                              colors: [Colors.blue, Colors.green],
                            ),
                            barWidth: 3,
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                colors: [
                                  Colors.blue.withValues(alpha: 0.3),
                                  Colors.green.withValues(alpha: 0.3),
                                ],
                              ),
                            ),
                            dotData: const FlDotData(show: false),
                          ),
                        ],
                        gridData: const FlGridData(show: true),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 5),
                                  child: Transform.rotate(
                                    angle:
                                        -0.5, // Rotate labels for better readability
                                    child: Text(
                                      _getTimeString(value),
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                  ),
                                );
                              },
                              reservedSize: 35,
                              interval: 5, // Show every 5th timestamp
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return Text(value.toInt().toString());
                              },
                              reservedSize: 40,
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
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text(snapshot.error.toString()));
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Current PMS Value: ${dataPoints.isNotEmpty ? dataPoints.last.y.toStringAsFixed(2) : "0"}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
