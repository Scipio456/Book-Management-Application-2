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

class _WebPdfViewer extends StatelessWidget {
  final String url;

  const _WebPdfViewer({required this.url});

  @override
  Widget build(BuildContext context) {
    // Use JavaScript to inject PDF.js viewer
    final html = '''
      <div style="height: 100%; width: 100%;">
        <iframe
          src="https://cdnjs.cloudflare.com/ajax/libs/pdf.js/4.9.155/web/viewer.html?file=$url"
          style="width: 100%; height: 100%; border: none;"
        ></iframe>
      </div>
    ''';
    web.document.getElementById('pdf-viewer')?.remove();
    final div = web.document.createElement('div') as web.HTMLDivElement;
    div.id = 'pdf-viewer';
    div.innerHTML = html;
    web.document.body.append(div);

    return const SizedBox.expand(); // Placeholder, as iframe is injected via JS
  }
}