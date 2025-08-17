import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/syncfusion_flutter_pdfviewer.dart';
import 'dart:io' show File;

class PdfViewerScreen extends StatelessWidget {
  final String path;
  final String title;

  const PdfViewerScreen({super.key, required this.path, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: kIsWeb
          ? SfPdfViewer.network(
              path,
              onDocumentLoadFailed: (details) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to load PDF: ${details.description}')),
                );
              },
            )
          : SfPdfViewer.file(
              File(path),
              onDocumentLoadFailed: (details) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to load PDF: ${details.description}')),
                );
              },
            ),
    );
  }
}