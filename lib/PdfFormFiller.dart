import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:html' as html;
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfFormFiller extends StatefulWidget {
  const PdfFormFiller({super.key});

  @override
  State<PdfFormFiller> createState() => _PdfFormFillerState();
}

class _PdfFormFillerState extends State<PdfFormFiller> {
  PdfDocument? _document; // Make it nullable and initialize later
  Map<String, dynamic> jasonData = {};
  final TextEditingController _jsonController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  void _loadPDF() {
    // Create file input element
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
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
        jasonData = extractFormFieldsToJson(document);
        _jsonController.text = _prettyJson(jasonData);

        document.dispose();
      });
    });
  }

  String _prettyJson(Map<String, dynamic> json) {
    return JsonEncoder.withIndent('  ').convert(json);
  }

  void _updateFormData() {
    try {} catch (e) {
      _showMessage('Invalid JSON format');
    }
  }

  Future<void> _savePdf() async {}

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _clearAll() {
    setState(() {});

    _document?.dispose();
    _document = null;
    // LocalStorageHelper.clearData();
    _showMessage('All data cleared');
  }

  @override
  void dispose() {
    // Clean up the PDF document when the widget is disposed
    _document?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Form Filler'),
        backgroundColor: Colors.blue.shade700,
        actions: [
          IconButton(
            icon: Icon(Icons.clear_all),
            onPressed: _clearAll,
            tooltip: 'Clear All',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left side - JSON Editor
          Expanded(
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'JSON Data',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Edit your form data in JSON format:',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    SizedBox(height: 16),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: TextField(
                          controller: _jsonController,
                          maxLines: null,
                          expands: true,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(12),
                            border: InputBorder.none,
                            hintText: 'Paste your JSON data here...',
                            alignLabelWithHint: true,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(width: 16),

          // Right side - PDF Preview and Controls
          Expanded(
            flex: 2,
            child: Column(
              children: [
                // Control Buttons
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _loadPDF,
                            icon: Icon(Icons.upload_file),
                            label: Text('Load PDF'),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _updateFormData,
                            icon: Icon(Icons.edit_document),
                            label: Text('Fill Form'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _savePdf,
                            icon: Icon(Icons.save_alt),
                            label: Text('Save PDF'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 16),

                // PDF Preview
                Expanded(
                  child: Card(
                    elevation: 4,
                    child:
                        // _filledPdfBytes != null
                        //     ? PdfPreview(
                        //         build: (format) => _filledPdfBytes!,
                        //         allowSharing: false,
                        //         allowPrinting: true,
                        //       )
                        //     :
                        _buildEmptyState(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.picture_as_pdf, size: 64, color: Colors.grey.shade400),
          SizedBox(height: 16),
          Text(
            'No PDF Loaded',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
          SizedBox(height: 8),
          Text(
            'Load a PDF file to get started',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
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
