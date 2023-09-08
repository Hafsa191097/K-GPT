import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/constants.dart';
import '../providers/dark_theme_provider.dart';
import 'auth.dart';
import 'package:google_fonts/google_fonts.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  @override
  Widget build(BuildContext context) {
    bool isDark = Provider.of<DarkThemeProvider>(context).darkTheme;
    return  Scaffold(
      
      body:
      
       Container(
        color: Provider.of<DarkThemeProvider>(context).darkTheme
        ? Color.fromARGB(213, 54, 55, 76)
        : cardColor,
         child: Center(
          child: Column(
            
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height:100,width:100,child: Image.asset('assets/logo.png')),
              const SizedBox(height:20),
              Text('Welcome to K-GPT',style: GoogleFonts.nunitoSans(
                color: isDark ? Colors.white : textcolortheme, fontSize: 30, fontWeight: FontWeight.w500, 
              )),
              const SizedBox(height:10),
              Text('Ask anything, get your answer',style: GoogleFonts.nunitoSans(
                color: isDark ? Colors.white : textcolortheme, fontSize: 16, fontWeight: FontWeight.w500,
              )),
              const SizedBox(height:80),
              GestureDetector(
                onTap: () async {
                  await FirebaseAuthentication().handleSignIn(context);
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 13, horizontal: 30),
                  padding:const EdgeInsets.symmetric(vertical: 13, horizontal: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: isDark ? Colors.white70 : const Color.fromARGB(31, 151, 151, 151), 
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/Google.png', 
                        height: 24,
                        width: 24,
                      ),
                      SizedBox(width: 25), 
                      Text(
                        'Sign in with Google',
                        style: TextStyle(fontSize: 17, color: isDark ? textcolortheme : Colors.black54), 
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
             ),
       ),
    );
  }
}