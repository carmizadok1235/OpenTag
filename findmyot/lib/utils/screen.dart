import 'package:flutter/material.dart';


bool isDialog(BuildContext context) {
  final ModalRoute<dynamic>? currentRoute = ModalRoute.of(context);

  return currentRoute is 
    RawDialogRoute 
    || (currentRoute?.opaque == false && currentRoute?.barrierDismissible == true);
}