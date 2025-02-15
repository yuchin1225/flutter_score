import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  final List<String> drawerText = ["首頁", "報表資料"];
  final List<String> drawerRoute = ["/", "/report"];
  final Map<String, IconData> drawerMap = {
    "首頁": Icons.home,
    "報表資料": Icons.table_chart,
  };

  MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          const DrawerHeader(
            padding: EdgeInsets.fromLTRB(18.0, 0, 18.0, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image(
                  image: AssetImage("images/logo.jpg"),
                  fit: BoxFit.cover,
                )
              ],
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18.0, 0, 18.0, 0),
              child: Column(
                children: List<Widget>.generate(
                  drawerText.length,
                  (index) => Container(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () {
                        // Your navigation logic here
                        Navigator.pushNamed(context, drawerRoute[index]);
                      },
                      icon: Icon(drawerMap[drawerText[index]]),
                      label: Text(drawerText[index]),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
