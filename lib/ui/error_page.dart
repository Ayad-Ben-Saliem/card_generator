import 'package:flutter/material.dart';

class ErrorPage extends StatelessWidget {
  final Object error;
  final StackTrace? stackTrace;

  const ErrorPage({
    Key? key,
    required this.error,
    this.stackTrace,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error!!!')),
      body: Column(
        children: [
          Text('$error'),
          if (stackTrace != null) const Divider(),
          if (stackTrace != null)
            SingleChildScrollView(child: Text('$stackTrace'))
        ],
      ),
    );
  }
}
