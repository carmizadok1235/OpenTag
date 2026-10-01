import 'package:findmyot/models/user.dart';
import 'package:flutter/material.dart';


class SignUpDialog extends StatefulWidget {
  const SignUpDialog({super.key});

  @override
  State<SignUpDialog> createState() => _SignUpDialogState();
}

class _SignUpDialogState extends State<SignUpDialog> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _appleidController = TextEditingController();
  final TextEditingController _appleidPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureEmailPassword = true;
  String? _errorText;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _appleidController.dispose();
    _appleidPasswordController.dispose();
    super.dispose();
  }

  void _handleSignUp() {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    final appleid = _appleidController.text.trim();
    final appleidPassword = _appleidPasswordController.text;

    if (username.isEmpty || password.isEmpty || appleid.isEmpty || appleidPassword.isEmpty) {
      setState(() {
        _errorText = "Please fill in all fields.";
      });
      return;
    }

    if (!appleid.contains("@") || !appleid.contains(".")) {
      setState(() {
        _errorText = "Please enter a valid email address.";
      });
      return;
    }

    // if (password.length < 6) {
    //   setState(() {
    //     _errorText = "Password must be at least 6 characters.";
    //   });
    //   return;
    // }

    final UserCreate newUser = UserCreate(
      username: username, 
      password: password, 
      appleid: appleid, 
      appleidPassword: appleidPassword
    );
    Navigator.pop(context, newUser);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      title: const Text(
        "Sign Up",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: "Username",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _appleidController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: "Apple ID",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _appleidPasswordController,
              obscureText: _obscureEmailPassword,
              decoration: InputDecoration(
                labelText: "Apple ID Password",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: IconButton(
                  icon: Icon(_obscureEmailPassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () {
                    setState(() {
                      _obscureEmailPassword = !_obscureEmailPassword;
                    });
                  },
                ),
              ),
            ),
            if (_errorText != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorText!,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: _handleSignUp,
          child: const Text("Sign Up", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}