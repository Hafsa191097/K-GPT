import 'package:flutter/material.dart';
import '../constants/constants.dart';
import 'auth.dart';
import 'package:google_fonts/google_fonts.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height:100,width:100,child: Image.asset('assets/logo.png')),
            const SizedBox(height:20),
            Text('Welcome to ChatGPT',style: GoogleFonts.nunitoSans(
              color: textcolortheme, fontSize: 30, fontWeight: FontWeight.w500, 
            )),
            const SizedBox(height:10),
            Text('Ask anything, get your answer',style: GoogleFonts.nunitoSans(
              color: textcolortheme, fontSize: 16, fontWeight: FontWeight.w500,
            )),
            const SizedBox(height:80),
            GoogleSignInButton(),
          ],
        ),
      ),
    );
  }
}

class GoogleSignInButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await FirebaseAuthentication().handleSignIn(context);
      },
      child: Expanded(
        child: Container(
          padding:const EdgeInsets.symmetric(vertical: 13, horizontal: 50),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: const Color.fromARGB(31, 151, 151, 151), 
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/Google.png', 
                height: 24,
                width: 24,
              ),
              SizedBox(width: 25), // Add spacing between icon and text
              Text(
                'Sign in with Google',
                style: TextStyle(fontSize: 17, color: Colors.black45), // Set your desired text style
              ),
            ],
          ),
        ),
      ),
    );
  }
}