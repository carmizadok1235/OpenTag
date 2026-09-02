import 'package:findmyot/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:findmyot/models/result.dart';


class TwoFactorDialog extends StatefulWidget {
  final Future Function(String code) onVerify;

  const TwoFactorDialog({required this.onVerify});

  @override
  State<TwoFactorDialog> createState() => _TwoFactorDialogState();
}

class _TwoFactorDialogState extends State<TwoFactorDialog> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(6, (_) => FocusNode());

  String? _errorMessage;
  bool _isLoading = false;
  int _resendCountdown = 0;
  Timer? _resendTimer;

  String get _code =>
      _controllers.map((c) => c.text).join();

  bool get _isComplete => _code.length == 6;

  @override
  void initState() {
    super.initState();
    // Focus first box when dialog opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    _controllers.forEach((c) => c.dispose());
    _focusNodes.forEach((f) => f.dispose());
    _resendTimer?.cancel();
    super.dispose();
  }

  void _onDigitEntered(String value, int index) {
    // Only allow digits
    if (value.isNotEmpty && !RegExp(r'[0-9]').hasMatch(value)) {
      _controllers[index].clear();
      return;
    }

    setState(() => _errorMessage = null);

    // Move to next box
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }

    // Auto-submit when all filled
    if (_isComplete) {
      _focusNodes[index].unfocus();
    }
  }

  void _onBackspace(int index) {
    if (_controllers[index].text.isEmpty && index > 0) {
      _controllers[index - 1].clear();
      _focusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _verify() async {
    if (!_isComplete) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // print("code is $_code");
      await widget.onVerify(_code);
      // onVerify should pop the dialog on success
    } catch (e) {
      // print("----------------------------------------------\n$e");
      setState(() {
        _errorMessage = 'Incorrect code. Try again.';
        _isLoading = false;
      });
      // Clear all boxes and refocus first
      _controllers.forEach((c) => c.clear());
      _focusNodes[0].requestFocus();
    }
  }

  void _startResendTimer() {
    setState(() => _resendCountdown = 30);
    _resendTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendCountdown > 0) {
          _resendCountdown--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            // Icon
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.shield_outlined, color: Colors.blue, size: 26),
            ),
            SizedBox(height: 16),

            // Title
            Text(
              'Two-factor authentication',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 6),

            // Subtitle
            Text(
              'Enter the 6-digit code from\nyour authenticator app.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.5),
            ),
            SizedBox(height: 24),

            // 6 digit boxes
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(6, (index) => _DigitBox(
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                hasError: _errorMessage != null,
                onChanged: (val) => _onDigitEntered(val, index),
                onBackspace: () => _onBackspace(index),
              )),
            ),
            SizedBox(height: 8),

            // Error message
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: TextStyle(fontSize: 12, color: Colors.red),
              ),
            SizedBox(height: 16),

            // Verify button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isComplete && !_isLoading ? _verify : null,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white,
                        ),
                      )
                    : Text('Verify'),
              ),
            ),
            SizedBox(height: 12),

            // Resend button
            TextButton(
              onPressed: _resendCountdown == 0 ? () {
                _startResendTimer();
                // call your resend API here
              } : null,
              child: Text(
                _resendCountdown > 0
                    ? 'Resend in ${_resendCountdown}s'
                    : "Didn't receive a code? Resend",
                style: TextStyle(fontSize: 13),
              ),
            ),

          ],
        ),
      ),
    );
  }
}

// Individual digit input box
class _DigitBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hasError;
  final Function(String) onChanged;
  final VoidCallback onBackspace;

  const _DigitBox({
    required this.controller,
    required this.focusNode,
    required this.hasError,
    required this.onChanged,
    required this.onBackspace,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44, height: 52,
      margin: EdgeInsets.symmetric(horizontal: 4),
      child: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: (event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.backspace) {
            onBackspace();
          }
        },
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            counterText: '',
            contentPadding: EdgeInsets.zero,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: hasError ? Colors.red : Colors.grey.shade300,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.blue, width: 1.5),
            ),
          ),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: onChanged,
        ),
      ),
    );
  }
}