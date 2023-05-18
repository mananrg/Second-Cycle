import 'package:flutter/material.dart';
import 'package:resell_app/Widgets/text_field_container.dart';



class RoundedInputField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final ValueChanged<String> onChanged;
  const RoundedInputField({
    Key? key,
    required this.hintText,
    this.icon = Icons.person,
    required this.onChanged,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      cursorColor: const Color(0xFF266AFE),
      decoration: InputDecoration(
        hintText: hintText,
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            width: 2, //<-- SEE HERE
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}
