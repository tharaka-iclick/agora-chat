import 'package:flutter/material.dart';
import 'package:agora_chat_sdk/agora_chat_sdk.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class AgoraChatConfig {
  static const String appKey = "611319330#1521297";
  static const String userId = "tharaka";
  static const String agoraToken =
      "007eJxTYIj+/cbbU8Q8e4VP340jwVeFDxZuDrUK7NkkOVH1x5lU6ZsKDImJJpZGieYWhoamKSaWBokWBhZJJmlpFomGyaapxmbJaysepzcEMjJk9t5hZGRgZWAEQhBfhcHUwig5zdjcQNfA0ihJ19AwzUA30dDYQtfANDnRPNHczCAtMRkAqlooFg==";
}

final List<Map<String, dynamic>> _messages = [];

class User02 extends StatefulWidget {
  const User02({super.key});

  @override
  State<User02> createState() => _User02State();
}

class _User02State extends State<User02> {
  late ChatClient agoraChatClient;
  bool isJoined = false;

  ScrollController scrollController = ScrollController();
  TextEditingController messageBoxController = TextEditingController();
  String messageContent = "", recipientId = "";
  final List<Widget> messageList = [];

  String? _messageContent, _chatId;
  final List<String> _logText = [];

  showLog(String message) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void initState() {
    super.initState();
    _initSDK();
    _addChatListener();
  }

  void _initSDK() async {
    ChatOptions options = ChatOptions(
      appKey: AgoraChatConfig.appKey,
      autoLogin: false,
    );
    await ChatClient.getInstance.init(options);
    await ChatClient.getInstance.startCallback();

    _addLogToConsole("Agora Chat SDK Initialized");
  }

