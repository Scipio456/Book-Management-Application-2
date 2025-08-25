import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book.dart';
import '../services/firestore_service.dart';
import '../screens/pdf_viewer_screen.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class BookDetailsScreen extends StatelessWidget {
  final Book book;

  const BookDetailsScreen({super.key, required this.book});

  Future<void> _toggleFavorite(BuildContext context) async {
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);
    try {
      await firestoreService.toggleFavorite(book.id, !book.isFavorite);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(book.isFavorite ? 'Removed from favorites' : 'Added to favorites'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating favorite: $e')),
      );
    }
  }

  Future<void> _readNow(BuildContext context) async {
    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PdfViewerScreen(path: book.pdfUrl, title: book.title),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening PDF: $e')),
      );
    }
  }

  Future<void> _downloadAndViewPdf(BuildContext context) async {
    try {
      final url = book.pdfUrl; // Google Drive direct URL
      if (kIsWeb) {
        // On web, navigate directly to PdfViewerScreen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PdfViewerScreen(path: url, title: book.title),
          ),
        );
      } else {
        // On mobile, download to local storage
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final dir = await getApplicationDocumentsDirectory();
          final file = File('${dir.path}/${book.title}.pdf');
          await file.write(response.bodyBytes);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PdfViewerScreen(path: file.path, title: book.title),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to download PDF')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading PDF: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(book.title),
        actions: [
          IconButton(
            icon: Icon(
              book.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: book.isFavorite ? Colors.red : null,
            ),
            onPressed: () => _toggleFavorite(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (book.coverImage.isNotEmpty)
              Center(
                child: Image.network(
                  book.coverImage,
                  height: 200,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                ),
              ),
            const SizedBox(height: 16),
            Text(
              book.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              'by ${book.author}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => _readNow(context),
                  child: const Text('Read Now'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () => _downloadAndViewPdf(context),
                  child: const Text('Download & View PDF'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}