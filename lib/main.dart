import 'package:flutter/material.dart';

import 'viewmodels/library_view_model.dart';
import 'views/library_screen.dart';
import 'models/library_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final service = LibraryService();
  await service.init();
  runApp(LibraryApp(service: service));
}

class LibraryApp extends StatefulWidget {
  const LibraryApp({super.key, required this.service});

  final LibraryService service;

  @override
  State<LibraryApp> createState() => _LibraryAppState();
}

class _LibraryAppState extends State<LibraryApp> {
  late final LibraryViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = LibraryViewModel(
      books: widget.service.readBooks(),
      loans: widget.service.readLoans(),
    );
    _viewModel.addListener(_save);
  }

  // Setiap perubahan di ViewModel ditulis ke service.
  void _save() {
    widget.service.writeBooks(_viewModel.books);
    widget.service.writeLoans(_viewModel.loans);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_save);
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Perpustakaan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: LibraryScreen(viewModel: _viewModel),
    );
  }
}