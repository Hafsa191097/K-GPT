import 'package:flutter/material.dart';
import 'package:kgpt/Screens/history.dart';
import 'package:kgpt/Screens/likes_dislike.dart';
import 'package:kgpt/providers/chat_provider.dart';
import 'package:kgpt/providers/dark_theme_provider.dart';
import 'package:provider/provider.dart';
import '../Authentication/Register.dart';
import '../Authentication/auth.dart';
import '../constants/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'GptScreen.dart';

class NavigationDrawerr extends StatefulWidget {
  const NavigationDrawerr({super.key});

  @override
  State<NavigationDrawerr> createState() => _NavigationDrawerrState();
}

class _NavigationDrawerrState extends State<NavigationDrawerr> {
  User? _user;

  @override
  void initState() {
    super.initState();
    _getUserProfile();
  }

  Future<void> _getUserProfile() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      setState(() {
        _user = currentUser;
      });
    }
  }

  @override
  Widget build(BuildContext context) => Drawer(
        backgroundColor: Provider.of<DarkThemeProvider>(context).darkTheme
            ? Color.fromARGB(255, 40, 41, 57)
            : const Color.fromARGB(255, 251, 243, 243),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              buildHeader(context),
              buildMenuItems(context),
            ],
          ),
        ),
      );

  buildHeader(BuildContext context) => Container(
        color: Provider.of<DarkThemeProvider>(context).darkTheme
            ? Color.fromARGB(213, 54, 55, 76)
            : text,
        padding: EdgeInsets.only(
            top: 24 + MediaQuery.of(context).padding.top, bottom: 24),
        child: FutureBuilder<User?>(
          future: FirebaseAuth.instance.authStateChanges().first,
          builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
            final themeProvider = Provider.of<DarkThemeProvider>(context);
            bool isDark = themeProvider.darkTheme;
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              _user = snapshot.data;
              return _user != null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 52,
                          backgroundImage:
                              NetworkImage(_user?.photoURL ?? 'No Image'),
                        ),
                        const SizedBox(height: 15),
                        Text(_user!.displayName ?? 'N/A',
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black54,
                              fontSize: 20,
                            )),
                        const SizedBox(height: 5),
                        Text('${_user!.email}',
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black54,
                              fontSize: 16,
                            )),
                      ],
                    )
                  : const Center(child: Text('User not logged in.'));
            }
          },
        ),
      );

  buildMenuItems(BuildContext context) {
    bool isDark = Provider.of<DarkThemeProvider>(context).darkTheme;
    return Column(
      children: [
        SizedBox(height: 20),
        ListTile(
          leading: const Icon(Icons.add_box_outlined, color: Colors.grey),
          title: Text(
            'Add Chat',
            style: TextStyle(
                color: isDark ? Colors.white : Colors.black54, fontSize: 16),
          ),
          onTap: () {
            final chatProvider =
                Provider.of<ChatProvider>(context, listen: false);
            chatProvider.setChatId(''); // new chat
            chatProvider.setChatList([]); //empty chat

            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => GptScreen()));
          },
        ),
        ListTile(
          leading: const Icon(Icons.history, color: Colors.grey),
          title:  Text('History',
              style: TextStyle(color: isDark ? Colors.white : Colors.black54, fontSize: 16)),
          onTap: () {
            final chatProvider =
                Provider.of<ChatProvider>(context, listen: false);
            chatProvider.shouldanimatelast = false;
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const HistoryScreen()));
          },
        ),
        ListTile(
          leading:
              const Icon(Icons.favorite_border_outlined, color: Colors.grey),
          title:  Text('Likes & Dislikes',
              style: TextStyle(color: isDark ? Colors.white : Colors.black54, fontSize: 16)),
          onTap: () {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const LikesDislikeScreen()));
          },
        ),
        ListTile(
          leading: const Icon(Icons.dark_mode_outlined, color: Colors.grey),
          title:  Text('Theme',
              style: TextStyle(color: isDark ? Colors.white : Colors.black54, fontSize: 16)),
          onTap: () {
            final themeChange =
                Provider.of<DarkThemeProvider>(context, listen: false);
            themeChange.darkTheme = !themeChange.darkTheme;
          },
        ),
        ListTile(
          leading: const Icon(Icons.logout_outlined, color: Colors.grey),
          title:  Text('Logout',
              style: TextStyle(color: isDark ? Colors.white : Colors.black54, fontSize: 16)),
          onTap: () {
            FirebaseAuthentication().signOut();
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const Register()));
          },
        ),
      ],
    );
  }
}
