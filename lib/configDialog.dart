import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

class ConfigInfo {
  String listingBy;
  double fontSize;

  ConfigInfo(this.listingBy, this.fontSize);
}

Future<ConfigInfo> showConfigurationDialog(
    BuildContext context, String listingBy, double fontSize) async {
  await showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title: const Text('設定', textAlign: TextAlign.center),
          content: SingleChildScrollView(
              child: Column(children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const Text("字體大小"),
                    Flexible(
                        child: NumberPicker(
                          value: fontSize.toInt(),
                          minValue: 14,
                          maxValue: 40,
                          step: 1,
                          haptics: true,
                          onChanged: (value) =>
                              setState(() => fontSize = value.toDouble()),
                        ))
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const Text("排列"),
                    Flexible(
                        child: DropdownButton<String>(
                            value: listingBy,
                            icon: const Icon(Icons.arrow_downward),
                            elevation: 16,
                            style: const TextStyle(color: Colors.deepPurple),
                            underline: Container(
                              height: 2,
                              color: Colors.deepPurpleAccent,
                            ),
                            onChanged: (String? newValue) {
                              setState(() {
                                listingBy = newValue!;
                              });
                            },
                            items: <String>[
                              "詩體", "作者", "詩題","我的心愛"
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList()))
                  ],
                ),
              ])),
          actions: <Widget>[

            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              TextButton(
                  child: const Text('確定'),
                  onPressed: () {
                    Navigator.pop(context, '確定');
                  }),
              TextButton(
                onPressed: () => Navigator.pop(context, '取消'),
                child: const Text('取消'),
              )
            ])
          ],
        );
      });
    },
  );
  return ConfigInfo(listingBy, fontSize);
}