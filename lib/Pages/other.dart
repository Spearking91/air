import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AQIPage(),
    );
  }
}

class AQIPage extends StatefulWidget {
  @override
  _AQIPageState createState() => _AQIPageState();
}

class _AQIPageState extends State<AQIPage> {
  final TextEditingController _controller = TextEditingController();
  double pm25 = 0.0;
  num aqi = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void updateAQI(double value) {
    setState(() {
      pm25 = value;
      aqi = calculateAQI(pm25).round(); // Round the AQI to whole number
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PM2.5 to AQI Calculator'),
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Enter PM2.5 concentration (µg/m³):',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                hintText: 'Enter PM2.5 value',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                updateAQI(double.tryParse(value) ?? 0.0);
              },
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'AQI: $aqi',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Air Quality: ${getAirQualityDescription(aqi.toInt())}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: getAQIColor(aqi.toInt()),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color getAQIColor(int aqi) {
    if (aqi <= 50) return Colors.green;
    if (aqi <= 100) return Colors.yellow;
    if (aqi <= 150) return Colors.orange;
    if (aqi <= 200) return Colors.red;
    if (aqi <= 300) return Colors.purple;
    return Colors.pink;
  }

  String getAirQualityDescription(int aqi) {
    if (aqi <= 50) {
      return 'Good';
    } else if (aqi <= 100) {
      return 'Moderate';
    } else if (aqi <= 150) {
      return 'Unhealthy for sensitive groups';
    } else if (aqi <= 200) {
      return 'Unhealthy';
    } else if (aqi <= 300) {
      return 'Very Unhealthy';
    } else {
      return 'Hazardous';
    }
  }
}

num calculateAQI(double pm25) {
  List<Map<String, double>> breakpoints = [
    {'low': 0, 'high': 12.0, 'lowAQI': 0, 'highAQI': 50},
    {'low': 12.1, 'high': 35.4, 'lowAQI': 51, 'highAQI': 100},
    {'low': 35.5, 'high': 55.4, 'lowAQI': 101, 'highAQI': 150},
    {'low': 55.5, 'high': 150.4, 'lowAQI': 151, 'highAQI': 200},
    {'low': 150.5, 'high': 250.4, 'lowAQI': 201, 'highAQI': 300},
    {'low': 250.5, 'high': 500.4, 'lowAQI': 301, 'highAQI': 500},
  ];

  for (var range in breakpoints) {
    if (pm25 >= range['low']! && pm25 <= range['high']!) {
      return ((pm25 - range['low']!) / (range['high']! - range['low']!)) *
              (range['highAQI']! - range['lowAQI']!) +
          range['lowAQI']!.round();
    }
  }

  return 0;
}
