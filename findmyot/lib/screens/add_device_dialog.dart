import 'package:findmyot/models/device.dart';
import 'package:flutter/material.dart';

class AddDeviceDialog extends StatefulWidget {
  const AddDeviceDialog({super.key});

  @override
  State<AddDeviceDialog> createState() => _AddDeviceDialogState();
}

class _AddDeviceDialogState extends State<AddDeviceDialog> {
  final TextEditingController _symmetricKeyController = TextEditingController();
  final TextEditingController _privateKeyController = TextEditingController();
  final TextEditingController _timeCreatedController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // pre-fill with current time, still editable
    _timeCreatedController.text = DateTime.now().toString();
  }

  @override
  void dispose() {
    _symmetricKeyController.dispose();
    _privateKeyController.dispose();
    _timeCreatedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      title: const Text(
        "Add Device",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _symmetricKeyController,
              decoration: InputDecoration(
                labelText: "Symmetric Key",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _privateKeyController,
              decoration: InputDecoration(
                labelText: "Private Key",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _timeCreatedController,
              decoration: InputDecoration(
                labelText: "Time Created",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context); // close without saving
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
          onPressed: () {
            final DeviceCreate newDevice = DeviceCreate(
              symmetricKey: _symmetricKeyController.text,
              privateKey:  _privateKeyController.text,
              timePaired: _timeCreatedController.text
            );
            Navigator.pop(context, newDevice); // close and return data
          },
          child: const Text("Add", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}