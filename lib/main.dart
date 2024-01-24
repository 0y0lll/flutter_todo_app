import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_todo_app/firebase_options.dart';
import 'package:flutter_todo_app/todo_state.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('ko_KR', null);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 101, 158, 114)),
          useMaterial3: true,
          textTheme: const TextTheme(
            bodyMedium: TextStyle(letterSpacing: -1.2),
          )),
      home: const MyHomePage(title: 'Awesome todo'),
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
  double bottom = -200.0; // 초기값으로 밑에서 위로 올린 상태

  final titleController = TextEditingController();
  final contentController = TextEditingController();

  void togglePositionedVisibility() {
    setState(() {
      if (bottom < 0) {
        bottom = 0.0; // 박스를 화면 아래에서 위로 올림
      } else {
        bottom = -200.0; // 박스를 화면 아래로 이동
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 101, 158, 114),
      // appBar: AppBar(
      //   backgroundColor: Colors.transparent,
      //   leading: IconButton(onPressed: () {}, icon: Icon(Icons.home)),
      //   actions: [IconButton(onPressed: () {}, icon: Icon(Icons.person))],
      // ),
      body: Stack(
        children: <Widget>[
          NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                const SliverAppBar(
                  backgroundColor: Color.fromARGB(255, 101, 158, 114),
                  expandedHeight: 100, // appbar가 펼쳐진 상태의 높이
                  floating: false, // 스크롤할 때 appbar를 항상 표시할 건지 여부
                  pinned: true, // 스크롤 업데이트에 따라 appbar를 상단에 고정할 건지 여부
                  flexibleSpace: FlexibleSpaceBar(title: Text('test app bar')),
                ),
              ];
            },
            body: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('/todos')
                    .orderBy('updateDate', descending: true)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                        snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: Text('Loading...'));
                  }

                  final docs = snapshot.data!.docs;
                  List<Todo> newDocs =
                      docs.map((doc) => Todo.fromFirestore(doc)).toList();

                  return ListView.builder(
                    itemCount: newDocs.length,
                    itemBuilder: (BuildContext context, int index) {
                      Todo item = newDocs[index];

                      TextEditingController titleController =
                          TextEditingController(text: item.title);
                      TextEditingController contentController =
                          TextEditingController(text: item.content);

                      return GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) {
                              return Container(
                                width: double.infinity,
                                decoration: const BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(16),
                                      topRight: Radius.circular(16),
                                    )),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 40, vertical: 20),
                                  child: Column(
                                    children: [
                                      TextField(
                                        controller: titleController,
                                        decoration: const InputDecoration(
                                            hintText: 'What your Todo?'),
                                      ),
                                      const SizedBox(height: 10),
                                      TextField(
                                        minLines: 14,
                                        maxLines: 14,
                                        controller: contentController,
                                        keyboardType: TextInputType.multiline,
                                        decoration:
                                            const InputDecoration.collapsed(
                                                hintText:
                                                    'Enter your Todo here'),
                                      ),
                                      Expanded(
                                          child: SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                            onPressed: () async {
                                              if (titleController
                                                      .text.isEmpty ||
                                                  contentController
                                                      .text.isEmpty) {
                                                return;
                                              }

                                              Todo data = Todo(
                                                  title: titleController.text,
                                                  content:
                                                      contentController.text,
                                                  date:
                                                      DateTime.now().toString(),
                                                  updateDate:
                                                      DateTime.now().toString(),
                                                  isPlanned: true,
                                                  isDoing: false,
                                                  isDone: false);

                                              await FirebaseFirestore.instance
                                                  .collection('todos')
                                                  .add(data.toFirestore());
                                            },
                                            child: const Text('Update')),
                                      )),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color.fromARGB(255, 46, 87, 55)
                                      .withOpacity(0.5),
                                  spreadRadius: 1,
                                  blurRadius: 10,
                                  offset: const Offset(0, 8),
                                )
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 15),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(item.title,
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold)),
                                      GestureDetector(
                                        onTap: () async {
                                          final doc = await FirebaseFirestore
                                              .instance
                                              .collection('todos')
                                              .where('title',
                                                  isEqualTo: item.title)
                                              .get()
                                              .then((value) =>
                                                  value.docs.map((e) => e.id));

                                          Todo data = Todo(
                                              title: item.title,
                                              content: item.content,
                                              date: item.date,
                                              updateDate:
                                                  DateTime.now().toString(),
                                              isPlanned: !item.isPlanned,
                                              isDoing: false,
                                              isDone: !item.isDone);

                                          await FirebaseFirestore.instance
                                              .collection('todos')
                                              .doc(doc.first)
                                              .update(data.toFirestore());
                                        },
                                        child: Icon(
                                            Icons.check_circle_outline_outlined,
                                            size: 30,
                                            color: item.isDone
                                                ? Colors.green
                                                : Colors.grey),
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(item.content),
                                  const SizedBox(height: 10),
                                  Text(item.updateDate,
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }),
          ),
          // Positioned(
          //   left: 0.0,
          //   right: 0.0,
          //   bottom: bottom,
          //   child: Container(
          //     height: MediaQuery.of(context).size.height,
          //     color: Colors.blue,
          //     child: Center(
          //       child: Text(
          //         'Positioned Widget',
          //         style: TextStyle(color: Colors.white, fontSize: 20.0),
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        // onPressed: togglePositionedVisibility,
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    )),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  child: Column(
                    children: [
                      TextField(
                        controller: titleController,
                        decoration:
                            const InputDecoration(hintText: 'What your Todo?'),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        minLines: 14,
                        maxLines: 14,
                        controller: contentController,
                        keyboardType: TextInputType.multiline,
                        decoration: const InputDecoration.collapsed(
                            hintText: 'Enter your Todo here'),
                      ),
                      Expanded(
                          child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                            onPressed: () async {
                              if (titleController.text.isEmpty ||
                                  contentController.text.isEmpty) {
                                return;
                              }

                              Todo data = Todo(
                                  title: titleController.text,
                                  content: contentController.text,
                                  date: DateTime.now().toString(),
                                  updateDate: DateTime.now().toString(),
                                  isPlanned: true,
                                  isDoing: false,
                                  isDone: false);

                              await FirebaseFirestore.instance
                                  .collection('todos')
                                  .add(data.toFirestore());
                            },
                            child: const Text('Add')),
                      )),
                    ],
                  ),
                ),
              );
            },
          );
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
