import 'package:flutter/material.dart';

import 'extra_item_container.dart';

class DefaultExtraWidget extends StatefulWidget {
  @override
  _DefaultExtraWidgetState createState() => _DefaultExtraWidgetState();
}

class _DefaultExtraWidgetState extends State<DefaultExtraWidget> {
  @override
  Widget build(BuildContext context) {
    return ExtraItemContainer(
      items: [
        createitem(),
        createitem(),
        createitem(),
        createitem(),
        createitem(),
        createitem(),
        createitem(),
        createitem(),
        createitem(),
      ],
    );
  }

  ExtraItem createitem() => DefaultExtraItem(
        icon: Icon(Icons.add),
        text: "添加",
        onPressed: () {
          print("添加");
        },
      );
}
