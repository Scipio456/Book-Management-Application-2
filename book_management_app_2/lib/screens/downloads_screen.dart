import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/firestore_service.dart';

class DownloadsScreen extends StatelessWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: const Text('Downloads')),
      body: StreamBuilder<List<Book>>(
        stream: firestoreService.getDownloads(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final downloads = snapshot.data ?? [];
          if (downloads.isEmpty) {
            return const Center(child: Text('No downloads yet.'));
          }
          return ListView.builder(
            itemCount: downloads.length,
            itemBuilder: (context, index) {
              final book = downloads[index];
              return Dismissible(
                key: Key(book.id),
                background: Container(
                  color: Colors.red,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) {
                  firestoreService.removeDownload(book.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${book.title} removed from downloads')),
                  );
                },
                child: ListTile(
                  title: Text(book.title),
                  subtitle: Text(book.author),
                ),
              );
            },
          );
        },
      ),
    );
  }
}