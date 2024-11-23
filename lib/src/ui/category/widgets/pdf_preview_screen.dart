import 'package:flutter/material.dart';
import 'dart:io';
import 'package:pdfx/pdfx.dart';

class PdfPreviewScreen extends StatefulWidget {
  final File pdfFile;
  final Function(List<int> selectedPages) onConfirm;

  const PdfPreviewScreen({
    super.key,
    required this.pdfFile,
    required this.onConfirm,
  });

  @override
  _PdfPreviewScreenState createState() => _PdfPreviewScreenState();
}

class _PdfPreviewScreenState extends State<PdfPreviewScreen> {
  late PdfControllerPinch _pdfController;
  int _totalPages = 0;
  List<int> _selectedPages = []; // 선택된 페이지 리스트
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _pdfController = PdfControllerPinch(
      document: PdfDocument.openFile(widget.pdfFile.path),
    );
  }

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }

  void _togglePageSelection() {
    setState(() {
      if (_selectedPages.contains(_currentPage)) {
        _selectedPages.remove(_currentPage); // 이미 선택된 페이지는 해제
      } else {
        _selectedPages.add(_currentPage); // 페이지 선택
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF 미리보기'),
      ),
      body: Stack(
        children: [
          PdfViewPinch(
            controller: _pdfController,
            onDocumentLoaded: (document) {
              setState(() {
                _totalPages = document.pagesCount; // 총 페이지 수 저장
              });
            },
            onPageChanged: (page) {
              setState(() {
                _currentPage = page; // 현재 페이지 업데이트
              });
            },
          ),
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: _selectedPages.contains(_currentPage),
                    onChanged: (_) => _togglePageSelection(),
                    activeColor: Colors.white,
                    checkColor: Colors.black,
                  ),
                  const Text(
                    '선택',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: () {
                if (_selectedPages.isNotEmpty) {
                  widget.onConfirm(_selectedPages); // 선택된 페이지 전달
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('최소 한 페이지를 선택하세요.'),
                    ),
                  );
                }
              },
              child: const Text('선택한 페이지 전송'),
            ),
          ),
        ],
      ),
    );
  }
}
