import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/book.dart';

class FirestoreService {
  final CollectionReference _booksCollection =
      FirebaseFirestore.instance.collection('books');
  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('users');

  Stream<List<Book>> getBooks() {
    return _booksCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Book.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  Future<void> toggleFavorite(String userId, String bookId, bool isFavorited) async {
    DocumentReference userDoc = _usersCollection.doc(userId);
    if (isFavorited) {
      await userDoc.collection('favorites').doc(bookId).delete();
    } else {
      await userDoc.collection('favorites').doc(bookId).set({'bookId': bookId});
    }
  }

  Stream<bool> isFavorited(String userId, String bookId) {
    return _usersCollection
        .doc(userId)
        .collection('favorites')
        .doc(bookId)
        .snapshots()
        .map((snapshot) => snapshot.exists);
  }

  Stream<List<Book>> getFavorites(String userId) {
    return _usersCollection
        .doc(userId)
        .collection('favorites')
        .snapshots()
        .asyncMap((snapshot) async {
      List<Book> favorites = [];
      for (var doc in snapshot.docs) {
        DocumentSnapshot bookDoc = await _booksCollection.doc(doc['bookId']).get();
        if (bookDoc.exists) {
          favorites.add(Book.fromMap(bookDoc.data() as Map<String, dynamic>, doc.id));
        }
      }
      return favorites;
    });
  }

  Future<void> addDownload(String userId, String bookId) async {
    await _usersCollection.doc(userId).collection('downloads').doc(bookId).set({
      'bookId': bookId,
      'downloadedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Book>> getDownloads() {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    return _usersCollection
        .doc(userId)
        .collection('downloads')
        .snapshots()
        .asyncMap((snapshot) async {
      List<Book> downloads = [];
      for (var doc in snapshot.docs) {
        DocumentSnapshot bookDoc = await _booksCollection.doc(doc['bookId']).get();
        if (bookDoc.exists) {
          downloads.add(Book.fromMap(bookDoc.data() as Map<String, dynamic>, doc.id));
        }
      }
      return downloads;
    });
  }

  Future<void> removeDownload(String bookId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    await _usersCollection.doc(userId).collection('downloads').doc(bookId).delete();
  }
}