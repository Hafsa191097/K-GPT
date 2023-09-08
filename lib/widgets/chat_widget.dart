import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kgpt/firestoreData/saveData.dart';
import 'package:kgpt/providers/chat_provider.dart';
import 'package:kgpt/providers/dark_theme_provider.dart';
import 'package:provider/provider.dart';

import '../constants/constants.dart';
import 'TextWidget.dart';

class ChatWidget extends StatefulWidget {
  ChatWidget(
      {super.key,
      required this.msg,
      required this.chatIndex,
      this.status = "neutral",
      this.shouldAnimate = false});

  final String msg;
  final int chatIndex;
  final bool shouldAnimate;
  String status;

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
    final themeProvider = Provider.of<DarkThemeProvider>(context);
    bool isDark = themeProvider.darkTheme;
    return Column(
      children: [
        Material(
          color: widget.chatIndex == 0
              ? isDark
                  ? scaffoldBackgroundColorDark
                  : scaffoldBackgroundColor
              : isDark
                  ? Color.fromARGB(213, 52, 54, 74)
                  : cardColor,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FutureBuilder<User?>(
                      future: FirebaseAuth.instance.authStateChanges().first,
                      builder: (BuildContext context,
                          AsyncSnapshot<User?> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        } else {
                          _user = snapshot.data;
                          return _user != null
                              ? Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundImage: NetworkImage(widget
                                                  .chatIndex ==
                                              0
                                          ? _user?.photoURL ?? 'No Image'
                                          : 'https://www.edigitalagency.com.au/wp-content/uploads/chatgpt-logo-white-green-background-png.png'),
                                    ),
                                  ],
                                )
                              : const Center(
                                  child: Text('User not logged in.'));
                        }
                      },
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: widget.chatIndex == 0
                          ? TextWidget(
                              label: widget.msg,
                              color: isDark? text1ColorDark: text1Color,
                              fontSize: 15,
                              fontWeight: FontWeight.normal,
                              
                            )
                          : widget.shouldAnimate
                              ? Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: DefaultTextStyle(
                                    textAlign: TextAlign.justify,
                                    style: GoogleFonts.nunitoSans(
                                      color: isDark? text1ColorDark: text1Color,
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
                              : Padding(
                                padding: const EdgeInsets.only(top:5,right:5),
                                child: Text(
                                  textAlign: TextAlign.justify,
                                    widget.msg.trim(),
                                    style: GoogleFonts.nunitoSans(
                                      color: isDark? text1ColorDark: text1Color,
                                      fontSize: 15,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                              ),
                    ),
                  ],
                ),
                widget.chatIndex == 0
                    ? const SizedBox.shrink()
                    : StatefulBuilder(
                        builder: (context, setState) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                onPressed: () {
                                  final chatProvider =
                                      Provider.of<ChatProvider>(context,
                                          listen: false);

                                  String chatId = chatProvider.chatId;

                                  setState(() {
                                    if (widget.status == 'liked') {
                                      widget.status = 'neutral';
                                    } else {
                                      widget.status = 'liked';
                                    }
                                  });

                                  FirestoreService().updateLikeDislikeStatus(
                                      chatId, widget.msg, widget.status);
                                },
                                padding: EdgeInsets.only(
                                    left: 10), // Set padding to zero

                                icon: Icon(
                                  widget.status == 'liked'
                                      ? Icons.thumb_up_alt
                                      : Icons.thumb_up_alt_outlined,
                                  color: text1Color,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  final chatProvider =
                                      Provider.of<ChatProvider>(context,
                                          listen: false);

                                  String chatId = chatProvider.chatId;
                                  setState(() {
                                    if (widget.status == 'disliked') {
                                      widget.status = 'neutral';
                                    } else {
                                      widget.status = 'disliked';
                                    }
                                  });
                                  // assign this new value to firestore &
                                  // provider if needed
                                  FirestoreService().updateLikeDislikeStatus(
                                      chatId, widget.msg, widget.status);
                                },
                                padding: EdgeInsets.only(
                                    right: 10), // Set padding to zero

                                icon: Icon(
                                  widget.status == 'disliked'
                                      ? Icons.thumb_down_alt
                                      : Icons.thumb_down_alt_outlined,
                                  color: text1Color,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
