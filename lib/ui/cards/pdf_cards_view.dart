import 'package:card_generator/models/card.dart';
import 'package:card_generator/pdf/reporting.dart';
import 'package:card_generator/ui/custom_switch.dart';
import 'package:flutter/material.dart' hide Card;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

final pageFormat = StateProvider((ref) => PdfPageFormat.roll57);

class PdfCardsView extends StatelessWidget {
  final List<Card> cards;

  const PdfCardsView({Key? key, required this.cards}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        return FutureBuilder(
          future: Reporting.generateCards(cards, ref.watch(pageFormat)),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Column(
                children: [
                  Text('${snapshot.error}'),
                  const Divider(),
                  SingleChildScrollView(child: Text('${snapshot.stackTrace}')),
                ],
              );
            }
            if (!snapshot.hasData) return const CircularProgressIndicator();

            final data = snapshot.data!;

            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      onPressed: () =>
                          Printing.layoutPdf(onLayout: (format) => data),
                      icon: const Icon(Icons.print_outlined),
                    ),
                    CustomSwitch(
                      choice1: PdfPageFormat.roll57,
                      choice2: PdfPageFormat.roll80,
                      choice1Text: 'Role57',
                      choice2Text: 'Role80',
                      choice2Color: Theme.of(context).colorScheme.primary,
                      onChange: (value) {
                        ref.read(pageFormat.notifier).state = value;
                      },
                    ),
                    IconButton(
                      onPressed: () =>
                          Printing.sharePdf(bytes: data, filename: 'Card.pdf'),
                      icon: const Icon(Icons.share),
                    ),
                  ],
                ),
                const Divider(
                  height: 0,
                  thickness: 2,
                ),
                Expanded(child: SfPdfViewer.memory(data)),
              ],
            );
          },
        );
      },
    );

    return PdfPreview(
      initialPageFormat: PdfPageFormat.roll57,
      // canChangePageFormat: false,
      canChangeOrientation: false,
      canDebug: false,
      // actions: [],
      dpi: 72,
      pageFormats: const {
        'Role80': PdfPageFormat.roll80,
        'Role57': PdfPageFormat.roll57,
      },
      build: (PdfPageFormat format) => Reporting.generateCards(cards, format),
    );
  }
}
