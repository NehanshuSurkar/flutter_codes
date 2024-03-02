import 'package:flutter/material.dart';
import 'package:flutter_codes/calres.dart';
import 'package:provider/provider.dart';

class History extends StatelessWidget {
  const History({super.key});

  @override
  Widget build(BuildContext context) {
    List<CalculationHistoryItem> history =
        Provider.of<CalculationHistoryProvider>(context).history;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Calculation History"),
        titleTextStyle: const TextStyle(
          color: Color.fromARGB(255, 255, 255, 255),
          fontSize: 25.0,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(206, 129, 89, 238),
      ),
      body: ListView.builder(
        itemCount: history.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(history[index].operation),
            subtitle: Text('Result: ${history[index].result}'),
          );
        },
      ),
    );
  }
}



// class History extends StatefulWidget {
//   const History({super.key});

//   @override
//   State<History> createState() => _HistoryState();
// }

// class _HistoryState extends State<History> {
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
//             margin: const EdgeInsets.symmetric(horizontal: 150),
//             //padding: EdgeInsets.all(50),
//             child: const Text(
//               'History',
//               style: TextStyle(
//                 fontSize: 30.0,
//               ),
//             ),
//           ),
//           const SizedBox(
//             height: 30,
//           ),
//           Container(
//             child: const Text(''),
//           )
//         ],
//       ),
//     );
//   }
// }
