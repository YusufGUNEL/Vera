import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/upcoming_bill.dart';
import '../data/upcoming_bills_store.dart';

class UpcomingBillsController extends StateNotifier<List<UpcomingBill>> {
  UpcomingBillsController(this._store) : super(const []) {
    _bootstrap();
  }

  final UpcomingBillsStore _store;

  Future<void> _bootstrap() async {
    final loaded = await _store.load();
    if (!mounted) return;
    state = loaded;
  }

  Future<void> refresh() async {
    final loaded = await _store.load();
    if (!mounted) return;
    state = loaded;
  }

  Future<void> add(UpcomingBill bill) async {
    final next = await _store.add(bill);
    if (!mounted) return;
    state = next;
  }

  Future<void> update(UpcomingBill bill) async {
    final next = await _store.update(bill);
    if (!mounted) return;
    state = next;
  }

  Future<void> remove(String id) async {
    final next = await _store.remove(id);
    if (!mounted) return;
    state = next;
  }

  Future<void> clear() async {
    await _store.clear();
    if (!mounted) return;
    state = const [];
  }
}

final upcomingBillsControllerProvider =
    StateNotifierProvider<UpcomingBillsController, List<UpcomingBill>>((ref) {
  return UpcomingBillsController(ref.watch(upcomingBillsStoreProvider));
});
