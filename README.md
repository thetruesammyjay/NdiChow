# NdiChow Mobile

NdiChow is the Flutter customer app for discovering restaurants and ordering food. It keeps the existing bright coral design language, custom PP Neue Machina typography, offline Basil icons, and Lottie/Rive animation support while connecting discovery to the NdiChow API.

The TypeScript API is maintained separately in [NdiChow-backend](https://github.com/thetruesammyjay/NdiChow-backend).

## Current capabilities

- Material 3 theme and responsive four-tab shell
- Home discovery with loading, error, and pull-to-refresh states
- Live restaurant listing and search through the backend
- Typed restaurant JSON mapping
- Home, Search, Orders, and Profile foundations
- Bundled SVG icons and animation assets
- Debug-only local HTTP access; HTTPS enforced for release API configuration
- CI formatting, analysis, and widget tests

Restaurant details, cart, authentication screens, secure session storage, checkout, payments, and live order tracking are the next product layers.

## Requirements

- Flutter stable with Dart 3.7 or newer
- Android Studio for Android, or Xcode for iOS
- A running NdiChow backend

Check your setup with `flutter doctor`.

## Local setup

```bash
git clone https://github.com/thetruesammyjay/NdiChow.git
cd NdiChow
flutter pub get
```

Copy the public build-time configuration template:

```bash
cp dart_defines.example.json dart_defines.json
```

Start the backend on port 4000, then run:

```bash
flutter run --dart-define-from-file=dart_defines.json
```

The template targets `http://10.0.2.2:4000/api/v1`, which reaches the host machine from an Android emulator. For an iOS simulator use `http://127.0.0.1:4000/api/v1`. A physical device needs the development machine's reachable LAN address or an HTTPS development tunnel.

Local cleartext traffic is allowed only by Android debug resources and iOS debug build settings. Release builds require an HTTPS `API_BASE_URL`.

## Build-time configuration

| Define | Default | Purpose |
| --- | --- | --- |
| `API_BASE_URL` | `http://10.0.2.2:4000/api/v1` | Versioned backend base URL |
| `APP_ENV` | `development` | Environment label |

Flutter defines are compiled into the application and are not secrets. Never put database URLs, payment secret keys, signing credentials, or server credentials in this repository or configuration file.

Example production build:

```bash
flutter build appbundle \
  --dart-define=APP_ENV=production \
  --dart-define=API_BASE_URL=https://api.example.com/api/v1
```

## Architecture

```text
lib/
|-- core/
|   |-- config/       Build-time application configuration
|   |-- networking/   HTTP transport and stable API errors
|   |-- navigation/   Root application shell
|   `-- theme/        Colors, typography, and component themes
|-- features/
|   |-- cart/
|   |-- home/         Repository and discovery presentation
|   |-- orders/
|   |-- profile/
|   `-- search/
|-- shared/
|   |-- models/       Typed cross-feature models
|   `-- widgets/      Icons, animations, and reusable cards
`-- main.dart
```

Screens receive repositories instead of making HTTP calls directly. `HttpHomeRepository` is used by the running app and `MockHomeRepository` keeps widget tests deterministic.

## API contract

Discovery currently uses:

```http
GET /api/v1/restaurants?page=1&limit=20
GET /api/v1/restaurants?q=jollof
GET /api/v1/restaurants/:restaurantId
```

Success responses use `{ "data": ... }`; failures use `{ "error": { "code": "...", "message": "..." } }`. The app maps backend error codes to safe user-facing states.

Authenticated endpoints use `Authorization: Bearer <session-token>`. When checkout is implemented, the app must submit only menu item IDs, quantities, notes, an address, and a unique `Idempotency-Key`. Prices and delivery fees are always calculated by the server.

## Common commands

```bash
flutter pub get
dart format lib test
flutter analyze
flutter test
flutter run --dart-define-from-file=dart_defines.json
flutter build apk --dart-define-from-file=dart_defines.json
flutter build appbundle --dart-define-from-file=dart_defines.json
flutter build ios --no-codesign --dart-define-from-file=dart_defines.json
```

## Android signing

Unsigned/local release builds do not require a keystore. To sign a store build, add these values to `android/local.properties` without committing them:

```properties
MYAPP_UPLOAD_STORE_FILE=C:\\path\\to\\upload-keystore.jks
MYAPP_UPLOAD_STORE_PASSWORD=replace-me
MYAPP_UPLOAD_KEY_ALIAS=upload
MYAPP_UPLOAD_KEY_PASSWORD=replace-me
```

## Testing and CI

GitHub Actions runs dependency resolution, formatting checks, static analysis, and widget tests on pushes to `main` and pull requests. Add unit tests for parsing and controllers, widget tests for every UI state, and integration tests for authentication and checkout as those features land.

## Security rules

- Store session tokens with a platform secure-storage package when authentication UI is added.
- Treat every value embedded in the app as public.
- Never calculate authoritative order totals on the device.
- Require HTTPS in staging and production.
- Do not log tokens, addresses, or payment details.
- Verify payments and webhook signatures only on the backend.

## Roadmap

- [x] Branded Flutter foundation and asset integration
- [x] HTTP restaurant discovery and search
- [x] Debug/release network policy separation
- [ ] Restaurant detail and categorized menu
- [ ] Sign-up, sign-in, logout, and secure session persistence
- [ ] Address management and delivery eligibility
- [ ] Cart, customization, and idempotent checkout
- [ ] Payment provider integration
- [ ] Active order timeline and notifications
- [ ] Accessibility, localization, and store-release audit

## License

Copyright © 2026 NdiChow. All rights reserved unless a separate license is added.
