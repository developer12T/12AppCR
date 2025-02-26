import 'package:_12sale_app/core/styles/style.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class CustomAlertDialog {
  static void show({
    required BuildContext context,
    required AlertType alertType,
    required String title,
    required String description,
    required VoidCallback onCancel,
    required VoidCallback onSubmit,
    String cancelText = 'Cancel',
    String submitText = 'Submit',
    AlertStyle? style,
  }) {
    Alert(
      context: context,
      // type: alertType,
      title: title,
      desc: description,
      style: style ??
          AlertStyle(
            animationType: AnimationType.grow,
            isCloseButton: false,
            isOverlayTapDismiss: false,
            animationDuration: const Duration(milliseconds: 400),
            alertBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22.0),
              side: const BorderSide(color: Colors.grey),
            ),
            alertAlignment: Alignment.center,
          ),
      buttons: [
        DialogButton(
          onPressed: onCancel,
          color:
              Styles.failTextColor, // You can replace this with a custom style
          child: Text(
            cancelText,
            style: Styles.white18(context),
          ),
        ),
        DialogButton(
          onPressed: onSubmit,
          color: Styles.successButtonColor,
          child: Text(
            submitText,
            style: Styles.white18(context),
          ),
        ),
      ],
    ).show();
  }

  static void showCommonAlert(
      BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: Styles.headerRed24(context),
          ),
          content: Text(
            content,
            style: Styles.red18(context),
          ),
          actions: [
            TextButton(
              child: Text("ตกลง", style: Styles.black18(context)),
              onPressed: () async {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
