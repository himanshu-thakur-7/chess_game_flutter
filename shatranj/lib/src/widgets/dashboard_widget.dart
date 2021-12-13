import 'package:chess_ui/src/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DashboardWidget extends StatelessWidget {
  const DashboardWidget({
    Key? key,
    required this.widget,
    required this.onTap,
    required this.backColor,
    required this.imgURL,
    required this.title,
    required this.flexVal,
    required this.imgScale,
  }) : super(key: key);

  final HomeScreen widget;
  final Function? onTap;
  final Color? backColor;
  final String? title;
  final String? imgURL;
  final int flexVal;
  final double imgScale;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flexVal,
      child: InkWell(
        onTap: () {
          onTap!();
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: backColor!,
            border: Border.all(),
            borderRadius: BorderRadius.circular(18),
          ),
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title!,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(35, 16, 2, 2),
                child: (title != "Chess Lessons")
                    ? Image.asset(
                        imgURL!,
                        fit: BoxFit.contain,
                        width: MediaQuery.of(context).size.width * imgScale,
                      )
                    : SvgPicture.asset(
                        imgURL!,
                        width: MediaQuery.of(context).size.width * imgScale,
                      ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
