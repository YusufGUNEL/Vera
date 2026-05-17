import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/localization/locale_controller.dart';
import '../../../core/services/gemini_service.dart';
import '../../../core/utils/formatters.dart';
import '../data/category_summary.dart';
import 'home_controller.dart';

class SpendingInsightState {
  const SpendingInsightState({
    this.text = '',
    this.loading = false,
    this.source = InsightSource.none,
  });

  final String text;
  final bool loading;
  final InsightSource source;

  SpendingInsightState copyWith({
    String? text,
    bool? loading,
    InsightSource? source,
  }) {
    return SpendingInsightState(
      text: text ?? this.text,
      loading: loading ?? this.loading,
      source: source ?? this.source,
    );
  }
}

enum InsightSource { none, heuristic, gemini }

/// Generates a short, real-data Uma insight for the Home screen.
///
/// 1) Always emits a heuristic line instantly so the strip is never blank.
/// 2) When Gemini is configured AND the user actually has transactions, asks
///    Gemini for a richer 1-2 sentence summary in the background and swaps it
///    in. Failures fall through quietly to the heuristic.
class SpendingInsightController extends StateNotifier<SpendingInsightState> {
  SpendingInsightController(this._gemini, this._ref)
      : super(const SpendingInsightState()) {
    _homeSub = _ref.listen(homeControllerProvider, (_, next) {
      _recompute(next.transactions, next.banks.length);
    }, fireImmediately: true);
    _localeSub = _ref.listen(localeControllerProvider, (_, __) {
      final home = _ref.read(homeControllerProvider);
      _recompute(home.transactions, home.banks.length);
    });
  }

  final GeminiService _gemini;
  final Ref _ref;
  ProviderSubscription<dynamic>? _homeSub;
  ProviderSubscription<dynamic>? _localeSub;
  int _generation = 0;

  Future<void> _recompute(List<dynamic> txnsRaw, int bankCount) async {
    final txns = txnsRaw.cast<dynamic>();
    final generation = ++_generation;
    final l10n = _ref.read(stringsProvider);

    if (txns.isEmpty) {
      state = SpendingInsightState(
        text: bankCount == 0
            ? l10n.umaInsightNoData
            : l10n.umaInsightNoTransactions,
        source: InsightSource.heuristic,
      );
      return;
    }

    final spending = summarizeSpending(txns.cast(), otherLabel: 'Diğer');
    final total = totalSpending(spending);

    final heuristic = _heuristicSummary(
      spending: spending,
      total: total,
      l10n: l10n,
    );
    state = SpendingInsightState(
      text: heuristic,
      source: InsightSource.heuristic,
    );

    if (!_gemini.isAvailable || spending.isEmpty) return;
    state = state.copyWith(loading: true);
    try {
      final prompt = _buildPrompt(spending: spending, total: total);
      final raw = await _gemini.generateText(prompt);
      if (generation != _generation) return;
      final clean = raw.trim();
      if (clean.isNotEmpty) {
        state = SpendingInsightState(
          text: clean,
          loading: false,
          source: InsightSource.gemini,
        );
      } else {
        state = state.copyWith(loading: false);
      }
    } catch (_) {
      if (generation != _generation) return;
      state = state.copyWith(loading: false);
    }
  }

  Future<void> refresh() async {
    final home = _ref.read(homeControllerProvider);
    await _recompute(home.transactions, home.banks.length);
  }

  String _heuristicSummary({
    required List<CategorySpend> spending,
    required double total,
    required AppStrings l10n,
  }) {
    if (spending.isEmpty) {
      return l10n.umaInsightNoPattern;
    }
    final top = spending.first;
    final share = total <= 0 ? 0 : ((top.amount / total) * 100).round();
    return l10n.umaInsightTopCategory(
      top.category,
      fmtTL(top.amount),
      share,
      fmtTL(total),
    );
  }

  String _buildPrompt({
    required List<CategorySpend> spending,
    required double total,
  }) {
    final byCat = spending
        .map((s) => '${s.category}=${s.amount.toStringAsFixed(0)} TL')
        .join(', ');
    return '''
Sen Vera mobil finans uygulamasının AI koçu Uma'sın. Kullanıcının son
işlemlerinden gelen harcama özetine kısa, sıcak, eyleme dönük 1-2 cümle
yorum yaz. Türkçe. TL para birimi. Sayıları tekrar etme; sadece anlamı söyle.
Bir tasarruf veya dikkat önerisi ekle. Tahmini bir banka ismi veya işlem
adı uydurmama izin verme.

Toplam analiz edilen harcama: ${total.toStringAsFixed(0)} TL.
Kategorilere göre: $byCat.

Yorum:''';
  }

  @override
  void dispose() {
    _homeSub?.close();
    _localeSub?.close();
    super.dispose();
  }
}

final spendingInsightControllerProvider =
    StateNotifierProvider<SpendingInsightController, SpendingInsightState>((ref) {
  return SpendingInsightController(
    ref.watch(geminiServiceProvider),
    ref,
  );
});
