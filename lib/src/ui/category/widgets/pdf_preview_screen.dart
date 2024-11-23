import 'package:flutter/material.dart';
import 'dart:io';
import 'package:pdf_render/pdf_render.dart';
import 'package:pdf_render/pdf_render_widgets.dart';

class PdfPreviewScreen extends StatelessWidget {
  final File pdfFile;
  final Function() onConfirm;

  const PdfPreviewScreen({
    super.key,
    required this.pdfFile,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF 미리보기'),
        actions: [
          TextButton(
            onPressed: onConfirm,
            child: const Text(
              '확인',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: PdfViewer.openFile(
        pdfFile.path,
        viewerController: PdfViewerController(),
      ),
    );
  }
}
