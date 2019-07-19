import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:like_wechat_input/const/resource.dart';
import 'package:like_wechat_input/widget/image_button.dart';
import 'dart:ui' as ui;

ChatType _initType = ChatType.text;

double _softKeyHeight = 200;

class InputWidget extends StatefulWidget {
  final TextEditingController controller;
  final List<Widget> otherItems;

  const InputWidget({
    Key key,
    this.controller,
    this.otherItems = const <Widget>[],
  }) : super(key: key);

  @override
  InputWidgetState createState() => InputWidgetState();
}

class InputWidgetState extends State<InputWidget> with WidgetsBindingObserver {
  ChatType currentType = _initType;

  double _currentOtherHeight = 0;

  FocusNode focusNode = FocusNode();

  bool needAnim = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    focusNode.addListener(onFocus);
  }

  @override
  void didChangeMetrics() {
    final mediaQueryData = MediaQueryData.fromWindow(ui.window);
    final keyHeight = mediaQueryData?.viewInsets?.bottom;
    if (keyHeight != 0) {
      _softKeyHeight = keyHeight;
      print("current type = $currentType");
      // updateState(ChatType.text);
    } else {
      setState(() {});
    }
  }

  void onFocus() {
    if (focusNode.hasFocus) {
      needAnim = false;
      updateState(ChatType.text);
      Future.delayed(const Duration(milliseconds: 100), () {
        needAnim = true;
      });
    }
  }

  @override
  void dispose() {
    focusNode.removeListener(onFocus);
    focusNode.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.withOpacity(0.4),
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              buildLeftButton(),
              Expanded(child: buildInputButton()),
              buildEmojiButton(),
              buildOtherButton(),
            ],
          ),
          _buildBottomContainer(child: _buildBottomItems()),
        ],
      ),
    );
  }

  Widget buildLeftButton() {
    return ImageButton(
      onPressed: () {
        if (currentType == ChatType.voice) {
          updateState(ChatType.text);
        } else {
          updateState(ChatType.voice);
        }
      },
      image: AssetImage(
        currentType != ChatType.voice
            ? R.ASSET_VOICE_PNG
            : R.ASSET_KEYBOARD_PNG,
      ),
    );
  }

  Widget buildOtherButton() {
    return ImageButton(
      image: AssetImage(R.ASSET_ADD_PNG),
      onPressed: () => updateState(ChatType.other),
    );
  }

  Widget buildEmojiButton() {
    return ImageButton(
      image: AssetImage(currentType != ChatType.emoji
          ? R.ASSET_EMOJI_PNG
          : R.ASSET_KEYBOARD_PNG),
      onPressed: () {
        if (currentType != ChatType.emoji) {
          updateState(ChatType.emoji);
        } else {
          updateState(ChatType.text);
        }
      },
    );
  }

  Widget buildInputButton() {
    final voiceButton = buildVoiceButton(context);
    final inputButton = TextField(
      focusNode: focusNode,
      decoration: InputDecoration(
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(10),
        border: OutlineInputBorder(),
      ),
    );

    return Stack(
      children: <Widget>[
        Offstage(
          child: voiceButton,
          offstage: currentType != ChatType.voice,
        ),
        Offstage(
          child: inputButton,
          offstage: currentType == ChatType.voice,
        ),
      ],
    );
  }

  Future<void> updateState(ChatType type) async {
    if (type == currentType) {
      return;
    }
    this.currentType = type;
    ChangeChatTypeNotification(type).dispatch(context);

    if (type != ChatType.text) {
      hideSoftKey();
    } else {
      showSoftKey();
    }

    if (type == ChatType.emoji || type == ChatType.other) {
      _currentOtherHeight = _softKeyHeight;
    } else {
      _currentOtherHeight = 0;
    }

    setState(() {});
  }

  void showSoftKey() {
    FocusScope.of(context).requestFocus(focusNode);
  }

  void hideSoftKey() {
    focusNode.unfocus();
  }

  Widget _buildBottomContainer({Widget child}) {
    return AnimatedContainer(
      height: _currentOtherHeight,
      duration: Duration(milliseconds: needAnim ? 150 : 0),
      child: child,
    );
  }

  Widget _buildBottomItems() {
    if (this.currentType == ChatType.other) {
      return GridView(
        shrinkWrap: true,
        children: widget.otherItems,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
        ),
      );
    } else {
      return Container();
    }
  }
}

Widget buildVoiceButton(BuildContext context) {
  return Container(
    width: double.infinity,
    child: RaisedButton(
      onPressed: () {
        print("连接");
      },
      child: Text("按住发声"),
    ),
  );
}

enum ChatType {
  text,
  voice,
  emoji,
  other,
}

class ChangeChatTypeNotification extends Notification {
  final ChatType type;

  ChangeChatTypeNotification(this.type);
}
