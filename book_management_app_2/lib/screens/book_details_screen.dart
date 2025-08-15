import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../models/book.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import 'pdf_viewer_screen.dart';

class BookDetailsScreen extends StatefulWidget {
  final Book book;

  const BookDetailsScreen({super.key, required this.book});

  @override
  State<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends State<BookDetailsScreen> {
  bool _isFavorite = false;
  bool _isDownloaded = false;
  String? _localPath;

  @override
  void initState() {
    super.initState();
    _checkFavorite();
    _checkDownloaded();
  }

  void _checkFavorite() async {
    _isFavorite = await FirestoreService().isFavorite(widget.book.id);
    setState(() {});
  }

  void _toggleFavorite() async {
    if (_isFavorite) {
      await FirestoreService().removeFavorite(widget.book.id);
    } else {
      await FirestoreService().addFavorite(widget.book.id);
    }
    setState(() => _isFavorite = !_isFavorite);
  }

  void _checkDownloaded() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/${widget.book.title}.pdf');
    if (await file.exists()) {
      _localPath = file.path;
      _isDownloaded = true;
      setState(() {});
    }
  }

  void _download() async {
    final url = await StorageService().getDownloadUrl(widget.book.pdfUrl);
    final bytes = await StorageService().downloadFile(url);
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/${widget.book.title}.pdf');
    await file.writeAsBytes(bytes);
    _localPath = file.path;
    await FirestoreService().addDownload(widget.book.id, _localPath!);
    setState(() => _isDownloaded = true);
  }

  void _read() {
    if (_localPath != null) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => PdfViewerScreen(path: _localPath!)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Download first to read')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.book.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Author: ${widget.book.author}'),
            Text('Description: ${widget.book.description}'),
            ElevatedButton(onPressed: _download, child: Text(_isDownloaded ? 'Downloaded' : 'Download')),
            ElevatedButton(onPressed: _read, child: const Text('Read')),
            IconButton(
              icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
              onPressed: _toggleFavorite,
            ),
          ],
        ),
      ),
    );
  }
}