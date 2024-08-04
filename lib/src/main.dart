import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:notelens_app/src/common/utils/database_utils.dart';

void main() async {
  await DatabaseUtils.initializeDatabase();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 0, 0, 0)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Note Lens'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: const Color.fromARGB(255, 206, 206, 206),
            leading: IconButton(
                icon: const Icon(Icons.sort),
                onPressed: _incrementCounter,
                tooltip: 'Category',
                iconSize: 30),
            title: Image.asset('assets/pngegg.png', width: 40, height: 40),
            actions: [
              IconButton(
                onPressed: _incrementCounter,
                icon: const Icon(Icons.settings),
                iconSize: 30,
              )
            ]),
        body: Column(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(12, 20, 0, 3),
              alignment: Alignment.bottomLeft,
              child: const Text('Category'),
            ),
            Container(
                height: 1,
                width: double.infinity,
                color: Colors.black,
                margin: const EdgeInsets.fromLTRB(10, 0, 10, 0))
          ],
        ),
        bottomNavigationBar: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.help_outline_rounded,
                    color: Color.fromARGB(255, 203, 203, 203),
                  ),
                  onPressed: _incrementCounter,
                  iconSize: 40,
                ),
                IconButton(
                  onPressed: _incrementCounter,
                  icon: const Icon(
                    Icons.add_circle_outline_rounded,
                    color: Color.fromARGB(255, 203, 203, 203),
                  ),
                  iconSize: 40,
                )
              ],
            )));
    // body: Center(
    //   child: Column(
    //     mainAxisAlignment: MainAxisAlignment.center,
    //     children: <Widget>[
    //       const Text(
    //         'You have pushed the button this many times:',
    //       ),
    //       Text(
    //         '$_counter',
    //         style: Theme.of(context).textTheme.headlineMedium,
    //       ),
    //     ],
    //   ),
    // ),
    //   floatingActionButton: FloatingActionButton(
    //     onPressed: _incrementCounter,
    //     tooltip: 'Increment',
    //     child: const Icon(Icons.add),
    //   ), // This trailing comma makes auto-formatting nicer for build methods.
    // );
  }
}
