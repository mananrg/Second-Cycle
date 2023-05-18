import 'package:flutter/material.dart';


class RoundedButton extends StatelessWidget {
  String text;
  final VoidCallback press;
  final Color color, textColor;
  RoundedButton({
    Key? key,
    required this.text,
    required this.press,
    this.color = const Color(0xFF266AFE),
    this.textColor = Colors.white,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    print(text);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      width: size.width * 0.8,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(29),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
          ),
          onPressed: press,
          child: Text(
            text,
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
