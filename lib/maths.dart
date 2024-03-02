import 'package:flutter/material.dart';
import 'package:flutter_codes/history.dart';
import 'package:flutter_codes/result_page.dart';
import "calres.dart";
import 'package:provider/provider.dart';

class Maths extends StatefulWidget {
  const Maths({super.key});

  @override
  State<Maths> createState() => _MathsState();
}

class _MathsState extends State<Maths> {
  TextEditingController controller1 = TextEditingController();
  TextEditingController controller2 = TextEditingController();
  int? result = 0, num1 = 0, num2 = 0;

  void add() {
    setState(() {
      num1 = int.parse(controller1.text);
      num2 = int.parse(controller2.text);
      result = num1! + num2!;
      addToHistory('Addition: $num1 + $num2', result!);
    });
  }

  void subtract() {
    setState(() {
      num1 = int.parse(controller1.text);
      num2 = int.parse(controller2.text);
      result = num1! - num2!;
      addToHistory('Subtraction: $num1 - $num2', result!);
    });
  }

  void multiply() {
    setState(() {
      num1 = int.parse(controller1.text);
      num2 = int.parse(controller2.text);
      result = num1! * num2!;
      addToHistory('Multiplication: $num1 * $num2', result!);
    });
  }

  void divide() {
    setState(() {
      num1 = int.parse(controller1.text);
      num2 = int.parse(controller2.text);
      result = num1! ~/ num2!;
      addToHistory('Division: $num1 ~/ $num2', result!);
    });
  }

  // void refresh() {
  //   setState(() {
  //     result = 0;
  //   });
  // }

  void addToHistory(String operation, int result) {
    Provider.of<CalculationHistoryProvider>(context, listen: false)
        .addToHistory(operation, result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Calculator"),
        titleTextStyle: const TextStyle(
          color: Color.fromARGB(255, 255, 255, 255),
          fontSize: 35.0,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(206, 129, 89, 238),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Container(
            //   margin: const EdgeInsets.all(5),
            //   child: const Text(
            //     'Calculator',
            //     style: TextStyle(
            //       fontSize: 30.0,
            //     ),
            //   ),
            // ),
            Image.network(
              'https://as1.ftcdn.net/v2/jpg/03/99/26/94/1000_F_399269495_bJ4PMquuKOXXHnc7evLzfM4pLeWQy7zQ.jpg',
              height:
                  280, // Aap apni pasand ke anusaar height aur width set kar sakte hain
              width: 350, // Yeh image ka width screen ke width ke barabar hogi
              fit: BoxFit
                  .cover, // Yeh image ko container ke saath fit karne ke liye hai
            ),
            // const SizedBox(
            //   height: 100,
            // ),
            Container(
              padding: const EdgeInsets.all(8.0),
              margin: const EdgeInsets.all(10.0),
              child: TextField(
                controller: controller1,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Enter 1st number',
                  hintStyle: TextStyle(
                    fontSize: 15,
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color.fromARGB(206, 129, 89, 238),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8.0),
              margin: const EdgeInsets.all(10.0),
              child: TextField(
                controller: controller2,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Enter 2nd number',
                  hintStyle: TextStyle(
                    fontSize: 15,
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color.fromARGB(206, 129, 89, 238),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    onPressed: () {
                      add();
                      Provider.of<CalculationResultProvider>(context,
                              listen: false)
                          .setCalculationResult(result);
                      controller1.clear();
                      controller2.clear();
                    },
                    child: const Text(
                      'ADD',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )),
                ElevatedButton(
                    onPressed: () {
                      subtract();
                      Provider.of<CalculationResultProvider>(context,
                              listen: false)
                          .setCalculationResult(result);
                      controller1.clear();
                      controller2.clear();
                    },
                    child: const Text(
                      'Subtract',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )),
                ElevatedButton(
                    onPressed: () {
                      multiply();
                      Provider.of<CalculationResultProvider>(context,
                              listen: false)
                          .setCalculationResult(result);
                      controller1.clear();
                      controller2.clear();
                    },
                    child: const Text(
                      'Multiply',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )),
                ElevatedButton(
                    onPressed: () {
                      divide();
                      Provider.of<CalculationResultProvider>(context,
                              listen: false)
                          .setCalculationResult(result);
                      controller1.clear();
                      controller2.clear();
                    },
                    child: const Text(
                      'Divide',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ))
              ],
            ),
            const SizedBox(
              height: 30,
            ),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: ((context) => const ResultPage())));
                  },
                  child: const Text(
                    'Result',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: ((context) => History())));
                  },
                  child: const Text(
                    'History',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
            ]),
            // const SizedBox(
            //   height: 20,
            // ),
            // const Padding(padding: EdgeInsets.all(10)),
            // Column(
            //   children: [
            //     Text(
            //       'Result : $result',
            //       style:
            //           const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            //     )
            //   ],
            // )
          ],
        ),
      ),
    );
  }
}
