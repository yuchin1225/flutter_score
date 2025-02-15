import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'sqlite.dart';
import 'drawer.dart';
import 'dialog.dart';

const List<Map<String, dynamic>> scores = [
  {"icons": "images/no.jpg", "value": 0},
  {"icons": "images/yes.jpg", "value": 1},
];

class Score extends StatefulWidget {
  @override
  State<Score> createState() => _ScoreState();
}

class _ScoreState extends State<Score> {
  final TextEditingController _passwordController = TextEditingController();

  void _ratingChanged(int index) {
    DBHelper().insertDb(index);
    showDialog(
      context: context,
      barrierDismissible: false, // 防止點擊對話框外部關閉
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => Future.value(false), // 防止按返回鍵關閉
          child: MyDialog(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: WillPopScope(
          //強制取消返回
          onWillPop: () async => Future.value(false),
          child: Container(
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("images/background.png"),
                      fit: BoxFit.fill)),
              width: 4000,
              height: 2500,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                      top: MediaQuery.of(context).size.height * 0.1912,
                      left: MediaQuery.of(context).size.width * 0.1095,
                      child: Image(
                        image: const AssetImage("images/title.png"),
                        fit: BoxFit.fill,
                        width: MediaQuery.of(context).size.width * 0.626,
                      )),
                  // Icons List
                  ...List.generate(scores.length, (index) {
                    double top = MediaQuery.of(context).size.height * 0.5088;
                    double left = MediaQuery.of(context).size.width *
                        (index == 0 ? 0.11275 : 0.38225); // Dynamic position
                    return Positioned(
                      top: top,
                      left: left,
                      child: IconButton(
                        splashRadius: 200,
                        icon: Image.asset(
                          scores[index]["icons"],
                          fit: BoxFit.fill,
                          width: MediaQuery.of(context).size.width * 0.15725,
                        ),
                        onPressed: () => _ratingChanged(scores[index]["value"]),
                      ),
                    );
                  }),
                  Positioned(
                      top: MediaQuery.of(context).size.height * 0.7968,
                      left: MediaQuery.of(context).size.width * 0.781,
                      child: IconButton(
                          icon: Image(
                            image: const AssetImage("images/logo.jpg"),
                            fit: BoxFit.fill,
                            width: MediaQuery.of(context).size.width * 0.15525,
                          ),
                          onPressed: () => {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text("請輸入密碼"),
                                      content: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            TextFormField(
                                              obscureText: true,
                                              enableSuggestions: false,
                                              autocorrect: false,
                                              controller: _passwordController,
                                              decoration: const InputDecoration(
                                                labelText: "密碼",
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                            onPressed: () {
                                              if (_passwordController.text ==
                                                  "123456789") {
                                                Navigator.pushNamed(
                                                    context, "/report");
                                              } else {
                                                Navigator.of(context).pop();
                                              }
                                              setState(() {
                                                _passwordController.clear();
                                              });
                                            },
                                            child: const Text("確認"))
                                      ],
                                    );
                                  },
                                )
                              })),
                ],
              )),
        ));
  }
}
