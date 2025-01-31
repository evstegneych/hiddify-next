import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CustomAlertDialog extends StatelessWidget {
  const CustomAlertDialog({
    super.key,
    this.title,
    required this.message,
  });

  final String? title;
  final String message;

  Future<void> show(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => this,
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);

    return AlertDialog(
      title: title != null ? Text(title!) : null,
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(localizations.okButtonLabel),
        ),
      ],
    );
  }
}

enum AlertType { info, error, success }

class CustomToast extends StatelessWidget {
  const CustomToast(
    this.message, {
    this.type = AlertType.info,
    this.icon,
    this.duration = const Duration(seconds: 3),
  });

  const CustomToast.error(
    this.message, {
    this.duration = const Duration(seconds: 5),
  })  : type = AlertType.error,
        icon = Icons.error;

  const CustomToast.success(
    this.message, {
    this.duration = const Duration(seconds: 3),
  })  : type = AlertType.success,
        icon = Icons.check;

  final String message;
  final AlertType type;
  final IconData? icon;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = switch (type) {
      AlertType.info => null,
      AlertType.error => scheme.error,
      AlertType.success => scheme.tertiary,
    };

    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        color: Theme.of(context).colorScheme.surface,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: color),
            const SizedBox(width: 8),
          ],
          Flexible(child: Text(message)),
        ],
      ),
    );
  }

  void show(BuildContext context) {
    FToast().init(context);
    FToast().showToast(
      child: this,
      gravity: ToastGravity.BOTTOM,
      toastDuration: duration,
    );
  }
}
