import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';

class CustomSwitch<T> extends StatefulWidget {
  final T choice1;
  final T choice2;

  final String? choice1Text;
  final String? choice2Text;


  final Widget Function(BuildContext)? choice1Builder;
  final Widget Function(BuildContext)? choice2Builder;

  final T? value;
  final double width;
  final void Function(T)? onChange;

  final Color? choice1Color;
  final Color? choice2Color;

  const CustomSwitch({
    Key? key,
    required this.choice1,
    required this.choice2,
    this.value,
    this.choice1Text,
    this.choice2Text,
    this.choice1Builder,
    this.choice2Builder,
    this.width = 100,
    this.onChange,
    this.choice1Color,
    this.choice2Color,
  })  : assert(choice1 != choice2),
        assert(value == choice1 || value == choice2 || value == null),
        assert(choice1Text == null || choice1Builder == null),
        assert(choice2Text == null || choice2Builder == null),
        super(key: key);

  @override
  State<CustomSwitch<T>> createState() => _CustomSwitchState<T>();
}

class _CustomSwitchState<T> extends State<CustomSwitch<T>> {
  bool value = true;

  @override
  void initState() {
    super.initState();
    value = widget.value == widget.choice1 || widget.value == null;
  }

  @override
  Widget build(BuildContext context) {
    return FlutterSwitch(
      value: value,
      activeText: widget.choice1Text ?? widget.choice1.toString(),
      inactiveText: widget.choice2Text ?? widget.choice2.toString(),
      showOnOff: true,
      width: widget.width,
      activeColor: widget.choice1Color ?? Theme.of(context).colorScheme.primary,
      inactiveColor: widget.choice2Color ?? Colors.grey,
      activeTextFontWeight: FontWeight.bold,
      inactiveTextFontWeight: FontWeight.bold,
      onToggle: (value) {
        setState(() {
          this.value = value;
          widget.onChange?.call(value ? widget.choice1 : widget.choice2);
        });
      },
    );
  }
}
