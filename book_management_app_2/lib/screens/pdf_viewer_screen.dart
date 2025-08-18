import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:web/web.dart' as web;
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
          ? _WebPdfViewer(url: path)
          : PDFView(
              filePath: path,
              enableSwipe: true,
              swipeHorizontal: false,
              autoSpacing: true,
              pageFling: true,
              onError: (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to load PDF: $error')),
                );
              },
              onPageError: (page, error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error on page $page: $error')),
                );
              },
            ),
    );
  }
}

class _WebPdfViewer extends StatefulWidget {
  final String url;

  const _WebPdfViewer({required this.url});

  @override
  _WebPdfViewerState createState() => _WebPdfViewerState();
}

class _WebPdfViewerState extends State<_WebPdfViewer> {
  @override
  void initState() {
    super.initState();
    // Inject PDF.js viewer on widget initialization
    _injectPdfViewer();
  }

  @override
  void dispose() {
    // Clean up the injected div to prevent duplicates
    web.document.getElementById('pdf-viewer')?.remove();
    super.dispose();
  }

  void _injectPdfViewer() {
    // Remove existing viewer if present
    web.document.getElementById('pdf-viewer')?.remove();
    // Create container div
    final div = web.document.createElement('div') as web.HTMLDivElement;
    div.id = 'pdf-viewer';
    div.style.width = '100%';
    div.style.height = '100%';
    // Inject iframe with PDF.js viewer
    final html = '''
      <iframe
        src="https://cdnjs.cloudflare.com/ajax/libs/pdf.js/4.9.155/web/viewer.html?file=${widget.url}"
        style="width: 100%; height: 100%; border: none;"
      ></iframe>
    ''';
    div.innerHTML = html as JSAny; // Use innerHTML property
    web.document.body?.append(div);
  }

  @override
  void didUpdateWidget(_WebPdfViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-inject if URL changes
    if (oldWidget.url != widget.url) {
      _injectPdfViewer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.expand(); // Placeholder for Flutter widget tree
  }
}