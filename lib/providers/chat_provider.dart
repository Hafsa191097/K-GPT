import 'package:flutter/cupertino.dart';
import '../models/chatmodel.dart';
import '../services/api_service.dart';

class ChatProvider with ChangeNotifier {
  List<ChatModel> chatList = [];
  List<ChatModel> get getChatList {
    return chatList;
  }

  String chatId = '';
  String get getChatId {
    return chatId;
  }

  void setChatId(newID){
    chatId = newID;
    // notifyListeners();
  }
  void updateLikeDislike({required String msg, required String status}) {
    // first find the message in the chatList
    int index = chatList.indexWhere((element) => element.msg == msg);
    // update the like or dislike
    chatList[index] = ChatModel(msg: msg, chatIndex: 1, status: status);
    notifyListeners();
  }


  void setChatList(List<ChatModel> c) {
    chatList = c;
    notifyListeners();
    
  }

  void addUserMessage({required String msg}) {
    chatList.add(ChatModel(msg: msg, chatIndex: 0));
    
    notifyListeners();
  }

  Future<void> sendMessageAndGetAnswers(
      {required String msg, required String chosenModelId}) async {
    if (chosenModelId.toLowerCase().startsWith("gpt")) {
      chatList.addAll(await ApiService.sendMessageGPT(
        message: msg,
        modelId: chosenModelId,
      ));
    } else {
      chatList.addAll(await ApiService.sendMessage(
        message: msg,
        modelId: chosenModelId,
      ));
    }
    notifyListeners();
  }
}