import 'package:flutter/material.dart';
import '../widgets/piechart.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color.fromRGBO(34, 0, 53, 1.0),
      body: Center(child: StatsPieChart()),
    );
  }
}
