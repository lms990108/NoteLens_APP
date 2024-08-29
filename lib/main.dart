import 'package:flutter/material.dart';
import 'package:notelens_app/common/utils/database_utils.dart';
import 'package:notelens_app/src/ui/category/view/category_list_view.dart';
import 'package:notelens_app/src/ui/category/view_model/category_list_view_model.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseUtils.initializeDatabase();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<CategoryListViewModel>(
          create: (_) => CategoryListViewModel())
      ],
      child: const MyApp()
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 0, 0, 0)),
          useMaterial3: true,
        ),
        home: CategoryListView());
  }
}
