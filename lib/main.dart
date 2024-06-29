import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';
import 'package:todo_rxdart/todo_model.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
  final todosSubject = BehaviorSubject<List<TodoModel>>();
  final searchSubject = BehaviorSubject<String>();
  //  _searchSubject.stream
  //       .debounceTime(Duration(milliseconds: 300))
  //       .distinct()
  //       .switchMap((query) {
  //         return allTasksStream.map((tasks) {
  //           return tasks.where((task) => task.description.contains(query)).toList();
  //         }).asStream();
  //       })
  //       .distinct((prev, next) => prev == next)
  //       .listen((filteredTasks) {
  //         _tasksSubject.add(filteredTasks);
  //       });

  // _startListeningToSearch() {
  //   searchSubject.stream.switchMap(
  //     (value) {
  //       return todosSubject.map((tasks) {
  //         return tasks.where((task) => task.name.contains(value)).toList();
  //       }).asBroadcastStream();
  //     },
  //   ).listen(
  //     (event) {
  //       todosSubject.add(event);
  //       event.clear();
  //       // print(event);
  //     },
  //   );

  _startListeningToSearch() {
    searchSubject.debounceTime(const Duration(seconds: 3)).distinct().listen(
      (value) {
        final filteredTodos = todosSubject.valueOrNull
            ?.where((element) => element.name.contains(value))
            .toList();

        if (filteredTodos != null) {
          todosSubject.add(filteredTodos);
        }
      },
    );
  }

  @override
  void initState() {
    _startListeningToSearch();
    super.initState();
  }

  final searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: todosSubject,
        builder: (context, snapshot) {
          final todosList = snapshot.data;
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              title: Text(widget.title),
            ),
            body: Column(
              children: [
                TextFormField(
                  controller: searchController,
                  onChanged: searchSubject.add,
                ),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: todosList?.length ?? 0,
                  itemBuilder: (context, index) {
                    final todo = todosList?[index];
                    return Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text("${todo?.name}"),
                            Switch.adaptive(
                              value: todo?.isDone ?? false,
                              onChanged: (value) {},
                            )
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                final todo = TodoModel(name: const Uuid().v8(), isDone: false);
                final newList = [todo, ...?todosList];

                todosSubject.add(newList);
              },
              tooltip: 'Increment',
              child: const Icon(Icons.add),
            ),
          );
        });
  }
}
