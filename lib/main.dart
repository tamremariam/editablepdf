import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text("Read PDF Web")),
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              // Create file input element
              html.FileUploadInputElement uploadInput =
                  html.FileUploadInputElement();
              uploadInput.accept = '.pdf';
              uploadInput.click();

              uploadInput.onChange.listen((e) async {
                final file = uploadInput.files!.first;
                final reader = html.FileReader();

                reader.readAsArrayBuffer(file);
                reader.onLoadEnd.listen((e) {
                  final bytes = reader.result as Uint8List;

                  // Load PDF document
                  final document = PdfDocument(inputBytes: bytes);

                  // Extract text using PdfTextExtractor
                  final textExtractor = PdfTextExtractor(document);
                  String text = textExtractor.extractText();

                  print("PDF Text:\n$text");

                  document.dispose();
                });
              });
            },
            child: const Text("Pick PDF File"),
          ),
        ),
      ),
    );
  }
}
