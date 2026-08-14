# NdiChow Mobile

NdiChow is the Flutter customer app for discovering restaurants and ordering food. It keeps the existing bright coral design language, custom PP Neue Machina typography, offline Basil icons, and Lottie/Rive animation support while connecting discovery to the NdiChow API.

The TypeScript API is maintained separately in [NdiChow-backend](https://github.com/thetruesammyjay/NdiChow-backend).

## Current capabilities

- Material 3 theme and responsive four-tab shell
- Home discovery with loading, error, and pull-to-refresh states
- Live restaurant listing and search through the backend
- Email/password registration, sign-in, session restoration, and logout
- Opaque bearer tokens stored with platform secure storage
- Restaurant details with categorized, availability-aware menus
- One-restaurant cart with quantities, notes, minimum-order checks, and estimated totals
- Address checkout with retry-safe idempotency keys and server-confirmed totals
- Live order history, detail, pull-to-refresh, and status timeline
- Typed customer, restaurant, menu, cart, and order models
- Bundled SVG icons and animation assets
- Debug-only local HTTP access; HTTPS enforced for release API configuration
- CI formatting, analysis, and widget tests

Payments, saved addresses, delivery-zone eligibility, push notifications, and realtime tracking require the next backend phase.

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
|   |-- auth/         Secure sessions and account presentation
|   |-- home/         Repository and discovery presentation
|   |-- orders/
|   |-- profile/
|   |-- restaurants/ Restaurant detail and categorized menu
|   `-- search/
|-- shared/
|   |-- models/       Typed cross-feature models
|   `-- widgets/      Icons, animations, and reusable cards
`-- main.dart
```

Screens receive repositories instead of making HTTP calls directly. `HttpHomeRepository` is used by the running app and `MockHomeRepository` keeps widget tests deterministic.

## API contract

The customer ordering flow currently uses:

```http
GET /api/v1/restaurants?page=1&limit=20
GET /api/v1/restaurants?q=jollof
GET /api/v1/restaurants/:restaurantId
POST /api/v1/auth/register
POST /api/v1/auth/login
GET /api/v1/auth/me
POST /api/v1/auth/logout
GET /api/v1/orders
GET /api/v1/orders/:orderId
POST /api/v1/orders
```

Success responses use `{ "data": ... }`; failures use `{ "error": { "code": "...", "message": "..." } }`. The app maps backend error codes to safe user-facing states.

Authenticated endpoints use `Authorization: Bearer <session-token>`. Checkout submits only menu item IDs, quantities, notes, an address, and a unique `Idempotency-Key`. Prices and delivery fees are always calculated by the server. A retry reuses its key only while the cart and address payload remain identical.

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

GitHub Actions runs dependency resolution, formatting checks, static analysis, and tests on pushes to `main` and pull requests. The suite covers the application shell, navigation, cart invariants, restaurant parsing, bearer authorization, idempotency headers, and the rule that checkout never sends client-controlled prices.

## Security rules

- Session tokens are stored with `flutter_secure_storage` and cleared after logout or a `401` response.
- Android application backups are disabled so encrypted session state cannot be restored without its key material.
- Treat every value embedded in the app as public.
- Never calculate authoritative order totals on the device.
- Require HTTPS in staging and production.
- Do not log tokens, addresses, or payment details.
- Verify payments and webhook signatures only on the backend.

## Roadmap

- [x] Branded Flutter foundation and asset integration
- [x] HTTP restaurant discovery and search
- [x] Debug/release network policy separation
- [x] Restaurant detail and categorized menu
- [x] Sign-up, sign-in, logout, and secure session persistence
- [ ] Address management and delivery eligibility
- [x] Cart, notes, quantities, and idempotent checkout
- [ ] Payment provider integration
- [x] Order history, detail, and status timeline
- [ ] Push notifications and realtime order updates
- [ ] Accessibility, localization, and store-release audit

## License

Copyright © 2026 NdiChow. All rights reserved unless a separate license is added.