  void _addLogToConsole(String log) {
    _logText.add("$_timeString: $log");
    setState(() {
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      }
    });
  }

  String get _timeString {
    return DateTime.now().toString().split(".").first;
  }

  void _signIn() async {
    try {
      await ChatClient.getInstance.loginWithToken(
        AgoraChatConfig.userId,
        AgoraChatConfig.agoraToken,
      );
      _addLogToConsole("login succeed, userId: ${AgoraChatConfig.userId}");
    } on ChatError catch (e) {
      _addLogToConsole("login failed, code: ${e.code}, desc: ${e.description}");
    }
  }

  void _signOut() async {
    try {
      await ChatClient.getInstance.logout(true);
      _addLogToConsole("sign out succeed");
    } on ChatError catch (e) {
      _addLogToConsole(
        "sign out failed, code: ${e.code}, desc: ${e.description}",
      );
    }
  }

  void _sendMessage() async {
    if (_chatId == null || _messageContent == null) {
      _addLogToConsole("single chat id or message content is null");
      return;
    }

    setState(() {
      _messages.add({
        'text': _messageContent!,
        'isMe': true,
        'sender': AgoraChatConfig.userId,
      });
    });

    var msg = ChatMessage.createTxtSendMessage(
      targetId: _chatId!,
      content: _messageContent!,
    );

    ChatClient.getInstance.chatManager.sendMessage(msg);
  }

  void onMessagesReceived(List<ChatMessage> messages) {
    for (var msg in messages) {
      switch (msg.body.type) {
        case MessageType.TXT:
          {
            ChatTextMessageBody body = msg.body as ChatTextMessageBody;
            setState(() {
              _messages.add({
                'text': body.content,
                'isMe': false,
                'sender': msg.from,
              });
            });
            _addLogToConsole(
              "receive text message: ${body.content}, from: ${msg.from}",
            );
            print("receive text message: ${body.content}, from: ${msg.from}");
          }
          break;
        case MessageType.IMAGE:
          {
            _addLogToConsole("receive image message, from: ${msg.from}");
          }
          break;
        case MessageType.VIDEO:
          {
            _addLogToConsole("receive video message, from: ${msg.from}");
          }
          break;
        case MessageType.LOCATION:
          {
            _addLogToConsole("receive location message, from: ${msg.from}");
          }
          break;
        case MessageType.VOICE:
          {
            _addLogToConsole("receive voice message, from: ${msg.from}");
          }
          break;
        case MessageType.FILE:
          {
            _addLogToConsole("receive image message, from: ${msg.from}");
          }
          break;
        case MessageType.CUSTOM:
          {
            _addLogToConsole("receive custom message, from: ${msg.from}");
          }
          break;
        case MessageType.CMD:
          {
            // Receiving command messages does not trigger the `onMessagesReceived` event, but triggers the `onCmdMessagesReceived` event instead.
          }
          break;
        case MessageType.COMBINE:
          // TODO: Handle this case.
          throw UnimplementedError();
      }
    }
  }

  void _addChatListener() async {
    ChatClient.getInstance.chatManager.addMessageEvent(
      "UNIQUE_HANDLER_ID",
      ChatMessageEvent(
        onSuccess: (msgId, msg) {
          _addLogToConsole("send message succeed + $msgId");
        },
        onProgress: (msgId, progress) {
          _addLogToConsole("send message Progress");
        },
        onError: (msgId, msg, error) {
          _addLogToConsole(
            "send message failed, code: ${error.code}, desc: ${error.description}",
          );
        },
      ),
    );

    ChatClient.getInstance.chatManager.addEventHandler(
      "UNIQUE_HANDLER_ID",
      ChatEventHandler(onMessagesReceived: onMessagesReceived),
    );
  }

  @override
  void dispose() {
    ChatClient.getInstance.chatManager.removeMessageEvent("UNIQUE_HANDLER_ID");
    ChatClient.getInstance.chatManager.removeEventHandler("UNIQUE_HANDLER_ID");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("chat")),
      body: Container(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.max,
          children: [
            const SizedBox(height: 10),
            const Text("login userId: ${AgoraChatConfig.userId}"),
            // const Text("agoraToken: ${AgoraChatConfig.agoraToken}"),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  flex: 1,
                  child: TextButton(
                    onPressed: _signIn,
                    child: const Text("SIGN IN"),
                    style: ButtonStyle(
                      foregroundColor: WidgetStateProperty.all(Colors.white),
                      backgroundColor: WidgetStateProperty.all(
                        Colors.lightBlue,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextButton(
                    onPressed: _signOut,
                    child: const Text("SIGN OUT"),
                    style: ButtonStyle(
                      foregroundColor: WidgetStateProperty.all(Colors.white),
                      backgroundColor: WidgetStateProperty.all(
                        Colors.lightBlue,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(
                hintText: "Enter recipient's userId",
              ),
              onChanged: (chatId) => _chatId = chatId,
            ),
            TextField(
              decoration: const InputDecoration(hintText: "Enter message"),
              onChanged: (msg) => _messageContent = msg,
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: _sendMessage,
              child: const Text("SEND TEXT"),
              style: ButtonStyle(
                foregroundColor: WidgetStateProperty.all(Colors.white),
                backgroundColor: WidgetStateProperty.all(Colors.lightBlue),
              ),
            ),

            // Flexible(
            //   child: ListView.builder(
            //     controller: scrollController,
            //     itemBuilder: (_, index) {
            //       return Text(_logText[index]);
            //     },
            //     itemCount: _logText.length,
            //   ),
            // ),
            Flexible(
              child: ListView.builder(
                controller: scrollController,
                reverse: true, // To show newest messages at bottom
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages.reversed.toList()[index];
                  return MessageBubble(
                    message: message['text'],
                    isMe: message['isMe'],
                    sender: message['sender'],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final String sender;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.sender,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? Colors.lightBlue : Colors.grey[300],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: Radius.circular(isMe ? 12 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 12),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Text(
                sender,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            Text(
              message,
              style: TextStyle(color: isMe ? Colors.white : Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
