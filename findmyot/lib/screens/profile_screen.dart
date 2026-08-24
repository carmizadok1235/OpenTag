import 'package:findmyot/models/user.dart';
import 'package:findmyot/providers/auth_provider.dart';
import 'package:findmyot/providers/devices_provider.dart';
import 'package:findmyot/providers/useapi_provider.dart';
import 'package:findmyot/utils/apple.dart';
import 'package:findmyot/widgets/status_dialog.dart';
import 'package:findmyot/widgets/two_factor_auth_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:findmyot/models/result.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _appleIdController = TextEditingController();
  final TextEditingController _appleIdPasswordController = TextEditingController();

  bool _obscureAppleIdPassword = true;

  // Placeholder values — replace with real user data
  // final String _username = "JohnDoe";
  // final int _numOfDevices = 3;

  @override
  void initState() {
    super.initState();
    // _usernameController.text = _username;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _appleIdController.dispose();
    _appleIdPasswordController.dispose();
    super.dispose();
  }

  void _handleSave() {
    final updatedProfile = {
      "username": _usernameController.text.trim(),
      "appleId": _appleIdController.text.trim(),
      "appleIdPassword": _appleIdPasswordController.text,
    };
    // handle saving — e.g. call your backend here
    print(updatedProfile);
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Container(
      margin: const EdgeInsets.only(left: 30, right: 30, top: 20),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: const Color(0xff1d1617).withOpacity(0.11),
            blurRadius: 40,
            spreadRadius: 0.0,
          )
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.all(15),
          hintText: hintText,
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AuthProvider authProvider = context.watch<AuthProvider>();
    final DevicesProvider devicesProvider = context.watch<DevicesProvider>();
    _usernameController.text = authProvider.user != null ? authProvider.user!.username : "";
    _appleIdController.text = authProvider.user != null ? authProvider.user!.appleid : "";
    
    return Scaffold(
      backgroundColor: const Color(0xffF7F8F8),
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            Text(
              "Hello ${authProvider.user != null ? authProvider.user!.username : ""}",
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Devices: ${devicesProvider.devices.length}",
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[600],
              ),
            ),
            _buildField(
              controller: _usernameController,
              hintText: "Username",
            ),
            _buildField(
              controller: _appleIdController,
              hintText: "Apple ID",
            ),
            _buildField(
              controller: _appleIdPasswordController,
              hintText: "Apple ID Password",
              obscureText: _obscureAppleIdPassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureAppleIdPassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _obscureAppleIdPassword = !_obscureAppleIdPassword;
                  });
                },
              ),
            ),
            const SizedBox(height: 30),
            Container(
              margin: const EdgeInsets.only(left: 30, right: 30),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    Result res = await authProvider.updateProfile(
                      authProvider.user!.id, 
                      _usernameController.text.trim(),
                      _appleIdController.text.trim(), 
                      _appleIdPasswordController.text.trim()
                    );

                    if (res.success) {
                      showStatusDialog(
                        context, 
                        status: DialogStatus.success, 
                        message: "User Updated Successfully"
                      );
                      await authProvider.refreshUser();
                    } else {
                      showStatusDialog(
                        context, 
                        status: DialogStatus.error, 
                        message: res.error!
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    "Save",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 30, right: 30, top: 12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    Result<AppleLoginState> res = await authProvider.validateAppleCredentials();
                    // print(res.data);
                    checkAppleLoginState(context, res);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    "Validate Apple Account",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}