import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_codes/calres.dart';
import 'package:flutter_codes/drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_codes/user_status.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(providers: [
      ChangeNotifierProvider(create: (context) => CalculationResultProvider()),
      ChangeNotifierProvider(create: (context) => CalculationHistoryProvider()),
    ], child: const MyApp()),
  );

  // runApp(ChangeNotifierProvider(
  //     create: (context) => CalculationResultProvider(), child: const MyApp()));
}

class Task {
  String id;
  String name;
  bool isCompleted;

  Task({required this.id, required this.name, this.isCompleted = false});
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: start(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController taskController = TextEditingController();
  List<Task> tasks = [];
  List<Task> completedTasks = [];
  User? userId = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    // Load tasks when the widget is first created
    fetchTasks();
  }

  void addTask(String taskName) {
    setState(() {
      tasks.add(Task(id: DateTime.now().toString(), name: taskName));
      taskController.clear();
    });
  }

  void deleteTask(int index, bool isCompleted) {
    setState(() {
      completedTasks.removeAt(index);
      tasks.removeAt(index);
    });
  }

  void editTask(int index, String newTaskName, bool isCompleted) {
    setState(() {
      if (isCompleted) {
        completedTasks[index].name = newTaskName;
      } else {
        tasks[index].name = newTaskName;
      }
    });
  }

  void completeTask(int index, bool isCompleted) {
    setState(() {
      if (isCompleted) {
        if (index < completedTasks.length) {
          Task task = completedTasks[index];
          task.isCompleted = !task.isCompleted;
          completedTasks.removeAt(index);
          tasks.add(task);
          updateTask(task);
        }
      } else {
        if (index < tasks.length) {
          Task task = tasks[index];
          task.isCompleted = !task.isCompleted;
          tasks.removeAt(index);
          completedTasks.add(task);
          updateTask(task);
        }
      }
    });
    // setState(() {
    //   Task task = isCompleted ? completedTasks[index] : tasks[index];
    //   task.isCompleted = !task.isCompleted;

    //   if (isCompleted) {
    //     if (index < completedTasks.length) {
    //       completedTasks.removeAt(index);
    //       tasks.add(task);
    //     }
    //   } else {
    //     if (index < tasks.length) {
    //       tasks.removeAt(index);
    //       completedTasks.add(task);
    //     }
    //   }
    // });
  }

  void storeTask(String taskName, bool isCompleted) async {
    try {
      await FirebaseFirestore.instance.collection(userId!.uid).add({
        "Created at": DateTime.now(),
        "Task": taskName,
        "isCompleted": isCompleted,
      }).then((value) {
        log("Task added");
      });
    } catch (e) {
      log('Error adding task: $e');
    }
  }

  // void delTask(String taskName, Task task, bool isCompleted) async {
  void delTask(Task task, int index, bool isCompleted) async {
    try {
      await FirebaseFirestore.instance
          .collection(userId!.uid)
          .doc(task.id)
          .delete()
          .then((value) {
        log("Task deleted");
      });
    } catch (e) {
      log('Error deleting task: $e');
    }
    // deleteing task from local list

    // setState(() {
    //   if (isCompleted) {
    //     if (completedTasks.length > index) {
    //       completedTasks.removeAt(index);
    //     }
    //   } else {
    //     if (tasks.length > index) {
    //       tasks.removeAt(index);
    //     }
    //   }
    // });
    setState(() {
      completedTasks.removeAt(index);
      tasks.removeAt(index);
    });
  }

  void updateTask(Task task) async {
    try {
      // Update the task in Firestore
      await FirebaseFirestore.instance
          .collection(userId!.uid)
          .doc(task.id)
          .update({
        "Task": task.name,
        "IsCompleted": task.isCompleted,
      }).then((value) {
        log("Task updated");
      });
    } catch (e) {
      log('Error updating task in database: $e');
    }
  }

  void fetchTasks() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance.collection(userId!.uid).get();

      // Clear existing tasks
      setState(() {
        tasks.clear();
        completedTasks.clear();
      });

