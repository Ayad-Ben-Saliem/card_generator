import 'package:card_generator/equatable_list.dart';
import 'package:card_generator/ui/cards/cards_view.dart';
import 'package:card_generator/ui/disable-widget.dart';
import 'package:card_generator/utils.dart';
import 'package:flutter/material.dart' hide Card;
import 'package:card_generator/models/card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedCards = StateProvider((ref) {
  // Update selectedCards when filter changes
  ref.watch(filter);
  return EquatableList<Card>();
});

class CardsList extends StatelessWidget {
  final List<Card?> cards;

  const CardsList({
    Key? key,
    required this.cards,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: cards.length,
      itemBuilder: (context, index) {
        final card = cards.elementAt(index);
        if (card == null) return const ListTile(title: Text('Null'));
        return Consumer(
          builder: (context, ref, child) {
            return DisableWidget(
              disable: card.usedAt != null && ref.watch(filter) != 'used',
              child: ListTile(
                selected: ref.watch(selectedCards).contains(card),
                leading: Text(
                  Utils.double2String(card.value, fractionDigits: 2),
                  style: const TextStyle(fontSize: 24),
                ),
                title: Text(card.code),
                subtitle: Text(card.code),
                trailing: Text('${card.usedAt ?? ''}'),
                onTap: () => _selectCard(ref, card),
              ),
            );
          },
        );
      },
      separatorBuilder: (context, index) => const Divider(height: 0),
    );
  }

  void _selectCard(WidgetRef ref, Card card) {
    final cards = EquatableList(ref.read(selectedCards));
    cards.contains(card) ? cards.remove(card) : cards.add(card);
    ref.read(selectedCards.notifier).state = cards;
  }
}
