class ChatModel {
  final String msg;
  final int chatIndex;
  final String status;
// add whether a message is liked or not
  ChatModel({required this.msg, required this.chatIndex, this.status = "neutral"});

  factory ChatModel.fromJson(Map<String, dynamic> json) => ChatModel(
        msg: json["msg"],
        chatIndex: json["chatIndex"],
        status: json["status"] ?? "neutral",
      );
}