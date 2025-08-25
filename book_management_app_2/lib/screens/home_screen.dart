import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'book_details_screen.dart';
import 'downloads_screen.dart';
import 'favorites_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final firestoreService = Provider.of<FirestoreService>(context);

    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<Map<String, dynamic>?>(
          stream: firestoreService.getUserData(authService.currentUser?.uid),
          builder: (context, snapshot) {
            final userData = snapshot.data;
            final username = userData?['username'] ?? 'User';
            return Text('Library - $username');
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: const Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              title: const Text('Library'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Favorites'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FavoritesScreen()),
                );
              },
            ),
            ListTile(
              title: const Text('Downloads'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DownloadsScreen()),
                );
              },
            ),
            ListTile(
              title: const Text('Logout'),
              onTap: () async {
                await authService.signOut();
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Books',
                hintText: 'Enter title or author',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim().toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Book>>(
              stream: firestoreService.getBooks(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final books = snapshot.data ?? [];
                final filteredBooks = books.where((book) {
                  final title = book.title.toLowerCase();
                  final author = book.author.toLowerCase();
                  return title.contains(_searchQuery) || author.contains(_searchQuery);
                }).toList();
                if (filteredBooks.isEmpty) {
                  return const Center(child: Text('No books found'));
                }
                return ListView.builder(
                  itemCount: filteredBooks.length,
                  itemBuilder: (context, index) {
                    final book = filteredBooks[index];
                    return ListTile(
                      leading: book.coverImage.isNotEmpty
                          ? Image.network(
                              book.coverImage,
                              width: 50,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.book),
                            )
                          : const Icon(Icons.book),
                      title: Text(book.title),
                      subtitle: Text(book.author),
                      trailing: Icon(
                        book.isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: book.isFavorite ? Colors.red : null,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookDetailsScreen(book: book),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}