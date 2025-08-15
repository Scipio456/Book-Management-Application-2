import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AuthService _auth = AuthService();

  Stream<QuerySnapshot> getBooks() {
    return _db.collection('books').snapshots();
  }

  Future<DocumentSnapshot> getBookById(String id) {
    return _db.collection('books').doc(id).get();
  }

  Future<void> addFavorite(String bookId) {
    final userId = _auth.getUserId();
    return _db.collection('users').doc(userId).collection('favorites').add({'bookId': bookId});
  }

  Future<void> removeFavorite(String bookId) async {
    final userId = _auth.getUserId();
    final snapshot = await _db.collection('users').doc(userId).collection('favorites').where('bookId', isEqualTo: bookId).get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  Future<bool> isFavorite(String bookId) async {
    final userId = _auth.getUserId();
    final snapshot = await _db.collection('users').doc(userId).collection('favorites').where('bookId', isEqualTo: bookId).get();
    return snapshot.docs.isNotEmpty;
  }

  Stream<QuerySnapshot> getFavorites() {
    final userId = _auth.getUserId();
    return _db.collection('users').doc(userId).collection('favorites').snapshots();
  }

  Future<void> addDownload(String bookId, String localPath) {
    final userId = _auth.getUserId();
    return _db.collection('users').doc(userId).collection('downloads').add({'bookId': bookId, 'localPath': localPath});
  }

  Future<void> removeDownload(String downloadId) {
    final userId = _auth.getUserId();
    return _db.collection('users').doc(userId).collection('downloads').doc(downloadId).delete();
  }

  Stream<QuerySnapshot> getDownloads() {
    final userId = _auth.getUserId();
    return _db.collection('users').doc(userId).collection('downloads').snapshots();
  }
}