import 'dart:convert';

import 'package:card_generator/models/card.dart';
import 'package:card_generator/services/cards_service.dart';
import 'package:card_generator/ui/cards/pdf_cards_view.dart';
import 'package:card_generator/ui/custom-text-field.dart';
import 'package:card_generator/ui/custom_dialog.dart';
import 'package:card_generator/utils.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart' hide Card;
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final cardsText = StateProvider((ref) => '');
final cardsValue = StateProvider((ref) => '');
final importing = StateProvider((ref) => false);

final validImport = StateProvider(
  (ref) =>
      ref.watch(cardsText).trim().isNotEmpty &&
      ref.watch(cardsValue).isNotEmpty,
);

class ImportCards extends StatelessWidget {
  const ImportCards({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Consumer(
          builder: (context, ref, child) => ref.watch(importing)
              ? const Center(child: CircularProgressIndicator())
              : Container(),
        ),
        Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Consumer(
                  builder: (context, ref, child) {
                    return CustomTextField(
                      text: ref.watch(cardsText),
                      maxLines: 1000,
                      decoration:
                          const InputDecoration(hintText: 'Put Text Here'),
                      onChanged: (txt) =>
                          ref.read(cardsText.notifier).state = txt,
                    );
                  },
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Consumer(
                      builder: (context, ref, child) {
                        return CustomTextField(
                          text: ref.watch(cardsValue),
                          decoration:
                              const InputDecoration(labelText: 'Card Value'),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r"^\d*")),
                          ],
                          onChanged: (txt) =>
                              ref.read(cardsValue.notifier).state = txt,
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Consumer(
                    builder: (context, ref, child) {
                      return ElevatedButton(
                        onPressed: () async {
                          final txt = await _getFromFile(context);
                          if (txt != null) {
                            ref.read(cardsText.notifier).state = txt;
                          }
                        },
                        child: const Text('Import From File'),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Consumer(
                    builder: (context, ref, child) {
                      return ElevatedButton(
                        onPressed: ref.watch(validImport)
                            ? () async {
                                ref.read(importing.notifier).state = true;
                                await _process(
                                  context,
                                  ref.read(cardsText),
                                  ref.read(cardsValue),
                                ).whenComplete(
                                  () => ref.read(importing.notifier).state =
                                      false,
                                );
                              }
                            : null,
                        child: const Text('Import'),
                      );
                    },
                  ),
                ),
              ],
            )
          ],
        ),
      ],
    );
  }

  Future<String?> _getFromFile(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      withData: true,
      type: FileType.custom,
      allowedExtensions: ['txt', 'csv'],
    );
    if (result != null) {
      final file = result.files.first;
      if (file.bytes != null) {
        return const Utf8Decoder().convert(file.bytes!.toList());
      }
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        _showMessage(context, 'No data found');
      });
    }
    return null;
  }

  Future<void> _process(BuildContext context, String txt, String value) async {
    final table = const CsvToListConverter(eol: '\n').convert(txt);
    final cards = await CardsService.saveCards(_prepareCards(table, value));
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _pdfCardsViewDialog(context, cards);
    });
  }

  List<Card> _prepareCards(List data, String value) {
    if (data is List<List>) data = tableToJson(data, value);
    return [for (final obj in data) Card.fromJson(obj)];
  }

  List<JsonMap> tableToJson(List<List> data, String value) {
    return [
      for (var record in data)
        {
          'value': double.parse(value),
          'code': '${record[0]}',
          'serial': '${record[1]}',
        },
    ];
  }

  void _pdfCardsViewDialog(BuildContext context, List<Card> cards) {
    if (cards.isEmpty) {
      return _showMessage(context, 'Invalid data, no cards to import');
    }
    showDialog(
      context: context,
      builder: (_) => CustomDialog(child: PdfCardsView(cards: cards)),
    );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
