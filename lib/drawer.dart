import "package:flutter/material.dart";
import 'package:flutter_codes/login_page.dart';
import 'package:flutter_codes/maths.dart';
//import './incomplete_list.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(20),
                bottom: Radius.circular(20),
              ),
              color: Colors.teal,
            ),
            child: Center(
              child: Text(
                'Menu',
                style: TextStyle(
                  fontSize: 30.0,
                ),
              ),
            ),
          ),
          ListTile(
            title: const Text('Add Task'),
            leading: const Icon(Icons.add),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Maths'),
            leading: const Icon(Icons.calculate),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: ((context) => const Maths())));
            },
          ),
          // ListTile(
          //   title: const Text('Completed Task List'),
          //   onTap: () {
          //     Navigator.pop(context);
          //   },
          //   leading: const Icon(Icons.done),
          // ),
          // ListTile(
          //   title: const Text('Incomplete Task List'),
          //   leading: const Icon(Icons.incomplete_circle_rounded),
          //   onTap: () {
          //     Navigator.push(
          //         context,
          //         MaterialPageRoute(
          //             builder: ((context) => const Incomplete())));
          //   },
          // ),
          ListTile(
            title: const Text('Logout'),
            onTap: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: ((context) => const Login())));
            },
            leading: const Icon(Icons.logout),
          ),
        ],
      ),
    );
  }
}
