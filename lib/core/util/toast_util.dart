import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:flutter/material.dart';

class ToastUtil {
  static void success({
    required BuildContext context,
    required String message,
  }) {
    CherryToast.success(
      title: const Text("Success"),
      description: Text(message),
      animationType: AnimationType.fromRight,
      autoDismiss: true,
    ).show(context);
  }

  static void otpSent({required BuildContext context}) {
    CherryToast.info(
      title: const Text("OTP Sent"),
      description: const Text(
        "OTP has been sent to your registered mobile number",
      ),
      animationType: AnimationType.fromRight,
      autoDismiss: true,
    ).show(context);
  }

  static void checkIn({required BuildContext context}) {
    CherryToast.success(
      title: const Text("Check-In"),
      description: const Text("You have successfully checked in"),
      animationType: AnimationType.fromRight,
      autoDismiss: true,
    ).show(context);
  }

  static void checkOut({required BuildContext context}) {
    CherryToast.info(
      title: const Text("Check-Out"),
      description: const Text("You have successfully checked out"),
      animationType: AnimationType.fromRight,
      autoDismiss: true,
    ).show(context);
  }

  static void error({required BuildContext context, required String message}) {
    CherryToast.error(
      title: const Text("Error"),
      description: Text(message),
      animationType: AnimationType.fromBottom,
      autoDismiss: true,
    ).show(context);
  }
}
