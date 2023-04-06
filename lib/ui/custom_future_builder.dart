import 'package:flutter/material.dart';

class CustomFutureBuilder<T> extends StatelessWidget {
  final Future<T> future;
  final T? initialData;
  final AsyncWidgetBuilder<T> builder;
  final bool nullableData;
  final bool showErrors;

  const CustomFutureBuilder({
    Key? key,
    required this.future,
    this.initialData,
    required this.builder,
    this.nullableData = false,
    this.showErrors = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      initialData: initialData,
      builder: (context, snapshot) {
        if(showErrors) {
          if (snapshot.hasError) {
            return errorWidget(snapshot.error, snapshot.stackTrace);
          }
          if (snapshot.hasData) {
            if (snapshot.data == null) {
              return const Text('Null Data');
            } else {
              return builder.call(context, snapshot);
            }
          } else {
            return const CircularProgressIndicator();
          }
        } else {
          return builder.call(context, snapshot);
        }
      },
    );
  }

  Widget errorWidget(Object? error, StackTrace? stackTrace) {
    return Column(
      children: [
        Text('$error'),
        const Divider(),
        SingleChildScrollView(
          controller: ScrollController(),
          child: Text('$stackTrace'),
        )
      ],
    );
  }
}
