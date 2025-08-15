import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/firestore_service.dart';
import 'pdf_viewer_screen.dart';

class DownloadsScreen extends StatelessWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Downloads')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirestoreService().getDownloads(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text('Error loading downloads'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final downloads = snapshot.data!.docs;

          return ListView.builder(
            itemCount: downloads.length,
            itemBuilder: (context, index) {
              final download = downloads[index];
              final bookId = download['bookId'];
              final localPath = download['localPath'];

              return FutureBuilder<DocumentSnapshot>(
                future: FirestoreService().getBookById(bookId),
                builder: (context, bookSnapshot) {
                  if (!bookSnapshot.hasData) return const ListTile(title: Text('Loading...'));
                  final book = Book.fromMap(bookSnapshot.data!.data() as Map<String, dynamic>, bookId);

                  return Dismissible(
                    key: Key(download.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                        color: Colors.red,
                        child: const Align(
                            alignment: Alignment.centerRight, child: Icon(Icons.delete, color: Colors.white))),
                    onDismissed: (direction) async {
                      await FirestoreService().removeDownload(download.id);
                      final file = File(localPath);
                      if (await file.exists()) await file.delete();
                    },
                    child: ListTile(
                      title: Text(book.title),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PdfViewerScreen(path: localPath))),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}