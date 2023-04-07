import 'dart:convert';

import 'package:card_generator/equatable_list.dart';
import 'package:card_generator/models/card.dart';
import 'package:card_generator/services/cards_service.dart';
import 'package:card_generator/ui/cards/cards_list.dart';
import 'package:card_generator/ui/cards/import_cards.dart';
import 'package:card_generator/ui/cards/import_cards_dialog.dart';
import 'package:card_generator/ui/cards/pdf_cards_view.dart';
import 'package:card_generator/ui/custom-text-field.dart';
import 'package:card_generator/ui/custom_dialog.dart';
import 'package:card_generator/utils.dart';
import 'package:flutter/material.dart' hide Card;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';

import 'package:csv/csv.dart';

final cards = StreamProvider((ref) => CardsService.cards());
final usedCards = StreamProvider((ref) => CardsService.usedCards());
final unusedCards = StreamProvider((ref) => CardsService.unusedCards());

final activeCards = StateProvider((ref) {
  var provider = unusedCards;
  final cardsFilter = ref.watch(filter);
  if (cardsFilter == 'all') {
    provider = cards;
  } else if (cardsFilter == 'used') {
    provider = usedCards;
  }
  return provider;
});

final filter = StateProvider((ref) => 'unused');

final cardsValues = StateProvider<Set<double>>((ref) {
  final result = <double>{};
  final _cards = ref.watch(cards).value;
  if (_cards != null) {
    for (final card in _cards) {
      if (card != null) result.add(card.value);
    }
  }
  return result;
});

final selectedValue = StateProvider<double?>((ref) => null);
final count = StateProvider<int?>((ref) => null);
final validate = StateProvider(
  (ref) => ref.watch(selectedValue) != null && ref.watch(count) != null,
);

class CardsView extends StatelessWidget {
  const CardsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buttons(context),
        const Divider(height: 0),
        Expanded(child: _cardsList()),
      ],
    );
  }

  Widget _buttons(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _button(
              onPressed: () => _importCards(context),
              child: Column(
                children: const [
                  Icon(Icons.import_export),
                  Text('Import Cards'),
                ],
              ),
            ),
            Consumer(
              builder: (context, ref, child) {
                return _button(
                  onPressed: () {
                    final cards = ref.read(selectedCards);
                    ref.read(selectedCards.notifier).state = EquatableList();
                    if (cards.isNotEmpty) {
                      _toPdf(context, cards.toList());
                    } else {
                      _filters(context);
                    }
                  },
                  child: Column(
                    children: const [
                      Icon(Icons.picture_as_pdf_outlined),
                      Text('Convert Cards'),
                    ],
                  ),
                );
              },
            ),
            Consumer(
              builder: (context, ref, child) {
                return _button(
                  onPressed: () {
                    CardsService.deleteCards(
                      ref.read(selectedCards).map((card) => card.id!),
                    );
                  },
                  child: Column(
                    children: const [
                      Icon(Icons.delete_outline),
                      Text('Delete Cards'),
                    ],
                  ),
                );
              },
            ),
            Consumer(
              builder: (context, ref, child) {
                return _button(
                  onPressed: () {
                    ref.read(selectedCards.notifier).state = EquatableList(
                      ref
                          .read(ref.read(activeCards))
                          .value
                          ?.map((card) => card!),
                    );
                  },
                  child: Column(
                    children: const [
                      Icon(Icons.checklist),
                      Text('Select All'),
                    ],
                  ),
                );
              },
            ),
            Consumer(
              builder: (context, ref, child) {
                return _button(
                  onPressed: () => _filterCards(context, ref),
                  child: Column(
                    children: const [
                      Icon(Icons.filter_alt_outlined),
                      Text('Filter Cards'),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _filterCards(BuildContext context, WidgetRef ref) {
    void selectFilter(WidgetRef ref, String value) {
      ref.read(filter.notifier).state = value;
      Navigator.pop(context);
    }

    showDialog(
      context: context,
      builder: (context) => CustomDialog(
        child: LayoutBuilder(builder: (context, constraints) {
          return Flex(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            direction: constraints.maxWidth > constraints.maxHeight
                ? Axis.horizontal
                : Axis.vertical,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: () => selectFilter(ref, 'all'),
                  child: const Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('All Cards'),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: () => selectFilter(ref, 'used'),
                  child: const Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('Used Cards'),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: () => selectFilter(ref, 'unused'),
                  child: const Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('Unused Cards'),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  void _toPdf(BuildContext context, List<Card?> cards) {
    showDialog(
      context: context,
      builder: (context) => CustomDialog(
        child: PdfCardsView(
          cards: [
            for (var card in cards)
              if (card != null) card
          ],
        ),
      ),
    );
    for (var card in cards) {
      if (card != null) CardsService.useCard(card);
    }
  }

  Widget _button({required VoidCallback? onPressed, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: TextButton(
        onPressed: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: child,
        ),
      ),
    );
  }

  Widget _cardsList() {
    return Consumer(
      builder: (context, ref, child) {
        return ref.watch(ref.watch(activeCards)).when(
              loading: () => const SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(),
              ),
              data: (cards) => CardsList(cards: cards),
              error: (error, stackTrace) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('$error'),
                    ),
                    const Divider(),
                    ListView(
                      shrinkWrap: true,
                      children: [Text('$stackTrace')],
                    ),
                  ],
                );
              },
            );
      },
    );
  }

  void _importCards(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const CustomDialog(child: ImportCards()),
    );
  }

  void _filters(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return CustomDialog(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 128),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Select Cards to Convert'),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Consumer(
                          builder: (context, ref, child) {
                            final values = ref.watch(cardsValues);
                            return DropdownButton<double>(
                              value: ref.watch(selectedValue),
                              items: [
                                for (var value in values)
                                  DropdownMenuItem(
                                    value: value,
                                    child: Text(
                                      Utils.double2String(
                                        value,
                                        fractionDigits: 2,
                                      ),
                                    ),
                                  ),
                              ],
                              onChanged: (value) {
                                ref.watch(selectedValue.notifier).state = value;
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Consumer(
                    builder: (context, ref, child) {
                      return CustomTextField(
                        decoration: const InputDecoration(labelText: 'Count'),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r"^\d*")),
                        ],
                        onChanged: (txt) {
                          ref.read(count.notifier).state = int.tryParse(txt);
                        },
                      );
                    },
                  ),
                ),
                const Divider(height: 0),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Consumer(
                          builder: (context, ref, child) {
                            return ElevatedButton(
                              onPressed: ref.watch(validate)
                                  ? () async {
                                      CardsService.getUnusedCards(
                                        value: ref.read(selectedValue),
                                        limit: ref.watch(count),
                                      ).then(
                                        (cards) {
                                          Navigator.pop(context);
                                          _toPdf(context, cards);
                                        },
                                      );
                                    }
                                  : null,
                              child: const Text('Convert'),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
