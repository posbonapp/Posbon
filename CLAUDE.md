# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```
flutter pub get                 # install dependencies
flutter gen-l10n                # regenerate lib/l10n/app_localizations*.dart from the .arb files
flutter analyze                 # static analysis (flutter_lints)
flutter run                     # run on a connected device/emulator
flutter build apk|ios|web ...   # platform build
flutter test                    # run tests (see note below — the only test is the unedited template)
```

There is a single test file, `test/widget_test.dart`, and it is still the default `flutter create` counter-app template — it pumps a non-existent `MyApp` widget (the real root widget is `PosbonApp` in `lib/main.dart`) and asserts on counter text that doesn't exist anywhere in this app. It will fail if run as-is; either fix/replace it or be aware `flutter test` is not currently a meaningful signal.

Supabase edge functions live under `supabase/functions/*/index.ts` (Deno) and are deployed with the Supabase CLI (`supabase functions deploy <name>`), not with Flutter tooling. There is no `supabase/migrations` directory in this repo, so the Postgres schema/RPCs are managed outside of what's checked in here.

## Architecture

**Stack**: Flutter app, Supabase (Postgres + Auth + Realtime + RPC) as the primary backend, Firebase (Cloud Messaging + `flutter_local_notifications`) used *only* for push notifications — auth and all data live in Supabase, not Firebase.

**Entry / role-based gating** (`lib/main.dart`): `PosbonApp` renders `AuthGate`, which watches `supabase.auth.onAuthStateChange`. No session → `AuthScreen`. With a session, `ProfileGate` fetches the caller's row from `profiles` and branches purely on `profile['role']`:
- `admin` → `HomeScreen`, unless `building_id` is null, in which case `SetupBuildingScreen` (onboarding) is shown first.
- `worker` → `WorkerHomeScreen`.
- anything else (tenant) → `TenantRootScreen`.

Each of these three root screens is its own bottom-nav shell (`IndexedStack` + `NavigationBar`) hosting role-specific screens from `lib/screens/`. There is no shared router config to look at — the role branch above is the entire routing story.

**No routing/state-management libraries despite being in `pubspec.yaml`**: `go_router` and `flutter_riverpod` are declared dependencies but unused in `lib/`. Actual navigation is plain `Navigator.push(MaterialPageRoute(...))`, and all state is `StatefulWidget`/`setState`. Don't assume either library is wired up — grep before relying on it.

**Data access has no service/repository layer**: screens talk to the global `supabase` client (instantiated once in `main.dart` as `final supabase = Supabase.instance.client;`) directly in their `State` classes — queries, mutations, and Realtime subscriptions all live inline in the screen widgets. Privileged/multi-step writes go through Postgres RPCs via `supabase.rpc('name', params: {...})` (e.g. `reserve_item`, `release_item`, `accept_task`, `buy_purchase_item`, `save_device_token`) rather than raw table writes; those RPC functions themselves are defined in the Supabase project, not in this repo. Live counters/badges use `supabase.channel(...).onPostgresChanges(...)` (see `home_screen.dart`), and channels must be removed in `dispose()`.

**Push notifications** (`lib/notifications.dart`): `Notifications.setup()` is called from `ProfileGate` after the profile loads. It requests permission, initializes `flutter_local_notifications` for foreground display, registers an FCM background handler, and syncs the device's FCM token to the `device_tokens` table (via the `save_device_token` RPC) whenever the user signs in or the token refreshes. Server-side, Supabase edge functions (`notify-task`, `notify-request`) are triggered by DB webhooks, look up tokens in `device_tokens`, and call the `send-push` function to actually deliver via FCM.

**Localization**: `lib/l10n/app_{en,ru,fr}.arb` are the source strings (`app_en.arb` is the template per `l10n.yaml`); `flutter gen-l10n` (run automatically on build because `flutter.generate: true` in `pubspec.yaml`) produces `lib/l10n/app_localizations*.dart`. Runtime locale override (independent of device locale) is persisted via `LocaleProvider` (`lib/locale_provider.dart`, a `ChangeNotifier` backed by `shared_preferences`) and applied at the `MaterialApp` level in `main.dart`.

**Inventory icon/keyword mapping** (`lib/icons.dart`): `kIcons` maps string keys (stored in the DB) to `IconData`, and `guessIcon(name)` auto-classifies a free-text item name into one of those keys by matching Russian/English/French keyword substrings — used wherever stock/inventory items are created or displayed (e.g. `stock_screen.dart`, `purchase_screen.dart`).

**Config** (`lib/config.dart`): Supabase URL and anon key are hardcoded constants (no `.env`/`--dart-define`). `lib/firebase_options.dart` is the FlutterFire-generated platform config.
