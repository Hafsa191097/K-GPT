import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:kgpt/firestoreData/saveData.dart';
import 'package:provider/provider.dart';
import '../constants/constants.dart';
import '../providers/chat_provider.dart';
import '../providers/models_provider.dart';
import '../services/showmodel.dart';
import '../widgets/TextWidget.dart';
import '../widgets/chat_widget.dart';
import 'NavigationDrawer.dart';

class GptScreen extends StatefulWidget {
  const GptScreen({super.key});

  @override
  State<GptScreen> createState() => _GptScreenState();
}

class _GptScreenState extends State<GptScreen> {
  User? _user;

  Future<void> _getUserProfile() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      setState(() {
        _user = currentUser;
      });
    }
  }

  bool _isTyping = false;

  late TextEditingController textEditingController;
  late ScrollController _listScrollController;
  late FocusNode focusNode;

  @override
  void initState() {
    _listScrollController = ScrollController();
    textEditingController = TextEditingController();
    focusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _listScrollController.dispose();
    textEditingController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final modelsProvider = Provider.of<ModelsProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);

    //  FirestoreService()
    //  .createMessageDocument('ywHcESIgn2w3jHKbrT71', 'pass hogya', 'answer');

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: textcolortheme),
        title: FutureBuilder<User?>(
          future: FirebaseAuth.instance.authStateChanges().first,
          builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              _user = snapshot.data;
              return _user != null
                  ? Text(
                      _user!.displayName ?? 'N/A',
                      style: TextStyle(
                        color: textcolortheme,
                        fontSize: 20,
                      ),
                    )
                  : const Text('User not logged in.');
            }
          },
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              await Services.showModalSheet(context: context);
            },
            icon: const Icon(Icons.model_training_outlined),
          ),
        ],
      ),
      drawer: const NavigationDrawerr(),
      body: SafeArea(
        child: Column(
          children: [
            Flexible(
              child: ListView.builder(
                  controller: _listScrollController,
                  itemCount: chatProvider.getChatList.length,
                  itemBuilder: (context, index) {
                    return ChatWidget(
                      msg: chatProvider.getChatList[index].msg,
                      chatIndex: chatProvider.getChatList[index].chatIndex,
                      shouldAnimate:
                          chatProvider.getChatList.length - 1 == index,
                      status: chatProvider.getChatList[index].status,
                    );
                  }),
            ),
            if (_isTyping) ...[
              const SpinKitThreeBounce(
                color: Colors.grey,
                size: 18,
              ),
            ],
            const SizedBox(
              height: 15,
            ),
            Material(
              color: cardColor,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        focusNode: focusNode,
                        style:  TextStyle(color: textcolortheme),
                        controller: textEditingController,
                        onSubmitted: (value) async {
                          await sendMessageFCT(
                              modelsProvider: modelsProvider,
                              chatProvider: chatProvider);
                        },
                        decoration:  InputDecoration.collapsed(
                          hintText: "How can I help you",
                          hintStyle: TextStyle(color: textcolortheme),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        await sendMessageFCT(
                            modelsProvider: modelsProvider,
                            chatProvider: chatProvider);
                      },
                      icon:  Icon(
                        Icons.send,
                        color: textcolortheme,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void scrollListToEND() {
    _listScrollController.animateTo(
        _listScrollController.position.viewportDimension,
        duration: const Duration(seconds: 2),
        curve: Curves.easeOut);
  }

  Future<void> addMessageToFirestore(String message, String type) async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    String chatId = chatProvider.getChatId;
    // defualt state of chatId is empty string
    log("chat id is: $chatId");
    if (chatId == '') {
      chatId = await FirestoreService().createChatDocument(message);
      chatProvider.setChatId(chatId);
    }
    log("calling createMessageDocument");
    await FirestoreService().createMessageDocument(chatId, message, type);
    log("done createMessageDocument");
  }

  Future<void> sendMessageFCT(
      {required ModelsProvider modelsProvider,
      required ChatProvider chatProvider}) async {
    if (_isTyping) {
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
          content: TextWidget(
            label: "You cant send multiple messages at a time",
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ),
          backgroundColor: textcolortheme,
        ),
      );
      return;
    }
    if (textEditingController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
          content: TextWidget(
            label: "Please type a message",
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ),
          backgroundColor: textcolortheme,
        ),
      );
      return;
    }
    try {
      String msg = textEditingController.text;
      setState(() {
        _isTyping = true;

        chatProvider.addUserMessage(msg: msg);
        // save the question to firestore
        textEditingController.clear();
        focusNode.unfocus();
      });
      await addMessageToFirestore(msg, 'question');

      await chatProvider.sendMessageAndGetAnswers(
          msg: msg, chosenModelId: modelsProvider.getCurrentModel);
      // save the answer to firestore
      addMessageToFirestore(chatProvider.getChatList.last.msg, 'answer');
      setState(() {});
    } catch (error) {
      log("error $error");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: TextWidget(
          label: error.toString(),
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        backgroundColor: textcolortheme,
      ));
    } finally {
      setState(() {
        scrollListToEND();
        _isTyping = false;
      });
    }
  }
}
