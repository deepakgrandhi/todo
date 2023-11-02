import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todo/constants/colors.dart';
import 'package:todo/model/todo.dart';
import 'package:todo/widgets/todo_item.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<ToDo> _foundToDo = [];
  bool isLoading = true;
  final _todoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchTodosFromFirestore();
  }

  Future<void> _fetchTodosFromFirestore() async {
    final querySnapshot = await _firestore.collection('todos').get();
    final todos = querySnapshot.docs.map((doc) {
      final data = doc.data();
      return ToDo(
        id: doc.id,
        todoText: data['todoText'],
        isDone: data['isDone'] ?? false,
        time: data['time'],
      );
    }).toList();

    setState(() {
      _foundToDo = todos;
      isLoading = false;
    });
  }

  Future<void> _addToDoItem(String toDo) async {
    final todoData = {
      'todoText': toDo,
      'isDone': false,
      'time': DateTime.now().toString(),
    };

    await _firestore.collection('todos').add(todoData).then((value) {
      _todoController.clear();
      _fetchTodosFromFirestore();
    });
  }

  Future<void> _deleteToDoItem(String id) async {
    await _firestore.collection('todos').doc(id).delete().then((value) {
      _fetchTodosFromFirestore();
    });
  }

  void _handleToDoChange(ToDo todo) {
    final updatedTodo = todo.copyWith(isDone: !todo.isDone);
    _firestore.collection('todos').doc(todo.id).update(updatedTodo.toJson());
    _fetchTodosFromFirestore();
  }

  void _runFilter(String enteredKeyword) {
    List<ToDo> results = [];
    if (enteredKeyword.isEmpty) {
      results = _foundToDo;
    } else {
      results = _foundToDo
          .where((item) =>
          item.todoText!.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
    }

    setState(() {
      _foundToDo = results;
    });
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
            color: tdBlack,
            size: 20,
          ),
          prefixIconConstraints: BoxConstraints(
            maxHeight: 20,
            minWidth: 25,
          ),
          border: InputBorder.none,
          hintText: 'Search',
          hintStyle: TextStyle(color: tdGrey),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: tdBGColor,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: tdBGColor,
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 15,
              ),
              child: Column(
                children: [
                  searchBox(),
                  Expanded(
                    child: ListView(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(
                            top: 30,
                            bottom: 20,
                          ),
                          child: const Text(
                            "Hey!, What's up",
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        _foundToDo.isEmpty ? const Text("No todos") : ListView.separated(
                          reverse: true,
                          shrinkWrap: true,
                          itemCount: _foundToDo.length,
                          itemBuilder: (context, index) {
                            final todo = _foundToDo[index];
                            return ToDoItem(
                              todo: todo,
                              onToDoChanged: _handleToDoChange,
                              onDeleteItem: _deleteToDoItem,
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) {
                            return const SizedBox(height: 10);
                          },
                        ),
                        const SizedBox(
                          height: 100,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Row(children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(
                      bottom: 20,
                      right: 20,
                      left: 20,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
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
                      controller: _todoController,
                      decoration: const InputDecoration(
                        hintText: 'Add new ToDo',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    _addToDoItem(_todoController.text);
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  child: Container(
                    margin: const EdgeInsets.only(
                      bottom: 20,
                      right: 20,
                    ),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      color: Colors.blue,
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}