import 'package:flutter/material.dart';
import '../../custom/custom_appbar.dart';

class HowToUseView extends StatelessWidget {
  const HowToUseView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Section 1: Upload
            _buildHowToUseCard(
              context,
              icon: Icons.file_upload,
              title: "1. PDF/사진 파일 업로드",
              description:
                  "PDF 파일을 업로드하거나 사진을 추가합니다. 선택한 파일 속의 밑줄 및 강조된 텍스트를 앱이 자동으로 감지합니다.",
            ),
            // Section 2: Text Processing
            _buildHowToUseCard(
              context,
              icon: Icons.edit,
              title: "2. 텍스트 추출 및 전처리",
              description:
                  "감지된 텍스트를 화면에서 확인하고 수정, 추가 또는 삭제할 수 있습니다. 원하는 질문 형태로 다듬어 다음 단계로 진행하세요.",
            ),
            // Section 3: Ask ChatGPT
            _buildHowToUseCard(
              context,
              icon: Icons.question_answer,
              title: "3. ChatGPT로 질문 보내기",
              description:
                  "다듬어진 질문은 '질문하기' 버튼을 눌러 ChatGPT에게 보낼 수 있습니다. 실시간으로 답변을 받아보세요.",
            ),
            // Section 4: Save Q&A
            _buildHowToUseCard(
              context,
              icon: Icons.save,
              title: "4. 질문과 답변 저장",
              description:
                  "받은 질문과 답변을 저장합니다. 원하는 카테고리를 선택하거나 새로 생성하여 체계적으로 관리할 수 있습니다.",
            ),
            // Section 5: Grid/List View
            _buildHowToUseCard(
              context,
              icon: Icons.grid_view,
              title: "5. 카테고리 그리드/리스트",
              description:
                  "오른쪽 상단 설정 버튼을 이용하여 카테고리를 그리드 또는 리스트 형태로 확인할 수 있습니다.",
            ),
            // Section 6: Manage Categories
            _buildHowToUseCard(
              context,
              icon: Icons.folder,
              title: "6. 카테고리 관리",
              description:
                  "저장된 질문과 답변은 카테고리별로 정리됩니다. 검색하거나 새로운 카테고리를 추가해 쉽게 관리하세요.",
            ),
            // Section 7: Manage Q&A
            _buildHowToUseCard(
              context,
              icon: Icons.manage_search,
              title: "7. 질문과 답변 관리",
              description: "저장된 질문과 답변을 탐색하고, 필요없다면 삭제할 수 있습니다.",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHowToUseCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 40, color: Theme.of(context).primaryColor),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14.0,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
