import "package:findmyot/models/user.dart";
import "package:findmyot/providers/auth_provider.dart";
import "package:findmyot/utils/button_handlers.dart";
import "package:findmyot/widgets/signup_dialog.dart";
import "package:findmyot/widgets/status_dialog.dart";
import "package:flutter/material.dart";
import "package:findmyot/screens/main_screen.dart";
import "package:provider/provider.dart";


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: buildBody(context)
    );
  }
}

AppBar buildAppBar(BuildContext context) {
  return AppBar(
    title: Text(
      "Login",
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold
      ),
    ),
    centerTitle: true,
  );
}

Column buildBody(BuildContext context) {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  return Column(
    children: [
      Container(
        margin: EdgeInsets.only(top: 200, left: 30, right: 30),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Color(0xff1d1617).withOpacity(0.11),
              blurRadius: 40,
              spreadRadius: 0.0
            )
          ]
        ),
        child: TextField(
          controller: usernameController,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.all(15),
            hintText: "Username",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none
            )
          ),
        )
      ),
      Container(
        margin: EdgeInsets.only(top: 20, left: 30, right: 30),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Color(0xff1d1617).withOpacity(0.11),
              blurRadius: 40,
              spreadRadius: 0.0
            )
          ]
        ),
        child: TextField(
          controller: passwordController,
          obscureText: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.all(15),
            hintText: "Password",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none
            )
          ),
        )
      ),
      Container(
        margin: EdgeInsets.only(top: 30, left: 30, right: 30),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              await UserHandlers.onLogin(
                authProvider: context.read<AuthProvider>(),
                username: usernameController.text,
                password: passwordController.text,
                onSuccess: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MainScreen())
                ),
                onFailure: (String msg) => showStatusDialog(
                  context,
                  status: DialogStatus.error,
                  message: msg
                )
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15)
              )
            ),
            child: Text(
              "Login",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white
              ),
            ),
          ),
        ),
      ),
      Container(
        margin: EdgeInsets.only(top: 10),
        child: TextButton(
          onPressed: () async {
            // handle sign up navigation
            final UserCreate? newUser = await showDialog<UserCreate>(
              context: context,
              builder: (context) => SignUpDialog()
            );
            
            if (newUser != null){
              await UserHandlers.onSignup(
                authProvider: context.read<AuthProvider>(), 
                newUser: newUser,
                onSuccess: () => showStatusDialog(
                  context, 
                  status: DialogStatus.success, 
                  message: "User Created Successfully"
                ),
                onFailure: (String msg) => showStatusDialog(
                  context,
                  status: DialogStatus.error, 
                  message: msg
                )
              );
            }            
          },
          child: Text(
            "Sign Up",
            style: TextStyle(
              fontSize: 16,
              color: Colors.blue
            ),
          ),
        ),
      )
    ],
  );
}