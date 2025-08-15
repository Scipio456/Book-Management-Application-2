import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'book_details_screen.dart';
import 'favorites_screen.dart';
import 'downloads_screen.dart';
import 'settings_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Library'),
        actions: [
          IconButton(
              icon: const Icon(Icons.favorite),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesScreen()))),
          IconButton(
              icon: const Icon(Icons.download),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DownloadsScreen()))),
          IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()))),
          IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await AuthService().signOut();
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
              }),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirestoreService().getBooks(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text('Error loading books'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final books = snapshot.data!.docs.map((doc) => Book.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();

          return ListView.builder(
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return ListTile(
                title: Text(book.title),
                subtitle: Text(book.author),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookDetailsScreen(book: book))),
              );
            },
          );
        },
      ),
    );
  }
}