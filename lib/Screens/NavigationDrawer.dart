
import 'package:flutter/material.dart';
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

  buildHeader(BuildContext context)=> Container(
    color: text,
    padding: EdgeInsets.only(top: 24 + MediaQuery.of(context).padding.top,bottom:24),
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
              ?
             Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius:52,
                  backgroundImage: NetworkImage(_user?.photoURL ?? 'No Image'),
                ),
                const SizedBox(height: 15),
                Text(_user!.displayName ?? 'N/A',style:TextStyle(color: Colors.black54,fontSize: 20,)),
                const SizedBox(height: 5),
                Text('${_user!.email}',style: TextStyle(color:Colors.black54,fontSize: 16,)),
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
        leading: const Icon(Icons.home_outlined,color:Colors.grey),
        title:const Text('Home' ,style:TextStyle(color:Colors.black54,fontSize: 16)),
         onTap: () => Navigator.of(context).pushReplacement(MaterialPageRoute(
         builder: (context) => GptScreen())),     
      ),
      ListTile(
        leading: const Icon(Icons.history,color:Colors.grey),
        title:const Text('History',style:TextStyle(color:Colors.black54,fontSize: 16)),
        
        onTap: (){
          
        },
      ),
      ListTile(
        leading: const Icon(Icons.favorite_border_outlined,color:Colors.grey),
        title:const Text('Likes & Dislikes',style:TextStyle(color:Colors.black54,fontSize: 16)),
        
        onTap: (){
          
        },
      ),

       ListTile(
        leading: const Icon(Icons.dark_mode_outlined,color:Colors.grey),
        title:const Text('Theme',style:TextStyle(color:Colors.black54,fontSize: 16)),
        
        onTap: (){
          
        },
      ),
      
      ListTile(
        leading: const Icon(Icons.logout_outlined,color:Colors.grey),
        title:const Text('Logout',style:TextStyle(color:Colors.black54,fontSize: 16)),
        onTap: (){
            FirebaseAuthentication().signOut();
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const SignUp()));
          },
      ),

    ],
  );
}

