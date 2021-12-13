import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../internals/indicator.dart';

class StatsPieChart extends StatefulWidget {
  const StatsPieChart({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => StatsPieChartState();
}

class StatsPieChartState extends State {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 30, top: 180, bottom: 10, right: 10),
      // color: Colors.white,

      child: Column(
        children: [
          Expanded(
            flex: 2,
            child: Stack(
              children: [
                Row(
                  children: <Widget>[
                    Expanded(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: PieChart(
                          PieChartData(
                              pieTouchData: PieTouchData(touchCallback:
                                  (FlTouchEvent event, pieTouchResponse) {
                                setState(() {
                                  if (!event.isInterestedForInteractions ||
                                      pieTouchResponse == null ||
                                      pieTouchResponse.touchedSection == null) {
                                    touchedIndex = -1;
                                    return;
                                  }
                                  touchedIndex = pieTouchResponse
                                      .touchedSection!.touchedSectionIndex;
                                });
                              }),
                              borderData: FlBorderData(
                                show: false,
                              ),
                              sectionsSpace: 0,
                              centerSpaceRadius: 140,
                              sections: showingSections()),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 18,
                    ),
                  ],
                ),
                Positioned(
                  left: 95.0,
                  top: 100.0,
                  child: Container(
                    // color: Colors.white,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          child: const Text(
                            'Total Games',
                            style: TextStyle(
                                color: Colors.amberAccent, fontSize: 25),
                          ),
                        ),
                        const Text(
                          "40",
                          style: TextStyle(
                              color: Colors.amberAccent,
                              fontSize: 50,
                              fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const <Widget>[
                  Indicator(
                    color: Color.fromRGBO(50, 205, 50, 1),
                    text: 'Won',
                    isSquare: true,
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Indicator(
                    color: Color.fromRGBO(159, 0, 0, 1),
                    text: 'Lost',
                    isSquare: true,
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Indicator(
                    color: Color.fromRGBO(178, 190, 181, 1),
                    text: 'Draw',
                    isSquare: true,
                  ),
                  SizedBox(
                    height: 18,
                  ),
                ],
              ),
              Image.asset(
                'graphics/horse.png',
                width: MediaQuery.of(context).size.width * 0.22,
              )
            ],
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(3, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 60.0 : 50.0;
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: const Color.fromRGBO(50, 205, 50, 1),
            value: 40,
            title: '40%',
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xffffffff)),
          );
        case 1:
          return PieChartSectionData(
            color: const Color.fromRGBO(159, 0, 0, 1),
            value: 30,
            title: '30%',
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xffffffff)),
          );
        case 2:
          return PieChartSectionData(
            color: const Color.fromRGBO(178, 190, 181, 1),
            value: 30,
            title: '30%',
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xffffffff)),
          );

        default:
          throw Error();
      }
    });
  }
}
