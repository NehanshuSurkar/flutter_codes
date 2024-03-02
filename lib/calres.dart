import 'package:flutter/material.dart';

class CalculationResult {
  final int? result;
  CalculationResult(this.result);
}

class CalculationResultProvider extends ChangeNotifier {
  CalculationResult? _calculationResult;

  CalculationResult? get calculationResult => _calculationResult;

  void setCalculationResult(int? result) {
    _calculationResult = CalculationResult(result);
    notifyListeners();
  }
}

// calculation history classes
class CalculationHistoryItem {
  final String operation;
  final int result;

  CalculationHistoryItem({required this.operation, required this.result});
}

class CalculationHistoryProvider extends ChangeNotifier {
  final List<CalculationHistoryItem> _history = [];

  List<CalculationHistoryItem> get history => _history;

  void addToHistory(String operation, int result) {
    _history.add(CalculationHistoryItem(operation: operation, result: result));
    notifyListeners();
  }
}
