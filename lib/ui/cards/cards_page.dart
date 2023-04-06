import 'package:card_generator/ui/cards/cards_view.dart';
import 'package:flutter/material.dart' hide Card;

class CardsPage extends StatelessWidget {
  const CardsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Users Page')),
      body: const CardsView(),
    );
  }
}
