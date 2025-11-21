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

                  // final PdfField radioButtonListField = document.form.fields[0];
                  //print all filable fields with thire types and names with curesponding values
                  for (int i = 0; i < document.form.fields.count; i++) {
                    final PdfField field = document.form.fields[i];
                    // print('Field ${i + 1}: ${field.runtimeType}');
                    print('Field ${i + 1}: ${field.name}');
                    if (field is PdfTextBoxField) {
                      print(' - Value: ${field.text}');
                    } else if (field is PdfCheckBoxField) {
                      print(' - Value: ${field.isChecked}');
                    } else if (field is PdfRadioButtonListField) {
                      print(' - Selected Value: ${field.selectedValue}');
                    } else if (field is PdfComboBoxField) {
                      print(' - Selected Value: ${field.selectedValue}');
                    } else if (field is PdfListBoxField) {
                      print(' - Selected Values: ${field.selectedValues}');
                    }
                  }

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