      querySnapshot.docs.forEach((doc) {
        Map<String, dynamic>? data = doc.data();
        Task task = Task(
          id: doc.id,
          name: data["Task"] ?? "",
          isCompleted: data["IsCompleted"] ?? false,
        );
        setState(() {
          if (task.isCompleted) {
            completedTasks.add(task);
          } else {
            tasks.add(task);
          }
        });
      });
    } catch (e) {
      log('Error fetching tasks from database: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Schedulo App"),
        titleTextStyle: const TextStyle(
          color: Color.fromARGB(255, 255, 255, 255),
          fontSize: 35.0,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(206, 129, 89, 238),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(5),
            child: const Text(
              'All Tasks',
              style: TextStyle(
                fontSize: 30.0,
              ),
            ),
          ),
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  const TabBar(
                    tabs: [
                      Tab(text: 'Incomplete'),
                      Tab(text: 'Completed'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        buildTaskList(tasks + completedTasks),
                        buildTaskList(completedTasks),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            margin: const EdgeInsets.all(10.0),
            child: TextField(
              controller: taskController,
              decoration: const InputDecoration(
                  hintText: 'Enter a new task',
                  hintStyle: TextStyle(
                    fontSize: 15,
                  ),
                  prefixIcon: IconButton(
                    icon: Icon(
                      Icons.task,
                      color: Colors.black,
                    ),
                    onPressed: null,
                  ),
                  border: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Color.fromARGB(206, 129, 89, 238)))),
              onSubmitted: (value) {
                bool isCompleted = false;
                addTask(value);
                storeTask(value, false);
              },
            ),
          ),
        ],
      ),
      drawer: const MainDrawer(),
    );
  }

  Widget buildTaskList(List<Task> taskList) {
    return ListView.builder(
      itemCount: taskList.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            margin: const EdgeInsets.all(3.0),
            decoration: const BoxDecoration(
              color: Color.fromARGB(206, 129, 89, 238),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: Text(
              taskList[index].name,
              style: TextStyle(
                decoration: taskList[index].isCompleted
                    ? TextDecoration.lineThrough
                    : null,
                color: const Color.fromARGB(255, 255, 255, 255),
                fontSize: 20.0,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                backgroundColor: const Color.fromARGB(206, 129, 89, 238),
                radius: 20,
                child: IconButton(
                  icon: const Icon(
                    Icons.edit,
                    color: Color.fromARGB(255, 255, 255, 255),
                  ),
                  onPressed: () {
                    // Open a dialog for editing the task
                    showDialog(
                      context: context,
                      builder: (context) {
                        String editedTask = taskList[index].name;
                        return AlertDialog(
                          title: const Text('Edit Task'),
                          content: TextField(
                            controller: TextEditingController(
                                text: taskList[index].name),
                            onChanged: (value) {
                              editedTask = value;
                            },
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                editTask(index, editedTask,
                                    taskList[index].isCompleted);
                                Task updatedTask = taskList[index];
                                updateTask(updatedTask);
                                Navigator.pop(context);
                              },
                              child: const Text('Save'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              CircleAvatar(
                backgroundColor: const Color.fromARGB(206, 129, 89, 238),
                radius: 20,
                child: IconButton(
                  icon: const Icon(
                    Icons.delete,
                    color: Color.fromARGB(255, 255, 255, 255),
                  ),
                  onPressed: () {
                    // deleteTask(index, taskList[index].isCompleted);
                    //delTask(taskList[index]);
                    delTask(
                        taskList[index], index, taskList[index].isCompleted);
                  },
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              CircleAvatar(
                backgroundColor: const Color.fromARGB(206, 129, 89, 238),
                radius: 20,
                child: IconButton(
                  icon: Icon(
                    taskList[index].isCompleted
                        ? Icons.check_box
                        : Icons.check_box_outline_blank,
                    color: const Color.fromARGB(255, 255, 255, 255),
                  ),
                  onPressed: () {
                    completeTask(index, taskList[index].isCompleted);
                  },
                ),
              )
            ],
          ),
        );
      },
    );
  }
}

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'dart:developer';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter_codes/drawer.dart';
// import 'package:flutter_codes/user_status.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   runApp(const MyApp());
// }

// class Task {
//   String id; // Add a unique identifier for each task
//   String name;
//   bool isCompleted;

//   Task({required this.id, required this.name, this.isCompleted = false});
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       home: start(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }

// class Home extends StatefulWidget {
//   const Home({super.key});

//   @override
//   _HomeState createState() => _HomeState();
// }

// class _HomeState extends State<Home> {
//   TextEditingController taskController = TextEditingController();
//   List<Task> tasks = [];
//   List<Task> completedTasks = [];
//   User? userId = FirebaseAuth.instance.currentUser;

//   @override
//   void initState() {
//     super.initState();
//     // Load tasks when the widget is first created
//     fetchTasks();
//   }

//   void addTask(String taskName) async {
//     try {
//       // Add the task to the local list
//       Task newTask = Task(id: DateTime.now().toString(), name: taskName);
//       setState(() {
//         tasks.add(newTask);
//         taskController.clear();
//       });

//       // Add the task to Firestore
//       await FirebaseFirestore.instance.collection(userId!.uid).add({
//         "Created at": DateTime.now(),
//         "Task": taskName,
//       }).then((value) {
//         // Update the task with the Firestore ID
//         newTask.id = value.id;
//         updateTask(newTask);
//         log("Task added");
//       });
//     } catch (e) {
//       log('Error adding task: $e');
//     }
//   }

//   void deleteTask(Task task) async {
//     try {
//       // Delete the task from Firestore
//       await FirebaseFirestore.instance
//           .collection(userId!.uid)
//           .doc(task.id)
//           .delete()
//           .then((value) {
//         // Delete the task from the local list
//         setState(() {
//           tasks.remove(task);
//           completedTasks.remove(task);
//         });
//         log("Task deleted");
//       });
//     } catch (e) {
//       log('Error deleting task from database: $e');
//     }
//   }

//   void editTask(int index, String newTaskName, bool isCompleted) {
//     setState(() {
//       if (isCompleted) {
//         completedTasks[index].name = newTaskName;
//       } else {
//         tasks[index].name = newTaskName;
//       }
//     });
//   }

//   void updateTask(Task task) async {
//     try {
//       // Update the task in Firestore
//       await FirebaseFirestore.instance
//           .collection(userId!.uid)
//           .doc(task.id)
//           .update({
//         "Task": task.name,
//         "IsCompleted": task.isCompleted,
//       }).then((value) {
//         log("Task updated");
//       });
//     } catch (e) {
//       log('Error updating task in database: $e');
//     }
//   }

//   void fetchTasks() async {
//     try {
//       QuerySnapshot<Map<String, dynamic>> querySnapshot =
//           await FirebaseFirestore.instance.collection(userId!.uid).get();

//       // Clear existing tasks
//       setState(() {
//         tasks.clear();
//         completedTasks.clear();
//       });

//       querySnapshot.docs.forEach((doc) {
//         Task task = Task(
//           id: doc.id,
//           name: doc["Task"],
//           isCompleted: doc["IsCompleted"] ?? false,
//         );
//         setState(() {
//           if (task.isCompleted) {
//             completedTasks.add(task);
//           } else {
//             tasks.add(task);
//           }
//         });
//       });
//     } catch (e) {
//       log('Error fetching tasks from database: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Schedulo App"),
//         titleTextStyle: const TextStyle(
//           color: Color.fromARGB(255, 255, 255, 255),
//           fontSize: 35.0,
//           fontWeight: FontWeight.bold,
//         ),
//         centerTitle: true,
//         backgroundColor: const Color.fromARGB(206, 129, 89, 238),
//       ),
//       body: Column(
//         children: [
//           Container(
//             margin: const EdgeInsets.all(5),
//             child: const Text(
//               'All Tasks',
//               style: TextStyle(
//                 fontSize: 30.0,
//               ),
//             ),
//           ),
//           Expanded(
//             child: DefaultTabController(
//               length: 2,
//               child: Column(
//                 children: [
//                   const TabBar(
//                     tabs: [
//                       Tab(text: 'Incomplete'),
//                       Tab(text: 'Completed'),
//                     ],
//                   ),
//                   Expanded(
//                     child: TabBarView(
//                       children: [
//                         buildTaskList(tasks),
//                         buildTaskList(tasks),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.all(8.0),
//             margin: const EdgeInsets.all(10.0),
//             child: TextField(
//               controller: taskController,
//               decoration: const InputDecoration(
//                 hintText: 'Enter a new task',
//                 hintStyle: TextStyle(
//                   fontSize: 15,
//                 ),
//                 prefixIcon: IconButton(
//                   icon: Icon(
//                     Icons.task,
//                     color: Colors.black,
//                   ),
//                   onPressed: null,
//                 ),
//                 border: OutlineInputBorder(
//                   borderSide: BorderSide(
//                     color: Color.fromARGB(206, 129, 89, 238),
//                   ),
//                 ),
//               ),
//               onSubmitted: (value) {
//                 addTask(value);
//               },
//             ),
//           ),
//         ],
//       ),
//       drawer: const MainDrawer(),
//     );
//   }

//   Widget buildTaskList(List<Task> taskList) {
//     return ListView.builder(
//       itemCount: taskList.length,
//       itemBuilder: (context, index) {
//         return ListTile(
//           title: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//             margin: const EdgeInsets.all(3.0),
//             decoration: const BoxDecoration(
//               color: Color.fromARGB(206, 129, 89, 238),
//               borderRadius: BorderRadius.all(Radius.circular(10)),
//             ),
//             child: Text(
//               taskList[index].name,
//               style: TextStyle(
//                 decoration: taskList[index].isCompleted
//                     ? TextDecoration.lineThrough
//                     : null,
//                 color: const Color.fromARGB(255, 255, 255, 255),
//                 fontSize: 18.0,
//                 fontWeight: FontWeight.normal,
//               ),
//             ),
//           ),
//           trailing: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               CircleAvatar(
//                 backgroundColor: const Color.fromARGB(206, 129, 89, 238),
//                 radius: 20,
//                 child: IconButton(
//                   icon: const Icon(
//                     Icons.edit,
//                     color: Color.fromARGB(255, 255, 255, 255),
//                   ),
//                   onPressed: () {
//                     // Open a dialog for editing the task
//                     showDialog(
//                       context: context,
//                       builder: (context) {
//                         String editedTask = taskList[index].name;
//                         return AlertDialog(
//                           title: const Text('Edit Task'),
//                           content: TextField(
//                             controller: TextEditingController(
//                                 text: taskList[index].name),
//                             onChanged: (value) {
//                               editedTask = value;
//                             },
//                           ),
//                           actions: [
//                             TextButton(
//                               onPressed: () {
//                                 Navigator.pop(context);
//                               },
//                               child: const Text('Cancel'),
//                             ),
//                             TextButton(
//                               onPressed: () {
//                                 // Update the task
//                                 Task updatedTask = taskList[index];
//                                 updatedTask.name = editedTask;
//                                 updateTask(updatedTask);
//                                 editTask(index, editedTask,
//                                     taskList[index].isCompleted);
//                                 editTask(index, editedTask,
//                                     taskList[index].isCompleted);
//                                 Navigator.pop(context);
//                               },
//                               child: const Text('Save'),
//                             ),
//                           ],
//                         );
//                       },
//                     );
//                   },
//                 ),
//               ),
//               const SizedBox(
//                 width: 10,
//               ),
//               CircleAvatar(
//                 backgroundColor: const Color.fromARGB(206, 129, 89, 238),
//                 radius: 20,
//                 child: IconButton(
//                   icon: const Icon(
//                     Icons.delete,
//                     color: Color.fromARGB(255, 255, 255, 255),
//                   ),
//                   onPressed: () {
//                     // Delete the task
//                     deleteTask(taskList[index]);
//                   },
//                 ),
//               ),
//               const SizedBox(
//                 width: 10,
//               ),
//               CircleAvatar(
//                 backgroundColor: const Color.fromARGB(206, 129, 89, 238),
//                 radius: 20,
//                 child: IconButton(
//                   icon: Icon(
//                     taskList[index].isCompleted
//                         ? Icons.check_box
//                         : Icons.check_box_outline_blank,
//                     color: const Color.fromARGB(255, 255, 255, 255),
//                   ),
//                   onPressed: () {
//                     // Complete the task
//                     Task completedTask = taskList[index];
//                     completedTask.isCompleted = !completedTask.isCompleted;
//                     updateTask(completedTask);
//                   },
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'dart:developer';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter_codes/drawer.dart';
// import 'package:flutter_codes/user_status.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   runApp(const MyApp());
// }

// class Task {
//   String id; // Add a unique identifier for each task
//   String name;
//   bool isCompleted;

//   Task({required this.id, required this.name, this.isCompleted = false});
// }

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key});

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       home: start(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }

// class Home extends StatefulWidget {
//   const Home({Key? key});

//   @override
//   _HomeState createState() => _HomeState();
// }

// class _HomeState extends State<Home> {
//   TextEditingController taskController = TextEditingController();
//   List<Task> tasks = [];
//   List<Task> completedTasks = [];
//   User? user = FirebaseAuth.instance.currentUser;

//   @override
//   void initState() {
//     super.initState();
//     // Load tasks when the widget is first created
//     fetchTasks();
//   }

//   void addTask(String taskName) async {
//     try {
//       // Add the task to the local list
//       Task newTask = Task(id: DateTime.now().toString(), name: taskName);
//       setState(() {
//         tasks.add(newTask);
//         taskController.clear();
//       });

//       // Add the task to Firestore
//       await FirebaseFirestore.instance.collection(user!.uid).add({
//         "Created at": DateTime.now(),
//         "Task": taskName,
//       }).then((value) {
//         // Update the task with the Firestore ID
//         newTask.id = value.id;
//         updateTask(newTask);
//         log("Task added");
//       });
//     } catch (e) {
//       log('Error adding task: $e');
//     }
//   }

//   void deleteTask(Task task) async {
//     try {
//       // Delete the task from Firestore
//       await FirebaseFirestore.instance
//           .collection(user!.uid)
//           .doc(task.id)
//           .delete()
//           .then((value) {
//         // Delete the task from the local list
//         setState(() {
//           tasks.remove(task);
//           completedTasks.remove(task);
//         });
//         log("Task deleted");
//       });
//     } catch (e) {
//       log('Error deleting task from database: $e');
//     }
//   }

//   void updateTask(Task task) async {
//     try {
//       // Update the task in Firestore
//       await FirebaseFirestore.instance
//           .collection(user!.uid)
//           .doc(task.id)
//           .update({
//         "Task": task.name,
//         "IsCompleted": task.isCompleted,
//       }).then((value) {
//         log("Task updated");
//       });
//     } catch (e) {
//       log('Error updating task in database: $e');
//     }
//   }

//   void fetchTasks() async {
//     try {
//       QuerySnapshot<Map<String, dynamic>> querySnapshot =
//           await FirebaseFirestore.instance.collection(user!.uid).get();

//       // Clear existing tasks
//       setState(() {
//         tasks.clear();
//         completedTasks.clear();
//       });

//       querySnapshot.docs.forEach((doc) {
//         Task task = Task(
//           id: doc.id,
//           name: doc["Task"],
//           isCompleted: doc["IsCompleted"] ?? false,
//         );
//         setState(() {
//           if (task.isCompleted) {
//             completedTasks.add(task);
//           } else {
//             tasks.add(task);
//           }
//         });
//       });
//     } catch (e) {
//       log('Error fetching tasks from database: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Schedulo App"),
//         titleTextStyle: const TextStyle(
//           color: Color.fromARGB(255, 255, 255, 255),
//           fontSize: 35.0,
//           fontWeight: FontWeight.bold,
//         ),
//         centerTitle: true,
//         backgroundColor: const Color.fromARGB(206, 129, 89, 238),
//       ),
//       body: Column(
//         children: [
//           Container(
//             margin: const EdgeInsets.all(5),
//             child: const Text(
//               'All Tasks',
//               style: TextStyle(
//                 fontSize: 30.0,
//               ),
//             ),
//           ),
//           Expanded(
//             child: DefaultTabController(
//               length: 2,
//               child: Column(
//                 children: [
//                   const TabBar(
//                     tabs: [
//                       Tab(text: 'Incomplete'),
//                       Tab(text: 'Completed'),
//                     ],
//                   ),
//                   Expanded(
//                     child: TabBarView(
//                       children: [
//                         buildTaskList(tasks),
//                         buildTaskList(tasks),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.all(8.0),
//             margin: const EdgeInsets.all(10.0),
//             child: TextField(
//               controller: taskController,
//               decoration: const InputDecoration(
//                 hintText: 'Enter a new task',
//                 hintStyle: TextStyle(
//                   fontSize: 15,
//                 ),
//                 prefixIcon: IconButton(
//                   icon: Icon(
//                     Icons.task,
//                     color: Colors.black,
//                   ),
//                   onPressed: null,
//                 ),
//                 border: OutlineInputBorder(
//                   borderSide: BorderSide(
//                     color: Color.fromARGB(206, 129, 89, 238),
//                   ),
//                 ),
//               ),
//               onSubmitted: (value) {
//                 addTask(value);
//               },
//             ),
//           ),
//         ],
//       ),
//       drawer: const MainDrawer(),
//     );
//   }

//   Widget buildTaskList(List<Task> taskList) {
//     return ListView.builder(
//       itemCount: taskList.length,
//       itemBuilder: (context, index) {
//         return ListTile(
//           title: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//             margin: const EdgeInsets.all(3.0),
//             decoration: const BoxDecoration(
//               color: Color.fromARGB(206, 129, 89, 238),
//               borderRadius: BorderRadius.all(Radius.circular(10)),
//             ),
//             child: Text(
//               taskList[index].name,
//               style: TextStyle(
//                 decoration: taskList[index].isCompleted
//                     ? TextDecoration.lineThrough
//                     : null,
//                 color: const Color.fromARGB(255, 255, 255, 255),
//                 fontSize: 18.0,
//                 fontWeight: FontWeight.normal,
//               ),
//             ),
//           ),
//           trailing: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               CircleAvatar(
//                 backgroundColor: const Color.fromARGB(206, 129, 89, 238),
//                 radius: 20,
//                 child: IconButton(
//                   icon: const Icon(
//                     Icons.edit,
//                     color: Color.fromARGB(255, 255, 255, 255),
//                   ),
//                   onPressed: () {
//                     // Open a dialog for editing the task
//                     showDialog(
//                       context: context,
//                       builder: (context) {
//                         String editedTask = taskList[index].name;
//                         return AlertDialog(
//                           title: const Text('Edit Task'),
//                           content: TextField(
//                             controller: TextEditingController(
//                                 text: taskList[index].name),
//                             onChanged: (value) {
//                               editedTask = value;
//                             },
//                           ),
//                           actions: [
//                             TextButton(
//                               onPressed: () {
//                                 Navigator.pop(context);
//                               },
//                               child: const Text('Cancel'),
//                             ),
//                             TextButton(
//                               onPressed: () {
//                                 // Update the task
//                                 Task updatedTask = taskList[index];
//                                 updatedTask.name = editedTask;
//                                 updateTask(updatedTask);
//                                 Navigator.pop(context);
//                               },
//                               child: const Text('Save'),
//                             ),
//                           ],
//                         );
//                       },
//                     );
//                   },
//                 ),
//               ),
//               const SizedBox(
//                 width: 10,
//               ),
//               CircleAvatar(
//                 backgroundColor: const Color.fromARGB(206, 129, 89, 238),
//                 radius: 20,
//                 child: IconButton(
//                   icon: const Icon(
//                     Icons.delete,
//                     color: Color.fromARGB(255, 255, 255, 255),
//                   ),
//                   onPressed: () {
//                     // Delete the task
//                     deleteTask(taskList[index]);
//                   },
//                 ),
//               ),
//               const SizedBox(
//                 width: 10,
//               ),
//               CircleAvatar(
//                 backgroundColor: const Color.fromARGB(206, 129, 89, 238),
//                 radius: 20,
//                 child: IconButton(
//                   icon: Icon(
//                     taskList[index].isCompleted
//                         ? Icons.check_box
//                         : Icons.check_box_outline_blank,
//                     color: const Color.fromARGB(255, 255, 255, 255),
//                   ),
//                   onPressed: () {
//                     // Complete the task
//                     Task completedTask = taskList[index];
//                     completedTask.isCompleted = !completedTask.isCompleted;
//                     updateTask(completedTask);
//                   },
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
