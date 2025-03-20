import 'package:air/widgets/progress_bar.dart';
import 'package:flutter/material.dart';

class ChartsPage extends StatelessWidget {
  const ChartsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: MediaQuery.sizeOf(context).width,
        // height: MediaQuery.sizeOf(context).height * 0.1,
        margin: EdgeInsets.only(top: 16),
        decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color.fromARGB(255, 39, 147, 115),
                const Color.fromARGB(255, 32, 69, 33),
              ],
            ),
            borderRadius: BorderRadius.circular(10)),
        child: Column(
          children: [
            ListTile(
              subtitle: Text(
                'Highest reading for the month',
                style: TextStyle(color: Colors.white60),
              ),
              title: Text(
                '7th January, 2025',
                style: TextStyle(color: Colors.white),
              ),
              leading: Icon(
                Icons.calendar_today,
                color: Colors.white60,
              ),
            ),
            ProgressBar(
              value: 0.9,
              title: 'Lowest',
            )
          ],
        ),
      ),
    );
  }
}
