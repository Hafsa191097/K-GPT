import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/constants.dart';
import 'TextWidget.dart';


class ChatWidget extends StatefulWidget {
  const ChatWidget(
      {super.key,
      required this.msg,
      required this.chatIndex,
      this.shouldAnimate = false});

  final String msg;
  final int chatIndex;
  final bool shouldAnimate;

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {

  
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
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: widget.chatIndex == 0 ? scaffoldBackgroundColor : cardColor,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FutureBuilder<User?>(
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                CircleAvatar(
                                  radius:20,
                                  backgroundImage: NetworkImage(
                                    widget.chatIndex == 0 
                                    ? _user?.photoURL ?? 'No Image' : 'https://www.edigitalagency.com.au/wp-content/uploads/chatgpt-logo-white-green-background-png.png'
                                    
                                  ),
                                ),
                             ],
                            )
                            : const Center(child: Text('User not logged in.'));
                          }
                        },
                      ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: widget.chatIndex == 0
                      ? TextWidget(
                          label: widget.msg,
                          color: text1Color,
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                        )
                      : widget.shouldAnimate
                          ? Padding(
                            padding: const EdgeInsets.only(right:8.0),
                            child: DefaultTextStyle(
                                style:GoogleFonts.nunitoSans(
                                  color: text1Color,
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal,
                                ),
                                child: AnimatedTextKit(
                                  
                                  isRepeatingAnimation: false,
                                  repeatForever: false,
                                  displayFullTextOnTap: true,
                                  totalRepeatCount: 1,
                                  animatedTexts: [
                                    TyperAnimatedText(
                                      textAlign: TextAlign.justify,
                                      widget.msg.trim(),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : 
                          Text(
                            widget.msg.trim(),
                              
                          ),
                  
                    ),
                  ],
                ),
                widget.chatIndex == 0
                ? const SizedBox.shrink()
                :  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    
                    children: [
                      Icon(
                        Icons.thumb_up_alt_outlined,
                        color: text1Color,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Icon(
                        Icons.thumb_down_alt_outlined,
                        color: text1Color,
                      ),
                      SizedBox(width:10),
                    ],
                  ),
              ],
                
            ),
          ),
        ),
      ],
    );
  }
}


