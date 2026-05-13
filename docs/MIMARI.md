# Mimari

Tek doc — klasor yapisi, paralel calisma, yeni feature ekleme.

## Felsefe: feature-first

Her ekran bir feature klasoru. Bir feature **kendi modeli, state'i, ekrani** ile birlikte tek yerde durur. Sen `wealth/`'da, arkadasin `credit/`'de calisirsa **hicbir dosyada bulusmazsiniz** → merge conflict yok.

## Klasor yapisi

```
lib/
├── main.dart                       # Giris noktasi
├── app.dart                        # MaterialApp + tema + router
│
├── core/                           # ORTAK ALTYAPI (dokunurken konus)
│   ├── theme/                      # Renk, font, tweaks (palette/mood/vibe)
│   ├── routing/                    # go_router config
│   ├── services/                   # Disariya cikan tek dokunma noktalari (Gemini)
│   ├── config/                     # .env okuma
│   └── utils/                      # fmtTL gibi kucuk yardimcilar
│
├── shared/widgets/                 # Birden fazla feature'da kullanilan widget
│   ├── app_shell.dart              # Bottom nav + FAB
│   ├── vera_card.dart, pill.dart, ...
│
└── features/<feature>/             # Her feature izole
    ├── domain/                     # (opsiyonel) Saf veri modelleri
    ├── data/                       # (opsiyonel) Repository / mock data
    ├── state/                      # (opsiyonel) Riverpod controller
    └── presentation/
        ├── <feature>_screen.dart   # Ekranin kendisi
        └── widgets/                # Sadece o ekrana ait BUYUK parçalar
```

`domain/`, `data/`, `state/`, `widgets/` **opsiyonel** — basit feature'da sadece `presentation/<feature>_screen.dart` yeterli.

## Dosya bolme kurali (en cok karistirilan kisim)

Bir ekran widget'ini ne zaman ayri dosyaya cikar?

**Ayri dosya** olsun:
- Birden fazla yerde kullaniliyor → `shared/widgets/`
- Cidden buyuk/karmasik (custom paint, kendi state'i, 150+ satir gercek logic)
- Kendi data/repository'si var (ornek: `connected_banks` Bank modelini tasiyor)

**Ayni dosyada** kalsin:
- Sadece o ekrana ozgu, kucuk UI parcasi → ekran dosyasi icinde **private class** (`_Header`, `_StatChip`) olarak yaz.

Ornek: `wealth_screen.dart` 380 satir, icinde `_Header`, `_ActivityRow`, `_SmallBtn` private class'lari var. Sadece `portfolio_donut.dart` (custom SVG painter) ayri dosyada.

Hedef: bir ekran dosyasi 250-400 satir bandinda olsun. 500+ ise gercekten parcala.

## Paralel calisma

| Bolge | Kim dokunabilir | Kural |
|---|---|---|
| `lib/features/<X>/` | O feature'i alan kisi | Once paylasin: sen `wealth`, arkadasin `credit` |
| `lib/core/`, `lib/shared/` | Herkes | Once mesajlas ("ben app_shell'a tab ekliyorum") |
| `pubspec.yaml` | Herkes | Once mesajlas |

Git ile her feature kendi branch'inde, PR ile merge → conflict riski sifira yakin.

## Yeni feature nasil eklenir

Diyelim `notifications` ekliyorsun.

**1.** Klasor: `lib/features/notifications/presentation/notifications_screen.dart`. Karmasiksa `domain/`, `data/`, `state/` ekle.

**2.** Rota: `lib/core/routing/routes.dart`'a sabit ekle, `app_router.dart`'taki `ShellRoute` icine `GoRoute` ekle.

**3.** (Bottom nav'a girecekse) `lib/shared/widgets/app_shell.dart`'taki `_tabs` listesine ekle. Modal/sheet olarak acilacaksa atla — `showModalBottomSheet` yeter (ornek: `profile_settings_sheet`).

**4.** State varsa Riverpod controller olustur. Patern `lib/features/uma_chat/state/uma_controller.dart`'ta — kopyala.

## State management: Riverpod

- Sayfa state'i → `StateNotifierProvider<XController, XState>`
- Tek deger → `StateProvider<T>`
- Read-only servis → `Provider<T>`

Widget'ta:

```dart
class FooScreen extends ConsumerWidget {
  Widget build(BuildContext ctx, WidgetRef ref) {
    final state = ref.watch(fooControllerProvider);          // izle
    final ctrl  = ref.read(fooControllerProvider.notifier);  // metod cagir
  }
}
```

## Tema (tweaks)

Renk/spacing **hardcode etme**. `context.tokens` kullan:

```dart
final t = context.tokens;
Container(color: t.card, padding: EdgeInsets.all(t.vibe.cardPadding));
```

Token icerigi: `brand`, `uma`, `bg`, `card`, `ink`, `muted`, `line`, `green/red/blue/gold`, `vibe.radius`, ... Palette/mood/vibe degisince hepsi otomatik guncellenir.

Istisna — hardcoded kalmasi GEREKEN renkler:
- Banka logosu (Garanti yesili, Akbank kirmizisi) — gercek marka rengi
- Kategori ikonu (groceries amber, food brown) — semantik kimlik
- Credit gauge segment renkleri — skor anlami

## Kisa kurallar

- `Color(0xFF...)` veya magic number gorursen `core/theme/`'e tasimaya bak.
- `BuildContext`'i async sonrasi kullanirken `if (!context.mounted) return;`.
- `ConsumerWidget` tercih et, `ConsumerStatefulWidget` sadece local state varsa.
- Commit oncesi: `flutter analyze && dart format lib/`.

Gemini icin → [GEMINI.md](GEMINI.md).
