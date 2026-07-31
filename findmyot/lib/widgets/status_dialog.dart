import 'package:flutter/material.dart';


enum DialogStatus { success, error }

class StatusDialog extends StatelessWidget {
  final DialogStatus status;
  final String title;
  final String message;

  const StatusDialog({
    super.key,
    required this.status,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final isSuccess = status == DialogStatus.success;
    final Color accentColor = isSuccess ? Colors.green : Colors.red;
    final IconData icon = isSuccess ? Icons.check_circle_outline : Icons.error_outline;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      title: Row(
        children: [
          Icon(icon, color: accentColor, size: 28),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: accentColor,
            ),
          ),
        ],
      ),
      content: Text(
        message,
        style: const TextStyle(fontSize: 15),
      ),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () => Navigator.pop(context),
          child: const Text("OK", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}


void showStatusDialog(
  BuildContext context, {
  required DialogStatus status,
  required String message,
  String? title,
}) {
  showDialog(
    context: context,
    builder: (context) => StatusDialog(
      status: status,
      title: title ?? (status == DialogStatus.success ? "Success" : "Error"),
      message: message,
    ),
  );
}