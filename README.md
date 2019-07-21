# like_wechat_input

仿微信输入框

无具体逻辑, 不会录音, 没有 emoji,加号里并没有真实的"其他"功能  
无具体逻辑, 不会录音, 没有 emoji,加号里并没有真实的"其他"功能  
无具体逻辑, 不会录音, 没有 emoji,加号里并没有真实的"其他"功能  
无具体逻辑, 不会录音, 没有 emoji,加号里并没有真实的"其他"功能  

## 截图

![gif](https://raw.githubusercontent.com/kikt-blog/image/master/github/like_wechat_input_2.gif)

## 简易使用说明

自行跑下代码和查看源码是最好的说明, 说明永远没有源码清晰

查看 InputWidget 的参数

1. "按住发生"按钮并无实际业务逻辑(并不会录音), 请自行填充, 使用 voiceWidget 选项
2. 支持自行配置点击 emoji 按钮时底部弹出的 Widget 内容, 使用 emojiWidget
3. 支持自行配置点击"加号"按钮时底部弹出的 Widget 内容, 可以使用`ExtraItemContainer`作为外部容器, 这个容器会自动分页, 每页 8 个按钮

因为只是一个 UI 示例, 不写插件了, 想用的可以 copy 源码和 asset 然后根据自己的需要来封装一个自己的聊天 widget

## 开源协议

使用 APACHE-2.0 协议开源

如果有转载或使用,请注明来源和作者名称
