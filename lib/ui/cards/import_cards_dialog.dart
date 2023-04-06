import 'package:card_generator/models/card.dart';
import 'package:card_generator/services/cards_service.dart';
import 'package:card_generator/ui/custom-text-field.dart';
import 'package:card_generator/ui/custom_dialog.dart';
import 'package:card_generator/ui/custom_switch.dart';
import 'package:card_generator/utils.dart';
import 'package:flutter/material.dart' hide Card;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final value = StateProvider<double?>((ref) => null);
final readableValue = StateProvider<String>((ref) {
  final v = ref.watch(value);
  if (v == null) return '';
  return Utils.double2String(v, fractionDigits: 2);
});

final importing = StateProvider((ref) => false);

class ImportCardsDialog extends StatelessWidget {
  final List<Card> cards;

  const ImportCardsDialog({Key? key, required this.cards}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      child: Scaffold(
        appBar: AppBar(title: const Text('Import Cards')),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Consumer(
              builder: (context, ref, child) {
                return ref.watch(importing)
                    ? const LinearProgressIndicator()
                    : Container();
              },
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Select which action you want to perform when card duplicate',
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CustomSwitch(
                    choice1: 'Replace',
                    choice2: 'Ignore',
                    choice1Color: Theme.of(context).colorScheme.primary,
                    choice2Color: Theme.of(context).colorScheme.primary,
                    onChange: (choice) {
                      // TODO: implement
                    },
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 128),
                child: Consumer(
                  builder: (context, ref, child) {
                    return CustomTextField(
                      decoration: const InputDecoration(labelText: 'Value'),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r"^\d*\.?\d*"),
                        ),
                      ],
                      onChanged: (txt) {
                        ref.read(value.notifier).state = double.tryParse(txt);
                      },
                    );
                  },
                ),
              ),
            ),
            const Divider(),
            Consumer(
              builder: (context, ref, child) {
                return Expanded(
                  child: ListView.separated(
                    itemCount: cards.length,
                    separatorBuilder: (_, __) => const Divider(
                      height: 0,
                      thickness: 0.5,
                    ),
                    itemBuilder: (context, index) {
                      final card = cards[index];
                      return ListTile(
                        leading: Text(
                          ref.watch(readableValue),
                          style: const TextStyle(fontSize: 24),
                        ),
                        title: Text(card.code),
                        subtitle: Text(card.serial),
                      );
                    },
                  ),
                );
              },
            ),
            const Divider(height: 0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Consumer(
                    builder: (context, ref, child) {
                      return ElevatedButton(
                        onPressed: _validate(ref)
                            ? () {
                                ref.read(importing.notifier).state = true;
                                final _value = ref.read(value);
                                final _cards = cards
                                    .map((card) => card.copyWith(value: _value))
                                    .toList();
                                CardsService.saveCards(_cards)
                                    .then((value) => Navigator.pop(context));
                              }
                            : null,
                        child: const Text('Import'),
                      );
                    },
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool _validate(WidgetRef ref) {
    return ref.watch(value) != null;
  }
}
