import 'dart:typed_data';

import 'package:card_generator/models/card.dart';
import 'package:card_generator/utils.dart';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';

abstract class Reporting {
  static Future<Uint8List> generateCards(
    List<Card> cards,
    PdfPageFormat format,
  ) async {
    final doc = Document();

    // final font = await PdfGoogleFonts.notoSansArabicRegular();
    final font = await fontFromAssetBundle('assets/fonts/HacenTunisia.ttf');
    final manassa = await imageFromAssetBundle(
      'assets/images/manassa.png',
    );
    final almadar = await imageFromAssetBundle(
      'assets/images/almadar.png',
    );

    for (var card in cards) {
      doc.addPage(
        Page(
          theme: ThemeData.withFont(base: font),
          textDirection: TextDirection.rtl,
          pageFormat: format,
          margin: const EdgeInsets.all(0),
          build: (context) => _generateCard(card, font, manassa, almadar),
        ),
      );
    }

    return doc.save();
  }

  static Widget _generateCard(
    Card card,
    Font font,
    ImageProvider manassa,
    ImageProvider almadar,
  ) {
    final textStyle = TextStyle(font: font);

    return Column(
      children: [
        Row(),
        Image(manassa, width: 32),
        Image(almadar, width: 64),
        Text(
          'المدار الجديد ${Utils.readableMoney(card.value)} د.ل',
          style: textStyle.copyWith(),
        ),
        // Text(
        //   'الرقم السري',
        //   style: textStyle.copyWith(fontWeight: FontWeight.bold),
        // ),
        // Text(
        //   card.code,
        //   style: textStyle.copyWith(fontSize: 12, fontWeight: FontWeight.bold),
        // ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '(${card.code})',
              style:
                  textStyle.copyWith(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 4),
            Text(
              'الرقم السري',
              style: textStyle.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Text(
          'طريقة التعبئة   #الرقم السري*112*',
          style: textStyle.copyWith(fontSize: 10),
        ),
        // Text(
        //   'SERIAL NUMBER',
        //   style: textStyle.copyWith(fontSize: 8),
        // ),
        // Text(
        //   card.serial,
        //   style: textStyle.copyWith(fontSize: 11, fontWeight: FontWeight.bold),
        // ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('(${card.serial})', style: textStyle.copyWith(fontSize: 8)),
            SizedBox(width: 4),
            Text('الرقم التسلسلي', style: textStyle.copyWith(fontSize: 8)),
          ],
        ),
        // Text(
        //   'شركة منصة للتقنية',
        //   style: textStyle.copyWith(fontSize: 8),
        // ),
      ],
    );
  }
}
