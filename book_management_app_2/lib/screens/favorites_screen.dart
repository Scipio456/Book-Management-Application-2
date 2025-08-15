import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/firestore_service.dart';
import 'book_details_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirestoreService().getFavorites(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text('Error loading favorites'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final favorites = snapshot.data!.docs;

          return ListView.builder(
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final bookId = favorites[index]['bookId'];
              return FutureBuilder<DocumentSnapshot>(
                future: FirestoreService().getBookById(bookId),
                builder: (context, bookSnapshot) {
                  if (!bookSnapshot.hasData) return const ListTile(title: Text('Loading...'));
                  final book = Book.fromMap(bookSnapshot.data!.data() as Map<String, dynamic>, bookId);
                  return ListTile(
                    title: Text(book.title),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookDetailsScreen(book: book))),
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