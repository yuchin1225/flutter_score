// ignore_for_file: use_build_context_synchronously
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
//syncfusion_flutter_charts 圖表
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';

//excel
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as Flutter_xlsio;
import 'package:path_provider/path_provider.dart' as path_provider;
import 'sqlite.dart';
import 'drawer.dart';

class Report extends StatefulWidget {
  @override
  State<Report> createState() => _ReportState();
}

class _ReportState extends State<Report> {
  DateTime? _startDate;
  DateTime? _endDate;
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  bool _focus = false; //是否點擊輸入框
  List<Map<String, dynamic>> _rows = [];
  int _yes = 0;
  int _no = 0;
  int _total = 0;
  String _yesRate = "";
  String _noRate = "";

  //圖表資料
  List<ChartData> _chartData = [];

  Future<bool> _requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      return result.isGranted;
    }
  }

  void _handleDownload(BuildContext context) async {
    // 獲取權限
    Permission? permission;
    // 獲取下載目錄
    Directory? directory;
    if (Platform.isAndroid) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      //獲取 sdk 版本
      int sdk = androidInfo.version.sdkInt;
      //Android 11 或以上
      if (sdk >= 30) {
        permission = Permission.manageExternalStorage;
      } else {
        //Android 10 或以下
        permission = Permission.storage;
      }

      if (await _requestPermission(permission)) {
        // 下載目錄
        directory = Directory('/storage/emulated/0/Download');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('未獲得儲存權限')),
        );
      }
    } else if (Platform.isIOS) {
      directory = await path_provider.getApplicationDocumentsDirectory();
    }

    // 創建 Excel
    final Flutter_xlsio.Workbook workbook = Flutter_xlsio.Workbook();
    final Flutter_xlsio.Worksheet sheet = workbook.worksheets[0];

    // 設置列寬
    sheet.getRangeByName('A1').columnWidth = 12.00;
    sheet.getRangeByName('B1').columnWidth = 12.00;
    sheet.getRangeByName('C1').columnWidth = 30.00;

    // 設置標題
    sheet.getRangeByName('A1').setText('id');
    sheet.getRangeByName('B1').setText('answer');
    sheet.getRangeByName('C1').setText('time');

    // 寫入資料
    for (int i = 0; i < _rows.length; i++) {
      sheet.getRangeByIndex(i + 2, 1).setText(_rows[i]['id'].toString());
      sheet
          .getRangeByIndex(i + 2, 2)
          .setText(_rows[i]['score'] == 1 ? "有" : "沒有");
      sheet.getRangeByIndex(i + 2, 3).setText(_rows[i]['datetime'].toString());
    }

    // 保存 Excel 文件
    List<int> bytes = workbook.saveAsStream();
    workbook.dispose();
    if (directory != null) {
      final String path = directory.path;
      final String fileName =
          'output_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      final File file = File('$path/$fileName');
      // 寫入文件
      await file.writeAsBytes(bytes);

      // 顯示成功消息
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Excel 文件已保存到: ${file.path}')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('無法獲取下載目錄')),
      );
    }
  }

  void _handleQuery() async {
    if (_startDateController.text != "" && _endDateController.text != "") {
      // 查詢時間
      List<Map<String, dynamic>> data = await DBHelper()
          .queryTimeDb(_startDateController.text, _endDateController.text);

      setState(() {
        _focus = false;
      });

      if (data.isEmpty) {
        setState(() {
          _rows = [];
          _yes = 0;
          _no = 0;
          _total = 0;
          _yesRate = "";
          _noRate = "";
          _chartData = [];
        });
        showDialog(
          // ignore: use_build_context_synchronously
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Icon(size: 36.0, Icons.error),
                ),
                Text("訊息")
              ],
            ),
            content: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Text("查無資料。")],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("確認")),
            ],
          ),
        );
      } else {
        setState(() {
          // 更新表格資料
          _rows = data;

          for (var row in _rows) {
            if (row['score'] == 0) {
              _no++;
            } else if (row['score'] == 1) {
              _yes++;
            }
          }
          _total = _yes + _no;
          _yesRate = (_yes / _total * 100).toStringAsFixed(2) + "%";
          _noRate = (_no / _total * 100).toStringAsFixed(2) + "%";
          _chartData = [
            ChartData("有", _yes, _yesRate),
            ChartData("沒有", _no, _noRate),
          ];
        });
      }
      // 更新页面显示
    }
  }

  @override
  void initState() {
    super.initState();
    _startDateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _endDateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("歷史報表"),
        ),
        drawer: MyDrawer(),
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _startDateController,
                decoration: const InputDecoration(
                  labelText: "開始時間",
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () {
                  setState(() {
                    _focus = true;
                  });
                  showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  ).then((selectedDate) {
                    if (selectedDate != null) {
                      setState(() {
                        _startDate = selectedDate;
                        _startDateController.text =
                            DateFormat('yyyy-MM-dd').format(selectedDate);
                      });
                    }
                  });
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _endDateController,
                decoration: const InputDecoration(
                  labelText: "結束時間",
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () {
                  setState(() {
                    _focus = true;
                  });
                  showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  ).then((selectedDate) {
                    if (selectedDate != null) {
                      setState(() {
                        _endDate = selectedDate;
                        _endDateController.text =
                            DateFormat('yyyy-MM-dd').format(selectedDate);
                      });
                    }
                  });
                },
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _handleQuery,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Icon(Icons.search), Text('查詢')],
                ),
              ),
              const SizedBox(height: 8.0),
              if (!_rows.isEmpty && !_focus)
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                        ElevatedButton(
                            onPressed: () => _handleDownload(context),
                            child: const Icon(Icons.download_rounded)),
                      ]),
                      const SizedBox(height: 4.0),
                      DataTable(
                        columns: const [
                          DataColumn(
                              label: Text('有',
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                  ))),
                          DataColumn(
                              label: Text('沒有',
                                  style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('總計',
                                  style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold))),
                        ],
                        rows: [
                          DataRow(cells: [
                            DataCell(Text(_yes.toString())),
                            DataCell(Text(_no.toString())),
                            DataCell(Text(_total.toString())),
                          ]),
                        ],
                      ),
                      Container(
                        height: 200.0,
                        child: SfCircularChart(
                            margin: const EdgeInsets.all(8.0),
                            legend: const Legend(
                                isVisible: true, position: LegendPosition.left),
                            series: <CircularSeries<ChartData, String>>[
                              PieSeries<ChartData, String>(
                                dataSource: _chartData,
                                xValueMapper: (ChartData data, _) => data.text,
                                yValueMapper: (ChartData data, _) => data.value,
                                dataLabelMapper: (ChartData data, _) =>
                                    data.rate,
                                dataLabelSettings:
                                    const DataLabelSettings(isVisible: true),
                              )
                            ]),
                      ),
                    ],
                  ),
                )
            ],
          ),
        ));
  }
}

class ChartData {
  ChartData(this.text, this.value, this.rate);
  final String text;
  final int value;
  final String rate;
}
