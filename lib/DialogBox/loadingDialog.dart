import 'package:flutter/material.dart';
import '../Widgets/loadingWidget.dart';

class LoadingAlertDialog extends StatelessWidget {
  const LoadingAlertDialog({Key? key, required this.message}) : super(key: key);
  final String message;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      key: key,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          circularProgress(),
          const SizedBox(height: 10),
          Text(message),
        ],
      ),
    );
  }
}