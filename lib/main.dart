import 'package:flutter/material.dart';

import 'widget/default_extra_item.dart';
import 'widget/input_widget.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ChatType currentType;

  TextEditingController ctl = TextEditingController();

  @override
  void initState() {
    super.initState();
    ctl.addListener(onValueChange);
  }

  void dispose() {
    ctl.removeListener(onValueChange);
    ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ChangeChatTypeNotification>(
      onNotification: _onChange,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: Center(
                child: Text(this.currentType.toString()),
              ),
            ),
            InputWidget(
              controller: ctl,
              extraWidget: DefaultExtraWidget(),
              onSend: (value){
                print("send text $value");
              },
            ),
          ],
        ),
      ),
    );
  }

  void onValueChange() {
    print(ctl.text);
  }

  bool _onChange(ChangeChatTypeNotification notification) {
    setState(() {
      this.currentType = notification.type;
    });
    return true;
  }
}
