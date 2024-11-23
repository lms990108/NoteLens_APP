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
  late PdfController _pdfController;
  int _totalPages = 0;
  int _currentPage = 1; // 현재 페이지 상태
  final Set<int> _selectedPages = {}; // 선택된 페이지를 저장하는 Set

  @override
  void initState() {
    super.initState();
    _pdfController = PdfController(
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
        actions: [
          Row(
            children: [
              Checkbox(
                value: _selectedPages.contains(_currentPage),
                onChanged: (_) => _togglePageSelection(),
                activeColor: Colors.black, // 체크박스 색상을 검은색으로 설정
                checkColor: Colors.black, // 체크 표시 색상을 검은색으로 설정
              ),
              Text(
                '$_currentPage / $_totalPages',
                style: const TextStyle(
                  color: Colors.black, // 페이지 표시 텍스트를 검은색으로 설정
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 16),
            ],
          ),
        ],
        backgroundColor: Colors.white, // AppBar 배경색을 흰색으로 설정
        elevation: 0, // AppBar 그림자 제거
      ),
      body: PdfView(
        controller: _pdfController,
        scrollDirection: Axis.horizontal, // 가로 슬라이드로 표시
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
      bottomNavigationBar: ElevatedButton(
        onPressed: () {
          if (_selectedPages.isNotEmpty) {
            widget.onConfirm(_selectedPages.toList());
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
    );
  }
}
