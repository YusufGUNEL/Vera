import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/category_budget_store.dart';

class CategoryBudgetController extends StateNotifier<Map<String, double>> {
  CategoryBudgetController(this._store) : super(const {}) {
    _bootstrap();
  }

  final CategoryBudgetStore _store;

  Future<void> _bootstrap() async {
    state = await _store.load();
  }

  Future<void> setLimit(String category, double limit) async {
    state = await _store.setLimit(category, limit);
  }

  Future<void> reset() async {
    await _store.clear();
    state = await _store.load();
  }
}

final categoryBudgetControllerProvider =
    StateNotifierProvider<CategoryBudgetController, Map<String, double>>((ref) {
  return CategoryBudgetController(ref.watch(categoryBudgetStoreProvider));
});
