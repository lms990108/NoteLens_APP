import 'package:flutter/material.dart';
import 'dart:io';
import 'package:pdfx/pdfx.dart';

class PdfPreviewScreen extends StatefulWidget {
  final File pdfFile;
  final Function(int selectedPage) onConfirm;

  const PdfPreviewScreen({
    super.key,
    required this.pdfFile,
    required this.onConfirm,
  });

  @override
  _PdfPreviewScreenState createState() => _PdfPreviewScreenState();
}

class _PdfPreviewScreenState extends State<PdfPreviewScreen> {
  late PdfController _pdfController;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _pdfController = PdfController(
      document: PdfDocument.openFile(widget.pdfFile.path),
      initialPage: _currentPage - 1, // 초기 페이지 (0 기반)
    );
  }

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF 미리보기'),
        actions: [
          TextButton(
            onPressed: () {
              widget.onConfirm(_currentPage); // 선택된 페이지 전달
            },
            child: const Text(
              '확인',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: PdfView(
        controller: _pdfController,
        onPageChanged: (page) {
          setState(() {
            _currentPage = page + 1; // 페이지 번호는 1부터 시작
          });
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('현재 페이지: $_currentPage'),
            ElevatedButton(
              onPressed: () {
                widget.onConfirm(_currentPage); // 선택된 페이지 전달
              },
              child: const Text('이 페이지 선택'),
            ),
          ],
        ),
      ),
    );
  }
}
