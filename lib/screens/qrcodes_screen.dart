import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pdfLib;
import 'package:open_file/open_file.dart';
import 'package:gastro/Firebase/database.dart';
import 'package:gastro/components/my_slider.dart';
import 'package:gastro/screens/user_menu_screen.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../data/models.dart';

class QRCodesScreen extends StatefulWidget {
  const QRCodesScreen({Key? key}) : super(key: key);

  @override
  _QRCodesState createState() => _QRCodesState();
}

class _QRCodesState extends State<QRCodesScreen> {
  final String _id = 'bshdfhsdfvwjs';
  int _numberOfCodes = 2;
  MyDatabase database = new MyDatabase();
  late Restaurant restaurant;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed: () async {
                String result = "-NnEfWiIDPlC1om8M-OP001";
                restaurant = new Restaurant(id: result.toString());
                await database.getAllGerichte(restaurant);
                _navigateToMenuDisplay(context);
              },
              child: Text('Get All Gerichte'),
            ),
            MySlider(
              onChanged: (value) {
                setState(() {
                  _numberOfCodes = value;
                });
              },
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                await _generatePDF();
              },
              child: const Text('GENERATE QR CODES & PDF'),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToMenuDisplay(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MenuDisplay(restaurant: restaurant),
      ),
    );
  }

  Future<void> _generatePDF() async {
    final pdfLib.Document pdf = pdfLib.Document();

    List<Map<String, dynamic>> qrCodes = [];
    for (int i = 0; i < _numberOfCodes; i++) {
      String combinedID = _id + ((i+1).toString().padLeft(3, '0'));
      final Uint8List? qrBytes = await _generateQRCode(combinedID);
      qrCodes.add({
        'qrBytes': qrBytes,
        'id': combinedID,
        'tableNumber' : (i+1).toString().padLeft(3, '0')
      });
    }

    List<List<Map<String, dynamic>>> qrCodesPerPage = [];
    for (int i = 0; i < qrCodes.length; i += 6) {
      qrCodesPerPage.add(qrCodes.sublist(i, i + 6 > qrCodes.length ? qrCodes.length : i + 6));
    }

    for (var pageCodes in qrCodesPerPage) {
      List<pdfLib.Widget> qrRows = [];
      for (int i = 0; i < 3; i++) {
        List<pdfLib.Widget> qrColumns = [];
        for (int j = 0; j < 2; j++) {
          int index = i * 2 + j;
          if (index < pageCodes.length && pageCodes[index]['qrBytes'] != null) {
            qrColumns.add(
              pdfLib.Container(
                margin: pdfLib.EdgeInsets.all(10),
                child: pdfLib.Column(
                  children: [
                    pdfLib.Image(pdfLib.MemoryImage(pageCodes[index]['qrBytes']!), fit: pdfLib.BoxFit.fill),
                    pdfLib.SizedBox(height: 5,),
                    pdfLib.Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: pdfLib.Text(pageCodes[index]['tableNumber'] as String, style: const pdfLib.TextStyle(fontSize: 15)),
                    ),
                  ],
                ),
              ),
            );
          } else {
            qrColumns.add(
              pdfLib.Container(
                margin: pdfLib.EdgeInsets.all(10),
              ),
            );
          }
        }
        qrRows.add(pdfLib.Row(
          mainAxisAlignment: pdfLib.MainAxisAlignment.spaceEvenly,
          children: qrColumns,
        ));
      }
      pdf.addPage(
        pdfLib.Page(
          build: (pdfLib.Context context) => pdfLib.Column(
            children: qrRows,
          ),
        ),
      );
    }

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/qrcodes.pdf");
    await file.writeAsBytes(await pdf.save());

    if (await file.exists()) {
      await OpenFile.open(file.path, type: "application/pdf");
    }
  }

  Future<Uint8List?> _generateQRCode(String data) async {
    final qrPainter = QrPainter(
      data: data,
      version: QrVersions.auto,
    );

    final ui.Image qrImage = await qrPainter.toImage(200);
    final ByteData? byteData = await qrImage.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }
}
