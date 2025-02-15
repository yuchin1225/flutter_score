import 'package:flutter/material.dart';
import 'dart:async';

class MyDialog extends StatefulWidget {
  @override
  State<MyDialog> createState() => _MyDialogState();
}

class _MyDialogState extends State<MyDialog> {
  int _secondsRemaining = 3;
  late Timer? _timer;

  @override
  void initState() {
    super.initState();
    // 啟動定時器
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          // 關閉對話框
          Navigator.of(context).pop();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // 取消定時器
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Image(
              image: AssetImage("images/logo.jpg"),
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 15.0),
            Text(
              "感謝您的回饋， ${_secondsRemaining.toString()} 秒後返回。",
              style: TextStyle(fontSize: 20.0),
            )
          ],
        ),
      ),
    );
  }
}
