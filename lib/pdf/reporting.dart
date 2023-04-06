import 'dart:typed_data';

import 'package:card_generator/models/card.dart';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart';
import 'package:flutter/material.dart' as flutter;
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';

abstract class Reporting {
  static Future<Uint8List> generateCards(
    List<Card> cards,
    PdfPageFormat format,
  ) async {
    final doc = Document();

    final font = Font.ttf(
      await rootBundle.load("assets/fonts/HacenTunisia.ttf"),
    );
    final imageProvider = await imageFromAssetBundle(
      'assets/images/almadar.png',
    );

    print('cards.length: ${cards.length}');
    for (var card in cards) {
      doc.addPage(
        Page(
          theme: ThemeData.withFont(base: font),
          textDirection: TextDirection.rtl,
          pageFormat: format,
          margin: const EdgeInsets.all(4),
          build: (context) => _generateCard(card, imageProvider, font),
        ),
      );
    }

    return doc.save();
  }

  static Widget _generateCard(
      Card card, ImageProvider imageProvider, Font font) {
    final textStyle = TextStyle(font: font);

    return Column(
      children: [
        Row(),
        Image(imageProvider, width: 100),
        Text(
          'المدار الجديد ${card.value} د.ل',
          style: textStyle.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          'الرقم السري',
          style: textStyle.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          card.code,
          style: textStyle.copyWith(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        Text(
          'طريقة التعبئة   #الرقم السري*112*',
          style: textStyle.copyWith(fontSize: 10),
        ),
        Text(
          'SERIAL NUMBER',
          style: textStyle.copyWith(fontSize: 10),
        ),
        Text(
          card.serial,
          style: textStyle.copyWith(fontSize: 11, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
