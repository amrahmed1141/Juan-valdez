# Juan Valdez

A modern café ordering Flutter app for **Juan Valdez** — browse the menu, check in, and track your dine-in visit.

## Features

- Soft onboarding with Explore CTA
- Home product list with hover expand cards (desktop / web)
- Product details with Order / Add to Cart
- Cart with quantity controls and Place Order
- State management via **flutter_bloc (Cubit)**
- Poppins typography via Google Fonts
- Responsive layout for phone and tablet

## Getting started

```bash
flutter pub get
flutter run
```

For web / desktop hover interactions:

```bash
flutter run -d chrome
# or
flutter run -d windows
```

## Project structure

```
lib/
  app/routes/          # Named routes + transitions
  core/                # Colors, strings, assets, theme
  cubits/              # CartCubit, HomeCubit
  data/models/         # ProductModel, CartItemModel
  data/mock/           # Mock product catalogue
  screens/             # Onboarding, Home, Details, Cart
  widgets/             # Hover cards, nav bar, chips
```
