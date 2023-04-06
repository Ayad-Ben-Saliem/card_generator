import 'package:card_generator/models/card.dart';
import 'package:card_generator/pdf/reporting.dart';
import 'package:flutter/material.dart' hide Card;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfCardsView extends StatelessWidget {
  final List<Card> cards;

  const PdfCardsView({Key? key, required this.cards}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Reporting.generateCards(cards, PdfPageFormat.roll57),
      builder: (context, snapshot) {
        if(snapshot.hasError) {
          return Column(
            children: [
              Text('${snapshot.error}'),
              const Divider(),
              SingleChildScrollView(child: Text('${snapshot.stackTrace}')),
            ],
          );
        }
        if (snapshot.hasData) return SfPdfViewer.memory(snapshot.data!);
        return const CircularProgressIndicator();
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
