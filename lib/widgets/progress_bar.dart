import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class first {
  static const beginColor = Colors.lime;
  static const endColor = Color.fromARGB(255, 5, 82, 4);
}

class second {
  static const beginColor = Color.fromARGB(255, 57, 204, 220);
  static const endColor = Color.fromARGB(255, 4, 22, 82);
}

class third {
  static const beginColor = Color.fromARGB(255, 220, 187, 57);
  static const endColor = Color.fromARGB(255, 82, 21, 4);
}

class ProgressBar extends StatelessWidget {
  const ProgressBar({super.key, required this.value, this.title, this.header});

  final double value;
  final String? title;
  final bool? header;

  @override
  Widget build(BuildContext context) {
    LinearGradient customGradient;
    if (title == 'PMS 1.0') {
      customGradient = LinearGradient(
        colors: [first.beginColor, first.endColor],
      );
    } else if (title == 'PMS 10') {
      customGradient = LinearGradient(
        colors: [second.beginColor, second.endColor],
      );
    } else if (title == 'PMS 2.5') {
      customGradient = LinearGradient(
        colors: [third.beginColor, third.endColor],
      );
    } else {
      // Default gradient if the title doesn't match any known case
      customGradient = LinearGradient(
        colors: [Colors.grey, Colors.black],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 10.0, right: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title!),
              Text(
                '${(value / 300 * 100).round()}%',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          ),
        ),
        LinearPercentIndicator(
            width: MediaQuery.of(context).size.width * 0.8,
            animation: true,
            lineHeight: 10.0,
            animationDuration: 2000,
            percent: value / 300.0,
            barRadius: Radius.elliptical(10, 20),
            linearGradient: customGradient),
      ],
    );
  }
}
