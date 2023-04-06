import 'package:flutter/material.dart';

class DisableWidget extends StatelessWidget {
  final Widget child;
  final bool disable;

  const DisableWidget({
    Key? key,
    required this.child,
    this.disable = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return disable ? Container(
      color: const Color(0x80808080),
      child: IgnorePointer(child: child),
    ) : child;
  }
}
