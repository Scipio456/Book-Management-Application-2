import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:io' show File;
import 'package:web/web.dart' as web;
import '../models/book.dart';
import '../services/firestore_service.dart';
import 'pdf_viewer_screen.dart';

class BookDetailsScreen extends StatelessWidget {
  final Book book;
  const BookDetailsScreen({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    Future<void> downloadAndView(BuildContext context) async {
      try {
        final ref = FirebaseStorage.instance.ref(book.pdfUrl);
        final url = await ref.getDownloadURL();
        String? filePath;
        if (kIsWeb) {
          // For web, trigger browser download
          web.HTMLAnchorElement()
            ..href = url
            ..setAttribute('download', '${book.title}.pdf')
            ..click();
          filePath = url; // Use URL for web PDF viewing
        } else {
          // For mobile, save to device
          final response = await http.get(Uri.parse(url));
          final dir = await getApplicationDocumentsDirectory();
          final file = File('${dir.path}/${book.title}.pdf');
          await file.writeAsBytes(response.bodyBytes);
          filePath = file.path; // Use file path for mobile PDF viewing
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Downloaded to $filePath')),
            );
          }
        }
        // Track download in Firestore
        await firestoreService.addDownload(userId, book.id);
        // Navigate to PDF viewer
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PdfViewerScreen(
                path: filePath,
                title: book.title,
              ),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Download failed: $e')),
          );
        }
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(book.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Author: ${book.author}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Description: ${book.description}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            StreamBuilder<bool>(
              stream: firestoreService.isFavorited(userId, book.id),
              builder: (context, snapshot) {
                final isFavorited = snapshot.data ?? false;
                return ElevatedButton(
                  onPressed: () {
                    firestoreService.toggleFavorite(userId, book.id, isFavorited);
                  },
                  child: Text(isFavorited ? 'Remove from Favorites' : 'Add to Favorites'),
                );
              },
            ),
            ElevatedButton(
              onPressed: () => downloadAndView(context),
              child: const Text('Download & View PDF'),
            ),
          ],
        ),
      ),
    );
  }
}