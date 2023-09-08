import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kgpt/Screens/GptScreen.dart';
import 'package:kgpt/Screens/NavigationDrawer.dart';
import 'package:kgpt/constants/constants.dart';
import 'package:kgpt/firestoreData/saveData.dart';
import 'package:kgpt/models/chatmodel.dart';
import 'package:kgpt/providers/chat_provider.dart';
import 'package:kgpt/providers/dark_theme_provider.dart';
import 'package:kgpt/services/showmodel.dart';
import 'package:provider/provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  User? _user;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<DarkThemeProvider>(context);
    bool isDark = themeProvider.darkTheme;
    return Scaffold(
      backgroundColor: isDark
            ? Color.fromARGB(214, 40, 41, 57)
            : Color.fromARGB(255, 249, 249, 249),
      appBar: AppBar(
        backgroundColor: isDark? Color.fromARGB(214, 40, 41, 57) 
        :Color.fromARGB(255, 249, 249, 249),
        iconTheme: IconThemeData(color:  isDark? Colors.white:Colors.black54),
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
                        color:  isDark? Colors.white:Colors.black54,
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
      body: Column(
        children: [
          FutureBuilder(
            future: FirestoreService().getChatsHistory(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return ChatContainer(
                          message: snapshot.data![index]['message_text'],
                          chatId: snapshot.data![index].id,
                          refreshParent: notifyParent);
                    },
                  );
                } else {
                  return const Center(child: Text('No data found.'));
                }
              } else {
                return Expanded(
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void notifyParent() {
    setState(() {});
  }
}

class ChatContainer extends StatelessWidget {
  const ChatContainer(
      {super.key,
      required this.message,
      required this.chatId,
      required this.refreshParent});
  final String message;
  final String chatId;
  final VoidCallback refreshParent;
  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final themeProvider = Provider.of<DarkThemeProvider>(context);
    bool isDark = themeProvider.darkTheme;

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () async {
        List<ChatModel> messages = await FirestoreService().getMessages(chatId);
        chatProvider.setChatId(chatId);
        chatProvider.setChatList(messages);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => GptScreen(),
          ),
        );
      },
      child: Container(
        width: width,
        height: height * 0.09,
        margin: const EdgeInsets.all(10),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDark? Color.fromARGB(213, 54, 55, 69) :Color.fromARGB(255, 249, 249, 249),
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 1,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          
          crossAxisAlignment: CrossAxisAlignment.center,
          
          children: [
            Icon(Icons.chat_bubble_outline_rounded, color: isDark? Colors.white:Colors.black54),
            SizedBox(width: width * 0.05),
            Expanded(
              child: Text(
                
                '$message',
                
                style: TextStyle(
                  overflow: TextOverflow.ellipsis,
                  fontSize: 16,
                  color: isDark? Colors.white:Colors.black54,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(child: SizedBox()),
            IconButton(
              onPressed: () async {
                await FirestoreService().deleteChat(chatId);
                refreshParent();
              },
              icon: Icon(Icons.delete_outline, color: isDark? Colors.white:Colors.black54),
            )
          ],
        ),
      ),
    );
  }
}
