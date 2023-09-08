
import 'package:flutter/material.dart';
import 'package:kgpt/firestoreData/saveData.dart';
import 'package:kgpt/providers/dark_theme_provider.dart';
import 'package:provider/provider.dart';

import '../constants/constants.dart';

// ignore: must_be_immutable
class LikesDislikesMessageWidget extends StatefulWidget {
  LikesDislikesMessageWidget(
      {super.key,
      required this.msg,
      required this.chatId,
      this.status = "neutral",
      this.shouldAnimate = false});

  final String msg;
  final bool shouldAnimate;
  final String chatId;
  String status;

  @override
  State<LikesDislikesMessageWidget> createState() => _LikesDislikesMessageWidgetState();
}

class _LikesDislikesMessageWidgetState extends State<LikesDislikesMessageWidget> {
  // User? _user;

  @override
  void initState() {
    super.initState();
    // _getUserProfile();
  }

  // Future<void> _getUserProfile() async {
  //   User? currentUser = FirebaseAuth.instance.currentUser;
  //   if (currentUser != null) {
  //     setState(() {
  //       _user = currentUser;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<DarkThemeProvider>(context);
    bool isDark = themeProvider.darkTheme;
    return Column(
      children: [
        Material(
          color: isDark
                  ? Color.fromARGB(213, 52, 54, 74)
                  : cardColor,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: NetworkImage(
                              'https://www.edigitalagency.com.au/wp-content/uploads/chatgpt-logo-white-green-background-png.png'),
                        ),
                      ],
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right:5.0,top:5),
                        child: Text(
                          textAlign: TextAlign.justify,
                          widget.msg.trim(),
                          style: TextStyle(
                      
                            color: isDark? text1ColorDark: text1Color,
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                          
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                StatefulBuilder(
                  builder: (context, setState) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                              if (widget.status == 'liked') {
                                widget.status = 'neutral';
                              } else {
                                widget.status = 'liked';
                              }
                            });

                            FirestoreService().updateLikeDislikeStatus(
                                widget.chatId, widget.msg, widget.status);
                          },
                          padding:
                              EdgeInsets.only(left: 10), // Set padding to zero

                          icon: Icon(
                            widget.status == 'liked'
                                ? Icons.thumb_up_alt
                                : Icons.thumb_up_alt_outlined,
                            color: text1Color,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              if (widget.status == 'disliked') {
                                widget.status = 'neutral';
                              } else {
                                widget.status = 'disliked';
                              }
                            });

                            FirestoreService().updateLikeDislikeStatus(
                                widget.chatId, widget.msg, widget.status);
                          },
                          padding:
                              EdgeInsets.only(right: 10), // Set padding to zero

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
