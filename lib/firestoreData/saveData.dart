import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kgpt/models/chatmodel.dart';

class FirestoreService {
  final _firestore = FirebaseFirestore.instance;
  final _user = FirebaseAuth.instance.currentUser;
  // Create a chat document
  Future<String> createChatDocument(String message) async {
    log('before document created');

    try {
      final DocumentReference docRef =
          await _firestore.collection("chats").add({
        "created_by": _user!.uid, // Logged-in user's UID
        "created_at": FieldValue.serverTimestamp(), // Current date and time
        "message_text": message, // Replace with your message text
      });
      return docRef.id;
    } catch (e) {
      log(e.toString());
    }
    log('document created');
    return '';
  }

  Future<void> createMessageDocument(
      String chatId, String message, String type) async {
    // chat1/1234567890
    try {
      await _firestore.collection("chats/${chatId}/messages").add({
        "created_by": _user!.uid, // Logged-in user's UID
        "created_at": FieldValue.serverTimestamp(), // Current date and time
        "message_text": message, // Replace with your message text
        "type": type,
        // liked/disliked/neutral should be here
      });
    } catch (e) {
      log(e.toString());
    }
  }

  Future<List<DocumentSnapshot>> getChatsHistory() async {
    log(FirebaseAuth.instance.currentUser!.uid);
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection("chats")
          .where("created_by",
              isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .orderBy('created_at', descending: true)
          .get();
      // convert the querySnapshot to a list of chat model
      log(querySnapshot.docs.toString());
      log(querySnapshot.docs.length.toString());

      return querySnapshot.docs;
    } catch (e) {
      log(e.toString());
    }

    return [];
  }

  Future<List<ChatModel>> getMessages(String chatID) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection("chats/${chatID}/messages")
          .orderBy('created_at', descending: false)
          .get();
      // convert the querySnapshot to a list of chat model
      log(querySnapshot.docs.toString());
      log(querySnapshot.docs.length.toString());

      var messagesObj =
          querySnapshot.docs.map((s) => s.data()); // foreach loop is used
      var messages = messagesObj.map((message) {
        var messageJSON = message as Map<String, dynamic>;
        return ChatModel(
            msg: messageJSON["message_text"],
            chatIndex: messageJSON["type"] == "question" ? 0 : 1,
            status: messageJSON["status"] ?? "neutral");
      }).toList();

      return messages;
    } catch (e) {
      log(e.toString());
    }

    return [];
  }

  Future<void> deleteChat(String chatId) async {
    try {
      await _firestore.collection("chats").doc(chatId).delete();
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> updateLikeDislikeStatus(
      String chatId, String message, String status) async {
    try {
      // find the message in the firestore
      var querySnapshot = await FirebaseFirestore.instance
          .collection('chats/$chatId/messages')
          .where("message_text", isEqualTo: message)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Assuming there's only one matching document, you can update it directly
        DocumentReference documentReference = querySnapshot.docs[0].reference;
        log(status);
        // Update the "status" field with the new value
        await documentReference.update({
          "status": status,
        });
        if(status == "neutral"){
          // nuke the document from likes_dislikes collection
          await FirebaseFirestore.instance
          .collection('likes_dislikes').doc(documentReference.id).delete();
          return;
        }
        // create a document in likes_dislike collection
        await FirebaseFirestore.instance.collection('likes_dislikes')
        .doc(documentReference.id)
        .set(
          {
            "message": message,
            "status": status,
            "created_by": FirebaseAuth.instance.currentUser!.uid,
            "created_at": FieldValue.serverTimestamp(),
          },
          SetOptions(
            merge: true,
          ),
        );
      } else {
        // Handle the case where no matching document was found
        // You can log an error or handle it in another way
      }
    } catch (e) {
      log(e.toString());
    }
  }

  Future<List<Map<String, dynamic>>> getLikesDislikes() async {

    try{
      final QuerySnapshot likesDislikesQuerySnapshot =
        await FirebaseFirestore
        .instance
        .collection('likes_dislikes')
        .where('created_by', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .orderBy("created_at", descending: true)
        .get();
    
    var likesDislikesObj =
        likesDislikesQuerySnapshot.docs
        .map((s) => s.data() as Map<String, dynamic>).toList(); // foreach loop is used

    return likesDislikesObj;

    }
    catch(e){
      log(e.toString());
    }
    return [];
    // doable but could have overhead in future

    // final QuerySnapshot chatQuerySnapshot = await FirebaseFirestore.instance
    //     .collection('chats')
    //     .where("created_by", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
    //     .get();

    // List<DocumentSnapshot> filteredChatDocuments = [];
    // for (QueryDocumentSnapshot chatDocument in chatQuerySnapshot.docs) {
    //   // Step 3: Query messages within each chat document where "status" is not "neutral"
    //   QuerySnapshot messageQuerySnapshot = await chatDocument.reference
    //       .collection('messages')
    //       .where("status", isNotEqualTo: "neutral")
    //       .get();

    //   // Step 4: If there are messages with non-neutral status, add the chat document to the result list
    //   if (messageQuerySnapshot.docs.isNotEmpty) {
    //     filteredChatDocuments.add(chatDocument);
    //   }
    // }
  }
}
