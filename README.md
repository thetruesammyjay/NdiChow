# NdiChow Mobile

NdiChow is a Flutter food-ordering application for discovering nearby restaurants, browsing menus, building a cart, checking out, and following an order from confirmation to delivery.

This repository contains the customer-facing Android and iOS application. The API lives in the separate [`NdiChow-backend`](https://github.com/thetruesammyjay/NdiChow-backend) repository.

## Project status

The project is in its foundation stage. The current build includes:

- A branded Material 3 design system
- Original NdiChow launcher artwork for Android and iOS
- A responsive four-tab application shell
- Food discovery home screen
- Restaurant summary models and repository abstraction
- Seeded development restaurant data
- Search, order history, and profile foundations
- Loading, error, empty, and pull-to-refresh states
- Environment-based API configuration
- An initial widget test
- Android and iOS project shells

Checkout, authentication, persistent carts, payments, and live order tracking are planned next.

## Product experience

The customer journey is designed around these steps:

1. Choose a delivery address.
2. Discover or search for a restaurant.
3. Browse the menu and customize food items.
4. Review the cart and delivery fees.
5. Select an address and payment method.
6. Place the order.
7. Follow preparation and delivery status.
8. Reorder, review, or contact support afterward.

The primary navigation contains Home, Search, Orders, and Profile. The cart will be exposed as a persistent contextual action with an item-count badge.

## Design system

NdiChow uses a friendly, high-contrast visual language:

| Token | Value | Use |
| --- | --- | --- |
| Primary | `#FF3355` | Main actions, active navigation, cart badges |
| Primary light | `#FF5A76` | Gradients and secondary brand emphasis |
| Background | `#F4F4F4` | App canvas |
| Surface | `#FFFFFF` | Cards, fields, and navigation |
| Success | `#10B981` | Open restaurants and successful orders |
| Warning | `#F59E0B` | Ratings, delays, and promotions |
| Text | `#111827` | Primary content |

PP Neue Machina is bundled for distinctive headings and labels. Cards use generous radii, white surfaces, restrained shadows, and a floating pill-shaped bottom navigation.

Design tokens are defined in [`lib/core/theme`](lib/core/theme).

## Architecture

The app follows a feature-first structure. Screens depend on repositories and application controllers rather than talking directly to databases.

```text
lib/
├── core/
│   ├── config/            # Environment and application configuration
│   ├── navigation/        # Root shell and route ownership
│   └── theme/             # Color, spacing, typography, and component themes
├── features/
│   ├── cart/              # Cart state and future cart UI
│   ├── home/              # Discovery data and presentation
│   ├── orders/            # Active and previous orders
│   ├── profile/           # Customer account and preferences
│   └── search/            # Dish and restaurant discovery
├── shared/
│   ├── models/            # Cross-feature domain models
│   └── widgets/           # Reusable UI components
└── main.dart              # Bootstrap and MaterialApp
```

The current `MockHomeRepository` provides deterministic development data. It will be replaced behind the same interface by an HTTP repository connected to the backend.

## Requirements

- Flutter 3.x with Dart 3.7 or newer
- Android Studio or Xcode for platform builds
- Android emulator/device or iOS simulator/device
- A running NdiChow backend for API-connected features

Verify the toolchain with:

```bash
flutter doctor
```

## Local setup

Clone and enter the project:

```bash
git clone https://github.com/thetruesammyjay/NdiChow.git
cd NdiChow
```

Create the local environment file:

```bash
cp .env.example .env
```

Install packages and run:

```bash
flutter pub get
flutter run
```

On an Android emulator, `10.0.2.2` points to the host machine. The default environment therefore uses:

```env
API_BASE_URL=http://10.0.2.2:4000/api/v1
```

For an iOS simulator, use `http://127.0.0.1:4000/api/v1`. For a physical device, use the development machine's LAN address and ensure both devices are on the same network.

## Environment variables

| Variable | Required | Description |
| --- | --- | --- |
| `API_BASE_URL` | Yes | Versioned NdiChow backend URL |
| `APP_ENV` | Yes | `development`, `staging`, or `production` |

The `.env` file is excluded from Git. Do not place private server credentials, payment secrets, or database credentials in the mobile application. Anything bundled into a client application must be treated as public.

## Common commands

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run

# Analyze Dart code
flutter analyze

# Run all tests
flutter test

# Format source and tests
dart format lib test

# Build Android artifacts
flutter build apk
flutter build appbundle

# Build iOS without signing
flutter build ios --no-codesign
```

## Backend integration contract

All application traffic should use the versioned API prefix configured by `API_BASE_URL`. The backend currently exposes:

- `GET /restaurants`
- `GET /restaurants/:restaurantId`
- `GET /orders`
- `GET /orders/:orderId`
- `POST /orders`

Successful responses use a data envelope:

```json
{
  "data": {}
}
```

Errors use a stable code and user-safe message:

```json
{
  "error": {
    "code": "RESTAURANT_NOT_FOUND",
    "message": "Restaurant not found."
  }
}
```

When authentication is introduced, the client will send a short-lived bearer access token. It will not send database credentials or trust client-calculated prices.

## State management

Provider is included for application state. Controllers should remain small and feature-scoped:

- UI widgets render state and dispatch user intent.
- Controllers coordinate user-facing state.
- Repositories own API and persistence operations.
- Models represent typed domain data.

Avoid placing HTTP calls, JSON decoding, payment logic, or mutable global state directly in screens.

## Testing strategy

The test suite will grow across three levels:

- Unit tests for models, repositories, totals, and controllers
- Widget tests for loading, error, empty, navigation, cart, and checkout states
- Integration tests for authentication, checkout, payment callbacks, and order tracking

Run the current test suite with `flutter test`.

## Roadmap

### Foundation

- [x] Project and native platform scaffolding
- [x] Design tokens and branded application shell
- [x] Initial restaurant discovery UI
- [x] Repository abstraction and seeded development data
- [ ] HTTP client, typed DTOs, and API error mapping

### Ordering MVP

- [ ] Customer sign-up and sign-in
- [ ] Address capture and location selection
- [ ] Restaurant details and categorized menus
- [ ] Item customization and add-ons
- [ ] Persistent cart with server price validation
- [ ] Checkout and order placement
- [ ] Payment provider integration
- [ ] Active order timeline and push notifications
- [ ] Order history and reorder

### Growth

- [ ] Favorites and reviews
- [ ] Promotions and referral codes
- [ ] Scheduled orders
- [ ] Restaurant availability and delivery zones
- [ ] Accessibility and localization audit
- [ ] App Store and Play Store release automation

## Engineering conventions

- Keep features independent and expose narrow public interfaces.
- Prefer immutable typed models over dynamic maps.
- Keep all colors and dimensions in the theme layer.
- Include explicit loading, empty, error, and offline states.
- Keep interactive targets at least 44 logical pixels.
- Never trust client-calculated menu prices or delivery fees on the server.
- Add tests for every important state transition and regression.
- Run formatting, analysis, and tests before opening a pull request.

## Security

- Environment files, signing keys, and service credentials must never be committed.
- Payment confirmation must be verified by the backend using provider webhooks.
- Authentication tokens should use secure platform storage.
- Sensitive personal data should be minimized and encrypted where appropriate.
- Logging must not include tokens, complete payment data, or unnecessary address details.

## License

Copyright © 2026 NdiChow. All rights reserved unless a separate license is added.
