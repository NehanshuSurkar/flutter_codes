import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_codes/calres.dart'; // Import your calculation result provider class

class ResultPage extends StatelessWidget {
  const ResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    CalculationResult? calculationResult =
        Provider.of<CalculationResultProvider>(context).calculationResult;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Result Page'),
      ),
      body: Center(
        child: calculationResult != null
            ? Text(
                'Result: ${calculationResult.result}',
                style: const TextStyle(fontSize: 24),
              )
            : const Text('No result available'),
      ),
    );
  }
}
