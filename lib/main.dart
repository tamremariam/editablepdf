import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';
import 'PdfFormFiller.dart';
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
      title: 'PDF Form Filler',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: PdfFormFiller(),
    );
  }
}

//--- IGNORE ---
class MyApp11 extends StatelessWidget {
  const MyApp11({super.key});

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

                  // Extract form fields data to JSON
                  final formData = extractFormFieldsToJson(document);

                  // Print the JSON data
                  print('PDF Form Fields JSON:');
                  print(JsonEncoder.withIndent('  ').convert(formData));

                  // Download JSON file
                  downloadJsonFile(formData, 'pdf_form_data.json');

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

  Map<String, dynamic> extractFormFieldsToJson(PdfDocument document) {
    final formFields = <String, dynamic>{};
    final fieldsList = <Map<String, dynamic>>[];

    for (int i = 0; i < document.form.fields.count; i++) {
      final PdfField field = document.form.fields[i];
      final fieldData = <String, dynamic>{};

      // Common field properties
      fieldData['fieldName'] = field.name;
      fieldData['fieldType'] = field.runtimeType.toString();
      fieldData['fieldIndex'] = i;

      // Field-specific properties and values
      if (field is PdfTextBoxField) {
        fieldData['value'] = field.text;
        fieldData['isMultiline'] = field.multiline;
        fieldData['isReadOnly'] = field.readOnly;
      } else if (field is PdfCheckBoxField) {
        fieldData['value'] = field.isChecked;
        fieldData['isReadOnly'] = field.readOnly;
      } else if (field is PdfRadioButtonListField) {
        fieldData['selectedIndex'] = field.selectedIndex;
        fieldData['selectedValue'] = field.selectedValue;
        fieldData['isReadOnly'] = field.readOnly;

        // Extract radio button items
        final items = <Map<String, dynamic>>[];
        for (int j = 0; j < field.items.count; j++) {
          final item = field.items[j];
          items.add({'index': j, 'value': item.value, 'text': item.value});
        }
        fieldData['items'] = items;
      } else if (field is PdfComboBoxField) {
        fieldData['selectedIndex'] = field.selectedIndex;
        fieldData['selectedValue'] = field.selectedValue;
        fieldData['isReadOnly'] = field.readOnly;

        // Extract combo box items
        final items = <Map<String, dynamic>>[];
        for (int j = 0; j < field.items.count; j++) {
          final item = field.items[j];
          items.add({'index': j, 'value': item.value, 'text': item.text});
        }
        fieldData['items'] = items;
      } else if (field is PdfListBoxField) {
        fieldData['selectedIndex'] = field.name;
        fieldData['selectedValues'] = field.selectedValues;
        fieldData['isReadOnly'] = field.readOnly;
        fieldData['isMultiSelect'] = field.multiSelect;

        // Extract list box items
        final items = <Map<String, dynamic>>[];
        for (int j = 0; j < field.items.count; j++) {
          final item = field.items[j];
          items.add({'index': j, 'value': item.value, 'text': item.text});
        }
        fieldData['items'] = items;
      } else {
        // For unknown field types, use toString() for value
        fieldData['value'] = field.mappingName.toString();
      }

      fieldsList.add(fieldData);
    }

    formFields['pdfFormFields'] = fieldsList;
    formFields['totalFields'] = document.form.fields.count;
    formFields['extractionDate'] = DateTime.now().toIso8601String();

    return formFields;
  }

  void downloadJsonFile(Map<String, dynamic> jsonData, String fileName) {
    final jsonString = JsonEncoder.withIndent('  ').convert(jsonData);
    final blob = html.Blob([jsonString], 'application/json');
    final url = html.Url.createObjectUrlFromBlob(blob);

    final anchor = html.AnchorElement()
      ..href = url
      ..download = fileName
      ..style.display = 'none';

    html.document.body!.children.add(anchor);
    anchor.click();
    html.document.body!.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  }
}
