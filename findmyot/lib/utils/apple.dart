import 'package:findmyot/models/result.dart';
import 'package:findmyot/providers/auth_provider.dart';
import 'package:findmyot/utils/screen.dart';
import 'package:findmyot/widgets/status_dialog.dart';
import 'package:flutter/material.dart';
import 'package:findmyot/widgets/two_factor_auth_dialog.dart';
import 'package:provider/provider.dart';

void checkAppleLoginState(BuildContext context, Result<AppleLoginState> res) async {
  final bool insideDialog = isDialog(context);

  if (!res.success) {
    if (insideDialog){
      throw Exception("Invalid Code");
    } else {
      showStatusDialog(
        context, 
        status: DialogStatus.error, 
        message: res.error!
      );
    }
  }

  switch (res.data!) {
    case AppleLoginState.VERIFIED:
      context.read<AuthProvider>().appleAccountVerified = true;
      if (insideDialog){
        Navigator.of(context).pop();
      }
      // } else {
      //   print("not dialog");
      // }
      // showStatusDialog(
      //   context, 
      //   status: DialogStatus.success, 
      //   message: "Apple Account is Verified"
      // );
    case AppleLoginState.TWO_FACTOR_AUTH:
      if (!insideDialog){
        showDialog(
          context: context, 
          builder: (context) => TwoFactorDialog(
            onVerify: (code) async {
              Result<AppleLoginState> res = await context.read<AuthProvider>().verifyTwoFactorAuthCode(code);
              // print("I am in verify function aaaaaa");
              // if (res.success){
                // print("login state is ${res.data}");
              // }

              try{
                checkAppleLoginState(context, res);
              } catch (e) {
                rethrow;
              }
            },
          )
        );
      }
  }
}

Result<AppleLoginState> handleAppleVerificationResult(Result result) {
  if (!result.success){
    return Result.failure(error: result.error);
  }

  bool verified = result.data["verified"];
  if (!verified) {
    return Result.success(AppleLoginState.TWO_FACTOR_AUTH);
  }

  return Result.success(AppleLoginState.VERIFIED);
}



                               