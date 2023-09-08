import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kgpt/Screens/NavigationDrawer.dart';
import 'package:kgpt/firestoreData/saveData.dart';
import 'package:kgpt/providers/dark_theme_provider.dart';
import 'package:kgpt/services/showmodel.dart';
import 'package:provider/provider.dart';
import '../widgets/likes_dislike_widget.dart';

class LikesDislikeScreen extends StatefulWidget {
  const LikesDislikeScreen({super.key});

  @override
  State<LikesDislikeScreen> createState() => _LikesDislikeScreenState();
}

class _LikesDislikeScreenState extends State<LikesDislikeScreen> {
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
        backgroundColor: isDark
            ? Color.fromARGB(214, 40, 41, 57)
            : Color.fromARGB(255, 249, 249, 249),
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black54),
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
                        color: isDark ? Colors.white : Colors.black54,
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
            future: FirestoreService().getLikesDislikes(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var likesDislikes = snapshot.data;
                return Flexible(
                  child: ListView.builder(
                    itemCount: likesDislikes!.length,
                    itemBuilder: (context, index) {
                      var favJSON = likesDislikes[index];
                      return LikesDislikesMessageWidget(
                        chatId: favJSON['chat_id'],
                        msg: favJSON["message"],
                        shouldAnimate: false,
                        status: favJSON["status"],
                      );
                    },
                  ),
                );
              } else {
                return Expanded(
                  child: Center(
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
}
