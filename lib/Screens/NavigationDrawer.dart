import 'package:flutter/material.dart';
import 'package:kgpt/Screens/history.dart';
import 'package:kgpt/Screens/likes_dislike.dart';
import 'package:kgpt/providers/chat_provider.dart';
import 'package:provider/provider.dart';
import '../Authentication/SignUp.dart';
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
        color: text,
        padding: EdgeInsets.only(
            top: 24 + MediaQuery.of(context).padding.top, bottom: 24),
        child: FutureBuilder<User?>(
          future: FirebaseAuth.instance.authStateChanges().first,
          builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
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
                              color: textcolortheme,
                              fontSize: 20,
                            )),
                        const SizedBox(height: 5),
                        Text('${_user!.email}',
                            style: TextStyle(
                              color: textcolortheme,
                              fontSize: 16,
                            )),
                      ],
                    )
                  : const Center(child: Text('User not logged in.'));
            }
          },
        ),
      );
  
  buildMenuItems(BuildContext context) => Column(
        children: [
          SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.add_box_outlined, color: Colors.grey),
            title:  Text('Add Chat',
                style: TextStyle(color: textcolortheme, fontSize: 16)),
            onTap: () {
              final chatProvider = Provider.of<ChatProvider>(context, listen: false);
              chatProvider.setChatId(''); // new chat
              chatProvider.setChatList([]); //empty chat

              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => GptScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.history, color: Colors.grey),
            title:  Text('Chat History',
                style: TextStyle(color: textcolortheme, fontSize: 16)),
            onTap: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const HistoryScreen()));
            },
          ),
          ListTile(
            leading:
                const Icon(Icons.favorite_border_outlined, color: Colors.grey),
            title:  Text('Likes & Dislikes',
                style: TextStyle(color: textcolortheme, fontSize: 16)),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const LikesDislikeScreen(),
                  ),
                );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout_outlined, color: Colors.grey),
            title:  Text('Logout',
                style: TextStyle(color: textcolortheme, fontSize: 16)),
            onTap: () {
              FirebaseAuthentication().signOut();
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const SignUp()));
            },
          ),
          Divider(
            color: Color.fromARGB(255, 231, 231, 231), // Change the color of the line
            height: MediaQuery.of(context).size.height*0.06, 
                  // Change the height of the line
            thickness: 1.5,     // Change the thickness of the line
          ),
          ListTile(
            leading: const Icon(Icons.person_2_outlined, color: Colors.grey),
            title:  Text('Upgrade to Plus',
                style: TextStyle(color: textcolortheme, fontSize: 16)),
            onTap: () {
              
              showDialog(
              context: context,
              builder: (BuildContext context) {
                return UpgradeDialog();
              },
            );
            },
          ),
          
        ],
      );
}



class UpgradeDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      
      title: Text('Upgrade to Plus'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Upgrade to the Plus plan to unlock premium features.'),
          SizedBox(height: 20),
          Text('Plan Details:'),
          SizedBox(height: 10),
          Text(' - Premium features'),
          Text(' - Priority support'),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              
              Navigator.of(context).pop(); 
            },
            child: Text('Upgrade Now'),
          ),
        ],
      ),
    );
  }
}

