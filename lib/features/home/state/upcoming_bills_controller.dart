import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/upcoming_bill.dart';
import '../data/upcoming_bills_store.dart';

class UpcomingBillsController extends StateNotifier<List<UpcomingBill>> {
  UpcomingBillsController(this._store) : super(const []) {
    _bootstrap();
  }

  final UpcomingBillsStore _store;

  Future<void> _bootstrap() async {
    state = await _store.load();
  }

  Future<void> refresh() async {
    state = await _store.load();
  }

  Future<void> add(UpcomingBill bill) async {
    state = await _store.add(bill);
  }

  Future<void> update(UpcomingBill bill) async {
    state = await _store.update(bill);
  }

  Future<void> remove(String id) async {
    state = await _store.remove(id);
  }

  Future<void> clear() async {
    await _store.clear();
    state = const [];
  }
}

final upcomingBillsControllerProvider =
    StateNotifierProvider<UpcomingBillsController, List<UpcomingBill>>((ref) {
  return UpcomingBillsController(ref.watch(upcomingBillsStoreProvider));
});
