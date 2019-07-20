import 'dart:async';

import 'package:flutter/material.dart';
import 'package:like_wechat_input/const/resource.dart';
import 'package:like_wechat_input/widget/image_button.dart';
import 'dart:ui' as ui;

typedef void OnSend(String text);

ChatType _initType = ChatType.text;

double _softKeyHeight = 200;

class InputWidget extends StatefulWidget {
  final TextEditingController controller;
  final Widget extraWidget;
  final Widget emojiWidget;
  final Widget voiceWidget;
  final OnSend onSend;

  const InputWidget({
    Key key,
    @required this.controller,
    this.extraWidget,
    this.emojiWidget,
    this.voiceWidget,
    this.onSend,
  }) : super(key: key);

  @override
  InputWidgetState createState() => InputWidgetState();
}

class InputWidgetState extends State<InputWidget>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  ChatType currentType = _initType;

  FocusNode focusNode = FocusNode();

  StreamController<String> inputContentStreamController = StreamController();

  Stream<String> get inputContentStream => inputContentStreamController.stream;

  AnimationController _bottomHeightController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    focusNode.addListener(onFocus);
    widget.controller.addListener(_onInputChange);
    _bottomHeightController = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 250,
      ),
    );
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
      // setState(() {});
    }
  }

  void onFocus() {
    print("onFocuse");
    if (focusNode.hasFocus) {
      updateState(ChatType.text);
    }
  }

  void _onInputChange() {
    inputContentStreamController.add(widget.controller.text);
  }

  @override
  void dispose() {
    _bottomHeightController.dispose();
    inputContentStreamController.close();
    widget.controller.removeListener(_onInputChange);
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
              buildRightButton(),
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

  Widget buildRightButton() {
    return StreamBuilder<String>(
      stream: inputContentStream,
      builder: (context, snapshot) {
        bool showSend() {
          if (currentType == ChatType.voice) {
            return false;
          }
          if (snapshot.hasData && snapshot.data.trim().isNotEmpty) {
            return true;
          }
          return false;
        }

        if (showSend()) {
          return RaisedButton(
            child: Text("发送"),
            onPressed: () => widget.onSend?.call(snapshot.data.trim()),
          );
        }
        return ImageButton(
          image: AssetImage(R.ASSET_ADD_PNG),
          onPressed: () => updateState(ChatType.extra),
        );
      },
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
    final voiceButton = widget.voiceWidget ?? buildVoiceButton(context);
    final inputButton = TextField(
      focusNode: focusNode,
      controller: widget.controller,
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

  void changeBottomHeight(final double height) {
    if (height > 0) {
      _bottomHeightController.animateTo(1);
    } else {
      _bottomHeightController.animateBack(0);
    }
  }

  Future<void> updateState(ChatType type) async {
    if (type == ChatType.text || type == ChatType.voice) {
      _initType = type;
    }
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

    if (type == ChatType.emoji || type == ChatType.extra) {
      // _currentOtherHeight = _softKeyHeight;
      changeBottomHeight(1);
    } else {
      changeBottomHeight(0);
      // _currentOtherHeight = 0;
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
    return SizeTransition(
      sizeFactor: _bottomHeightController,
      child: Container(
        child: child,
        height: _softKeyHeight,
      ),
      // animation: _bottomHeightController,
      // builder: (ctx,),
      // height: _currentOtherHeight,
      // duration: Duration(milliseconds: needAnim ? 150 : 0),
      // child: child,
    );
  }

  Widget _buildBottomItems() {
    if (this.currentType == ChatType.extra) {
      return widget.extraWidget ?? Center(child: Text("其他item"));
    } else if (this.currentType == ChatType.emoji) {
      return widget.emojiWidget ?? Center(child: Text("表情item"));
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
  extra,
}

class ChangeChatTypeNotification extends Notification {
  final ChatType type;

  ChangeChatTypeNotification(this.type);
}
