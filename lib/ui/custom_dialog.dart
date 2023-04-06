import 'dart:io';

import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  final Widget? child;
  const CustomDialog({Key? key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if(Platform.isAndroid || Platform.isIOS) return Dialog(child: child);

    return Dialog(
      child: LayoutBuilder(
        builder: (_, constraints) {
          return ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: constraints.maxWidth * 0.75,
              maxHeight: constraints.maxHeight * 0.75,
            ),
            child: child,
          );
        },
      ),
    );
  }
}
