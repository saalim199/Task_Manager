import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo/Database/DatabaseHelper.dart';
import 'package:todo/Providers/theme_changer_provider.dart';
import 'package:todo/constants/colors.dart';
import 'package:todo/models/task.dart';
import 'package:todo/widgets/task_items.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Task> _foundToDo = [];
  List<Task> _allToDo = [];

  final _taskController = TextEditingController();

  @override
  void initState() {
    _refreshTaskList();
    super.initState();
  }

  Widget searchBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        onChanged: (value) => _runFilter(value),
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.all(0),
          prefixIcon: Icon(
            Icons.search,
            color: tBlack,
            size: 20,
          ),
          prefixIconConstraints: BoxConstraints(
            maxHeight: 20,
            minWidth: 25,
          ),
          border: InputBorder.none,
          hintText: 'Search',
          hintStyle: TextStyle(color: tGrey),
        ),
      ),
    );
  }

  Future<void> _handleToDoChange(Task task) async {
    // Toggle the completion status
    task.isDone = !task.isDone;

    // Update the task in the database
    await DatabaseHelper.instance.update(task);

    // Update the UI
    setState(() {
      _refreshTaskList();
    });
  }

  Future<void> _deleteToDoItem(String id) async {
    if (id.isEmpty) {
      return;
    }
    // Delete the task from the database
    await DatabaseHelper.instance.delete(id);

    setState(() {
      _refreshTaskList();
    });
  }

  void _addToDoItem(String task) async {
    if (task.isEmpty) {
      return;
    }
    // Insert a new task into the database
    await DatabaseHelper.instance.insert({
      DatabaseHelper.columnId: DateTime.now().toString(),
      DatabaseHelper.columnTask: task,
      DatabaseHelper.isDone: 0,
    });
    _taskController.clear();
    _refreshTaskList(); // Refresh the list after adding
  }

  void _refreshTaskList() async {
    final data = await DatabaseHelper.instance.queryAllRows();
    setState(() {
      _foundToDo = data.map((item) => Task.fromMap(item)).toList();
      _allToDo = _foundToDo;
    });
  }

  void _runFilter(String enteredKeyword) {
    List<Task> results = [];
    if (enteredKeyword.isEmpty) {
      // Reset to all tasks when search is cleared
      results = _allToDo;
    } else {
      // Filter tasks based on the entered keyword
      results = _allToDo
          .where((task) => task.taskText!
              .toLowerCase()
              .contains(enteredKeyword.toLowerCase()))
          .toList();
    }

    setState(() {
      _foundToDo = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: tBGColor,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('ToDo'),
        // backgroundColor: tBGColor,
        actions: [
          Consumer<ThemeChangerProvider>(builder: (context, provider, child) {
            return Switch(
              value: provider.getTheme(),
              onChanged: (value) {
                provider.setTheme();
              },
            );
          })
        ],
      ),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(
                              bottom: 20,
                              right: 20,
                              left: 20,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.grey,
                                  offset: Offset(0.0, 0.0),
                                  blurRadius: 10.0,
                                  spreadRadius: 0.0,
                                ),
                              ],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: TextField(
                              controller: _taskController,
                              decoration: const InputDecoration(
                                  hintStyle: TextStyle(color: tBlack),
                                  hintText: 'Add a new Task',
                                  border: InputBorder.none),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(
                              bottom: 20,
                              right: 20,
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                _addToDoItem(_taskController.text);
                                Navigator.of(context).pop();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: tBlue,
                                minimumSize: const Size(60, 60),
                                elevation: 10,
                              ),
                              child: const Text(
                                '+',
                                style: TextStyle(
                                  fontSize: 40,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ]),
                  );
                });
          }),
      body: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 15,
        ),
        child: Column(
          children: [
            searchBox(),
            Container(
              margin: const EdgeInsets.only(
                top: 50,
                bottom: 20,
              ),
              child: const Text(
                'All Tasks',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _foundToDo.length,
                itemBuilder: (BuildContext context, int index) {
                  Task todoo = _foundToDo.reversed.toList()[index];
                  return TaskItem(
                    task: todoo,
                    onTaskChanged: _handleToDoChange,
                    onDeleteItem: _deleteToDoItem,
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
